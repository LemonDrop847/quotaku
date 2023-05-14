import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
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

  @override
  void initState() {
    super.initState();
  }

  void _resetQuote() async {
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '$quoteText',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Merriweather',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '-$char, $anime',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetQuote,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
