import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ClaudeAIService {
  static final ClaudeAIService _instance = ClaudeAIService._internal();

  factory ClaudeAIService() => _instance;

  final List<Map<String, dynamic>> _messages = [];
  // Using hardcoded API key instead of environment variable
  final String _apiKey = '';
  final String _model = 'claude-3-opus-20240229'; // Claude model to use
  final String _topic = 'Space Exploration'; // Topic constraint

  ClaudeAIService._internal() {
    // System message is handled separately in the API call, not in the messages array
  }

  Future<String?> chat(String userMessage) async {
    try {
      // Add user message to conversation history
      _addMessage(isFromUser: true, message: userMessage);

      // Prepare request to Claude API
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01'
        },
        body: jsonEncode({
          'model': _model,
          'messages': _messages,
          'system': "You are a helpful assistant specialized in $_topic. "
              "Only provide information related to $_topic. "
              "If asked about other topics, politely redirect the conversation back to $_topic. "
              "Be informative, educational, and engaging when discussing $_topic.",
          'max_tokens': 500,
          'temperature': 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final assistantMessage = jsonResponse['content'][0]['text'];
        
        // Add assistant response to conversation history
        _addMessage(isFromUser: false, message: assistantMessage);
        
        return assistantMessage;
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode} - ${response.body}');
        }
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      return 'Error: $e';
    }
  }

  void _addMessage({required String message, required bool isFromUser}) {
    _messages.add({
      'role': isFromUser ? 'user' : 'assistant',
      'content': message
    });
  }
}
