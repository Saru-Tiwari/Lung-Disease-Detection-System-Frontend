import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:personal_health_assistant/homepage/dashboard_page.dart';
import 'package:personal_health_assistant/homepage/user.dart';

class ChatbotPage extends StatefulWidget {
  final User loggedInUser;

  const ChatbotPage({super.key, required this.loggedInUser});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  final String _apiUrl = "http://10.10.1.18:1052/chat"; // backend URL

  @override
  void initState() {
    super.initState();
    _chatHistory.add({
      "role": "assistant",
      "content":
          "Hello 👋 I’m **PulmoCheck**, your AI-powered lung health assistant.\n\n"
          "I can provide **information** about respiratory health, "
          "common lung conditions, prevention tips, and when to seek medical care.\n\n"
          "How may I assist you today?",
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message
    setState(() {
      _chatHistory.add({"role": "user", "content": userMessage});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage, "history": _chatHistory}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fullMessage = data["message"] as String;

        // Add placeholder for AI response
        _chatHistory.add({"role": "assistant", "content": ""});
        final int index = _chatHistory.length - 1;

        // Stream the response character by character
        for (int i = 0; i < fullMessage.length; i++) {
          await Future.delayed(const Duration(milliseconds: 15), () {
            setState(() {
              _chatHistory[index]["content"] =
                  _chatHistory[index]["content"]! + fullMessage[i];
            });
          });
        }
      } else {
        _addErrorMessage();
      }
    } catch (e) {
      _addErrorMessage();
    }

    setState(() => _isLoading = false);
  }

  void _addErrorMessage() {
    setState(() {
      _chatHistory.add({
        "role": "assistant",
        "content":
            "⚠️ I’m sorry — I’m currently unable to respond.\n\nPlease try again later.",
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF4F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE84C88)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DashboardPage(loggedInUser: widget.loggedInUser),
              ),
            );
          },
        ),
        title: Row(
          children: const [
            Text(
              "Pulmo Check",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE84C88),
              ),
            ),
            SizedBox(width: 6),
            CircleAvatar(radius: 4, backgroundColor: Colors.green),
            SizedBox(width: 6),
            Text(
              "Assistant Online",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _chatList()),
          _chatInput(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _chatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final msg = _chatHistory[index];
        final isUser = msg["role"] == "user";

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .75,
            ),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFE84C88) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: MarkdownBody(
              data: msg["content"]!,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser ? Colors.white : Colors.black87,
                ),
                h3: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE84C88),
                ),
                listBullet: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chatInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading, // disable input while AI is typing
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          _isLoading
              ? Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE84C88),
                  ),
                ),
        ],
      ),
    );
  }
}
