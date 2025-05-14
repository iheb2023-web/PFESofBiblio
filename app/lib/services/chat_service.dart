import 'dart:convert';

import 'package:app/config/app_config.dart';
import 'package:app/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  Future<String> generateResponse(
    String prompt,
    int? userid, {
    String? userId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {'prompt': prompt};
      if (userId != null) {
        requestBody['user_id'] = userId;
      }

      final response = await http.post(
        Uri.parse(AppConfig.chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['response'] ?? 'Je n\'ai pas pu répondre.';
      } else {
        debugPrint('Erreur HTTP: ${response.statusCode}');
        return 'Une erreur est survenue.';
      }
    } catch (e) {
      debugPrint('Erreur: $e');
      return 'Une erreur est survenue.';
    }
  }

  Future<String> generateResponseWithChat(
    List<String> history,
    String prompt, {
    String? userId,
  }) async {
    try {
      String promptWithHistory = history.join('\n') + '\n' + prompt;

      final Map<String, dynamic> requestBody = {'prompt': promptWithHistory};
      if (userId != null) {
        requestBody['user_id'] = userId;
      }

      final response = await http.post(
        Uri.parse(AppConfig.chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['response'] ?? 'Je n\'ai pas pu répondre.';
      } else {
        debugPrint('Erreur HTTP: ${response.statusCode}');
        return 'Une erreur est survenue.';
      }
    } catch (e) {
      debugPrint('Erreur (chat): $e');
      return 'Une erreur est survenue.';
    }
  }

  Future<String> sendWelcomeMessage(String firstName, {String? userId}) async {
    try {
      final welcomePrompt =
          "L'utilisateur $firstName vient d'ouvrir le chat. "
          "Envoie un message de bienvenue personnalisé et propose ton aide "
          "pour des questions sur la bibliothèque.";

      final Map<String, dynamic> requestBody = {'prompt': welcomePrompt};
      if (userId != null) {
        requestBody['user_id'] = userId;
      }

      final response = await http.post(
        Uri.parse(AppConfig.chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['response'] ??
            'Bonjour $firstName ! Comment puis-je vous aider ?';
      } else {
        return 'Bonjour $firstName ! Comment puis-je vous aider aujourd\'hui ?';
      }
    } catch (e) {
      return 'Bonjour $firstName ! En quoi puis-je vous aider ?';
    }
  }
}
