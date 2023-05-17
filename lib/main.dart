import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quotaku/image_gen.dart';
import 'dart:convert';

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
  String quoteText = '';
  String anime = '';
  String char = '';
  bool loading = true;
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
    } else {
      print(res.reasonPhrase);
    }
  }

  @override
  void initState() {
    _getQuote();
    FlutterNativeSplash.remove();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
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
                  child: Card(
                    margin: const EdgeInsets.all(40),
                    color: Theme.of(context).canvasColor,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: loading
                          ? const CircularProgressIndicator()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () async {
                                    shareImage(quoteText, '-$char\n$anime');
                                  },
                                )
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetQuote,
        tooltip: 'Refresh',
        icon: const Icon(Icons.refresh),
        label: const Text('Get New Quote'),
      ),
    );
  }
}
