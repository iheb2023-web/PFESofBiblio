import 'package:app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/controllers/theme_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Ajouter le message de l'utilisateur
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _textController.clear();
      _scrollToBottom();
    });

    // Obtenir la réponse du chatbot
    try {
      final response = await _geminiService.generateResponse(text);

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Désolé, une erreur s'est produite. Veuillez réessayer.",
            isUser: false,
          ),
        );
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder:
          (themeController) => Scaffold(
            appBar: AppBar(
              title: const Text('Chat Intelligent'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor:
                  themeController.isDarkMode ? Colors.white : Colors.black,
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(
                          message: _messages[index].text,
                          isUser: _messages[index].isUser,
                        );
                      },
                    ),
                  ),
                ),
                _buildInputField(themeController),
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeController.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color:
                themeController.isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    themeController.isDarkMode
                        ? Colors.grey[700]
                        : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isUser
                      ? Colors.blue
                      : (themeController.isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[200]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    isUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                bottomRight:
                    isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color:
                    isUser
                        ? Colors.white
                        : (themeController.isDarkMode
                            ? Colors.white
                            : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
