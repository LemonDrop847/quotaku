import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quotaku/image_gen.dart';
import 'dart:convert';
import 'background_carousel.dart';
import 'background_option.dart';
import 'menu.dart';
import 'quote.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
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
  List<BackgroundOption> backgroundOptions = List.generate(
    7,
    (index) => BackgroundOption(
      id: index,
      name: 'Background ${index + 1}',
      imagePath: 'assets/images/bg${index + 1}.jpg',
    ),
  );

  void _loadSelectedBackgroundOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int backgroundOptionId = prefs.getInt('background_option_id') ?? 0;
    setState(() {
      _selectedBackgroundOption = backgroundOptions[backgroundOptionId];
    });
  }

  void _setBackgroundOption(BackgroundOption option) async {
    setState(() {
      _selectedBackgroundOption = option;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('background_option_id', option.id);
  }

  final GlobalKey _repaintKey = GlobalKey();
  String quoteText = '';
  String anime = '';
  String char = '';
  bool loading = true;

  void _getQuote() async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)'
    };
    var url = Uri.parse('https://quotaku.up.railway.app/quote');

    var req = http.Request('GET', url);
    req.headers.addAll(headersList);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final responseJson = jsonDecode(resBody);
      final quote = Quote.fromJson(responseJson);
      print(quote.quote);
      setState(
        () {
          loading = false;
          quoteText = quote.quote;
          char = quote.character;
          anime = quote.anime;
        },
      );
    } else {
      print(res.reasonPhrase);
    }
  }

  @override
  void initState() {
    _getQuote();
    FlutterNativeSplash.remove();
    _loadSelectedBackgroundOption();
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
    var url = Uri.parse('https://quotaku.up.railway.app/forcequote');

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

  void _openBackgroundCarousel() async {
    final selectedBackgroundOption = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackgroundCarousel(
          backgroundOptions: backgroundOptions,
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
