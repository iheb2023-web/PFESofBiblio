import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyALbVJW9lf4zi5NMkAWOFusTq7YMdy03ME'; // à sécuriser

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // Chat sans historique (nouvelle conversation)
  Future<String> generateResponse(String prompt) async {
    try {
      final chat = _model.startChat(); // Pas d'historique ici
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? 'Je n\'ai pas pu répondre.';
    } catch (e) {
      debugPrint('Erreur: $e');
      return 'Une erreur est survenue.';
    }
  }

  // Chat avec historique (conversation continue)
  Future<String> generateResponseWithChat(
    List<Content> history,
    String prompt,
  ) async {
    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? 'Je n\'ai pas pu répondre.';
    } catch (e) {
      debugPrint('Erreur (chat): $e');
      return 'Une erreur est survenue.';
    }
  }
}
