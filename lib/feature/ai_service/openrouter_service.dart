import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _chatCompletionsEndpoint = '/chat/completions';

  final String _apiKey;

  OpenRouterService({required String apiKey}) : _apiKey = apiKey;

  /// Send a text-only message to OpenRouter API
  Future<OpenRouterResponse> sendTextMessage({
    required String message,
    String model = 'google/gemini-2.5-pro',
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      final requestBody = {
        'model': model,
        'messages': [
          {'role': 'user', 'content': message},
        ],
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };

      final response = await _makeRequest(requestBody);
      return OpenRouterResponse.fromJson(response);
    } catch (e) {
      throw OpenRouterException('Failed to send text message: $e');
    }
  }

  /// Send a message with image to OpenRouter API
  Future<OpenRouterResponse> sendMessageWithImage({
    required String message,

    String model = 'anthropic/claude-3-sonnet',
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      // Convert image bytes to base64

      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': message},
            ],
          },
        ],
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };

      final response = await _makeRequest(requestBody);
      return OpenRouterResponse.fromJson(response);
    } catch (e) {
      throw OpenRouterException('Failed to send message with image: $e');
    }
  }

  /// Send a message with image URL to OpenRouter API
  Future<OpenRouterResponse> sendMessageWithImageUrl({
    required String message,
    required String imageUrl,
    String model = 'anthropic/claude-3-sonnet',
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': message},
              {
                'type': 'image_url',
                'image_url': {'url': imageUrl},
              },
            ],
          },
        ],
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };

      final response = await _makeRequest(requestBody);
      return OpenRouterResponse.fromJson(response);
    } catch (e) {
      throw OpenRouterException('Failed to send message with image URL: $e');
    }
  }

  /// Send a conversation with multiple messages
  Future<OpenRouterResponse> sendConversation({
    required List<OpenRouterMessage> messages,
    String model = 'anthropic/claude-3-sonnet',
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      final requestBody = {
        'model': model,
        'messages': messages.map((msg) => msg.toJson()).toList(),
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };

      final response = await _makeRequest(requestBody);
      return OpenRouterResponse.fromJson(response);
    } catch (e) {
      throw OpenRouterException('Failed to send conversation: $e');
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    Map<String, dynamic> requestBody,
  ) async {
    final url = Uri.parse('$_baseUrl$_chatCompletionsEndpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer':
            'https://github.com/hariprasath761/canvas_drawer_plus', // Optional: for analytics
        'X-Title': 'Canvas Drawer Plus', // Optional: for analytics
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = response.body;
      debugPrint('OpenRouter API Error: ${response.statusCode} - $errorBody');
      throw OpenRouterException(
        'API request failed with status ${response.statusCode}: $errorBody',
      );
    }
  }
}

/// Represents a message in the OpenRouter conversation
class OpenRouterMessage {
  final String role; // 'user' or 'assistant'
  final dynamic content; // String or List<Map<String, dynamic>>

  OpenRouterMessage({required this.role, required this.content});

  /// Create a text-only user message
  factory OpenRouterMessage.userText(String text) {
    return OpenRouterMessage(role: 'user', content: text);
  }

  /// Create a user message with text and image
  factory OpenRouterMessage.userWithImage({
    required String text,
    required String imageUrl,
  }) {
    return OpenRouterMessage(
      role: 'user',
      content: [
        {'type': 'text', 'text': text},
        {
          'type': 'image_url',
          'image_url': {'url': imageUrl},
        },
      ],
    );
  }

  /// Create an assistant response message
  factory OpenRouterMessage.assistant(String text) {
    return OpenRouterMessage(role: 'assistant', content: text);
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

/// Response from OpenRouter API
class OpenRouterResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenRouterChoice> choices;
  final OpenRouterUsage? usage;

  OpenRouterResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) {
    return OpenRouterResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices:
          (json['choices'] as List)
              .map((choice) => OpenRouterChoice.fromJson(choice))
              .toList(),
      usage:
          json['usage'] != null
              ? OpenRouterUsage.fromJson(json['usage'])
              : null,
    );
  }

  /// Get the first response text
  String get text => choices.isNotEmpty ? choices.first.message.content : '';

  /// Get all response texts
  List<String> get allTexts =>
      choices.map((choice) => choice.message.content as String).toList();
}

class OpenRouterChoice {
  final int index;
  final OpenRouterMessage message;
  final String? finishReason;

  OpenRouterChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory OpenRouterChoice.fromJson(Map<String, dynamic> json) {
    return OpenRouterChoice(
      index: json['index'] as int,
      message: OpenRouterMessage(
        role: json['message']['role'] as String,
        content: json['message']['content'] as String,
      ),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

class OpenRouterUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  OpenRouterUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenRouterUsage.fromJson(Map<String, dynamic> json) {
    return OpenRouterUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

class OpenRouterException implements Exception {
  final String message;

  OpenRouterException(this.message);

  @override
  String toString() => 'OpenRouterException: $message';
}

/// Available OpenRouter models for easy reference
class OpenRouterModels {
  static const String claude3Sonnet = 'anthropic/claude-3-sonnet';
  static const String claude3Haiku = 'anthropic/claude-3-haiku';
  static const String claude35Sonnet = 'anthropic/claude-3.5-sonnet';
  static const String gpt4Vision = 'openai/gpt-4-vision-preview';
  static const String gpt4Turbo = 'openai/gpt-4-turbo';
  static const String geminiPro = 'google/gemini-2.5-pro';
  static const String geminiProVision = 'google/gemini-pro-vision';
}
