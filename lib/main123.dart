import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dart_phonetics/dart_phonetics.dart';

void main() {
  runApp(MySpeechSearch());
}

class MySpeechSearch extends StatelessWidget {
  const MySpeechSearch({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Speech and Search",
      home: SpeechSearch(),
    );
  }
}

class SpeechSearch extends StatefulWidget {
  const SpeechSearch({Key key}) : super(key: key);

  @override
  State<SpeechSearch> createState() => _SpeechSearchState();
}

class _SpeechSearchState extends State<SpeechSearch> {
  List<Map<String, dynamic>> _products = [
    {"id": 1, "title": "Dal", "price": 100},
    {"id": 2, "title": "moong dal", "price": 200},
    {"id": 3, "title": "masoor dal", "price": 150},
    {"id": 4, "title": "paneer", "price": 100},
    {"id": 5, "title": "karl", "price": 500},
    {"id": 6, "title": "carl", "price": 784},
    {"id": 7, "title": "oven", "price": 1000},
    {"id": 8, "title": "oben", "price": 1200},
    {"id": 9, "title": "biscuit", "price": 45},
  ];
  List<Map<String, dynamic>> _foundProducts = [];
  List<String> _similarSoundWords = [];
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speeking';
  final _textController = TextEditingController();
  Soundex soundex = Soundex();

  @override
  void initState() {
    _foundProducts = _products;
    _speech = stt.SpeechToText();
    super.initState();
  }

  void _runFilter(String enterKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enterKeyword.isEmpty) {
      results = _products;
    } else {
      results = _products
          .where((user) =>
              user["title"].toLowerCase().contains(enterKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speech to Text"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.all(15),
            child: TextField(
              controller: _textController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  hintText: "Search!",
                  prefixIcon: Icon(Icons.search),
                  // label: Text(_text),
                  suffixIcon: InkWell(onTap: _listen, child: Icon(Icons.mic))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foundProducts.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Card(
                  key: ValueKey(_foundProducts[index]["id"]),
                  color: Colors.orange,
                  elevation: 4,
                  // margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text("${_foundProducts[index]["title"].toString()}"),
                    // subtitle: Text("${_foundProducts[index]["price"].toString()}"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _listen() async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      await _speech.listen().then((result) {
        _text = result;
        String encodedText = soundex.encode(_text).toString();
        List<Map<String, dynamic>> foundProducts = [];
        _similarSoundWords = [];
        for (var product in _products) {
          String encodedTitle = soundex.encode(product['title']).toString();
          if (encodedTitle == encodedText) {
            foundProducts.add(product);
            _similarSoundWords.add(product['title']);
          }
        }

        print("here the text");
        print(_similarSoundWords);
        setState(() {
          _foundProducts = foundProducts;
        });
      });
      _isListening = false;
    } else {
      print("Speech recognition not available");
    }
  }
}
