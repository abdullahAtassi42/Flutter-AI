import 'package:flutter/material.dart';
import 'dart:math';

// to make HTTP requests
import 'package:http/http.dart' as http;

// to encode/decode JSON
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

//Variables
final random = Random();

List start = ['Your journey starts here!', 'Chat GPT', 'Flutter is awesome!', 'Dart is fun!'];
int randomNumber = random.nextInt(start.length);

const String geminiApiKey = 'example_api_key'; // replace with actual api key

const String geminiModel = 'gemini-2.5-flash';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController _messageController = TextEditingController();
  List<String> chat = [];

  Future<String> sendToGemini(String userMessage) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent',
    );

    // http post request
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json', // tells Gemini we send JSON
        'x-goog-api-key': geminiApiKey, // authenticates request
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage} // user prompt
            ]
          }
        ]
      }),
    );

    // error handling
    if (response.statusCode != 200) {
      throw Exception('Gemini error: ${response.body}');
    }

    // decode response
    final decoded = jsonDecode(response.body);

    // extract gemini's text reply
    return decoded['candidates'][0]['content']['parts'][0]['text'];
  }

  // Existing message add
  void _addMessage(String message) {
    setState(() {
      chat.add(message);
    });
  }

  // sending user message and receiving Gemini response
  Future<void> _handleSend(String message) async {
    _addMessage(message); // adds user message to chat

    try {
      
      final aiReply = await sendToGemini(message);

      // add the response to the chat
      setState(() {
        chat.add(aiReply);
      });
    } catch (e) {
      //show error if something goes wrong
      setState(() {
        chat.add("Error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[500],
          title: Text("Hello There!", style: TextStyle(fontFamily: "Federo")),
        ),
        backgroundColor: Colors.teal[400],
        drawer: Drawer(
          backgroundColor: Colors.teal[400],
          child: ListView(
            padding: EdgeInsets.all(5),
            children: [
              DrawerHeader(child: Icon(Icons.history)),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("HOME"),
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: chat.length,
                      itemBuilder: (context, index) {
                        // 🔽 unchanged UI logic
                        if (index % 2 == 0) {
                          return Row(
                            children: [
                              const Spacer(),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal[500],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(chat[index]),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.lime[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(chat[index]),
                              ),
                              const Spacer(),
                            ],
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            if (chat.isEmpty)
              Center(
                child: Text(
                  start[randomNumber],
                  style: TextStyle(fontFamily: "Monoton", fontSize: 30),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (value) async {
                    if (value.trim().isNotEmpty) {
                      _messageController.clear();

                      // 🔽 CHANGED: now sends message to Gemini
                      await _handleSend(value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal[200],
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter text here',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


