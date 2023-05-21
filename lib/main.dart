import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:quotaku/image_gen.dart';
import 'dart:convert';
import 'background_carousel.dart';
import 'background_option.dart';
import 'menu.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class Quote {
  Quote({
    required this.anime,
    required this.character,
    required this.quote,
  });

  String anime;
  String character;
  String quote;
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
        anime: json['anime'],
        character: json['character'],
        quote: json['quote']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotaku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quotaku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BackgroundOption _selectedBackgroundOption = BackgroundOption(
    id: 0,
    name: 'Background 1',
    imagePath: 'assets/images/bg1.jpg',
  );
  void _setBackgroundOption(BackgroundOption option) {
    setState(() {
      _selectedBackgroundOption = option;
    });
  }

  final GlobalKey _repaintKey = GlobalKey();
  String quoteText = '';
  String anime = '';
  String char = '';
  bool loading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void _getQuote() async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)'
    };
    var url = Uri.parse('https://lemonquotaku.pythonanywhere.com/quote');

    var req = http.Request('GET', url);
    req.headers.addAll(headersList);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final responseJson = jsonDecode(resBody);
      final quote = Quote.fromJson(responseJson);
      print(quote.quote);
      setState(() {
        loading = false;
        quoteText = quote.quote;
        char = quote.character;
        anime = quote.anime;
      });
      scheduleDailyQuoteNotification(quoteText);
    } else {
      print(res.reasonPhrase);
    }
  }

  void initNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    _getQuote();
    FlutterNativeSplash.remove();
    initNotifications();
    super.initState();
  }

  void _resetQuote() async {
    setState(() {
      loading = true;
    });
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)'
    };
    var url = Uri.parse('https://lemonquotaku.pythonanywhere.com/forcequote');

    var req = http.Request('GET', url);
    req.headers.addAll(headersList);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final responseJson = jsonDecode(resBody);
      final quote = Quote.fromJson(responseJson);
      print(quote.quote);
      setState(() {
        loading = false;
        quoteText = quote.quote;
        char = quote.character;
        anime = quote.anime;
      });
    } else {
      print(res.reasonPhrase);
    }
  }

  void scheduleDailyQuoteNotification(String quote) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const int notificationId = 0;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Quotaku Daily Quote',
      quote,
      _nextInstanceOfTime(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote_channel',
          'Anime Quote Channel',
          importance: Importance.defaultImportance,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    prefs.setString('last_quote', quote);
  }

  tz.TZDateTime _nextInstanceOfTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10); // 10 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _openBackgroundCarousel() async {
    final selectedBackgroundOption = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackgroundCarousel(
          backgroundOptions: List.generate(
            7,
            (index) => BackgroundOption(
              id: index,
              name: 'Background ${index + 1}',
              imagePath: 'assets/images/bg${index + 1}.jpg',
            ),
          ),
          selectedBackgroundOption: _selectedBackgroundOption,
          onBackgroundOptionSelected: _setBackgroundOption,
        ),
      ),
    );
    if (selectedBackgroundOption != null) {
      _setBackgroundOption(selectedBackgroundOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        bottomOpacity: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Center(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kareudon',
              fontSize: 100,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _openBackgroundCarousel,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_selectedBackgroundOption.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.background,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 1.0,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: Card(
                        margin: const EdgeInsets.all(40),
                        color: Theme.of(context).canvasColor,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: loading
                              ? const CircularProgressIndicator()
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      quoteText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontFamily: 'Fallscoming',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      '-$char\n$anime',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Merriweather',
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Menu(
        onRefreshPressed: _resetQuote,
        onSharePressed: () async {
          shareCardAsImage(_repaintKey, quoteText, '-$char\n$anime');
        },
      ),
    );
  }
}
