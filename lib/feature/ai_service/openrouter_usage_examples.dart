/// Example usage of OpenRouter API integration in Canvas Drawer Plus
///
/// This file demonstrates how to use the OpenRouter service for AI-enhanced
/// drawing capabilities in your Flutter app.
library;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../drawing_room/presentation/viewmodel/drawing_canvas_viewmodel.dart';
import 'ai_config.dart';
import 'openrouter_service.dart';

class OpenRouterUsageExample {
  /// Example 1: Initialize OpenRouter in your app
  static void initializeOpenRouterExample(DrawingCanvasViewModel viewModel) {
    // Method 1: Using environment variable (recommended for production)
    const apiKey = String.fromEnvironment('OPENROUTER_API_KEY');
    if (apiKey.isNotEmpty) {
      viewModel.initializeOpenRouter(apiKey);
    }

    // Method 2: Using hardcoded key (only for testing, not recommended)
    // viewModel.initializeOpenRouter('your-api-key-here');

    // Method 3: Using configuration class
    if (AIConfig.isOpenRouterConfigured) {
      viewModel.initializeOpenRouter(AIConfig.getOpenRouterApiKey());
    }
  }

  /// Example 2: Analyze current drawing
  static Future<void> analyzeDrawingExample(
    DrawingCanvasViewModel viewModel,
  ) async {
    await viewModel.analyzeDrawingWithOpenRouter(
      analysisPrompt: AIConfig.analysisPrompts['identify']!,
      model: OpenRouterModels.claude35Sonnet,
    );
  }

  /// Example 3: Enhance drawing with AI suggestions
  static Future<void> enhanceDrawingExample(
    DrawingCanvasViewModel viewModel,
  ) async {
    await viewModel.enhanceDrawingWithOpenRouter(
      model: OpenRouterModels.claude35Sonnet,
    );
  }

  /// Example 4: Convert text to drawing
  static Future<void> textToDrawingExample(
    DrawingCanvasViewModel viewModel,
    String text,
  ) async {
    await viewModel.convertTextToDrawingWithOpenRouter(
      text: text,
      model: OpenRouterModels.claude35Sonnet,
    );
  }

  /// Example 5: Analyze drawing from image
  static Future<void> analyzeDrawingImageExample(
    DrawingCanvasViewModel viewModel,
    Uint8List imageBytes,
  ) async {
    await viewModel.analyzeDrawingImageWithOpenRouter(
      analysisPrompt:
          'What do you see in this drawing? Provide detailed analysis.',
      model: OpenRouterModels.claude35Sonnet,
    );
  }

  /// Example 6: Direct OpenRouter service usage
  static Future<void> directOpenRouterExample() async {
    const apiKey = 'your-openrouter-api-key';
    final service = OpenRouterService(apiKey: apiKey);

    try {
      // Text-only message
      final response = await service.sendTextMessage(
        message: 'What is in this image?',
        model: OpenRouterModels.claude35Sonnet,
      );
      print('AI Response: ${response.text}');

      // Message with image URL
      final imageResponse = await service.sendMessageWithImageUrl(
        message: 'Describe this image',
        imageUrl: 'https://example.com/image.jpg',
        model: OpenRouterModels.claude35Sonnet,
      );
      print('Image Analysis: ${imageResponse.text}');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example 7: Flutter widget integration
  static Widget buildOpenRouterControlsExample(
    DrawingCanvasViewModel viewModel,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => analyzeDrawingExample(viewModel),
          child: const Text('Analyze Drawing'),
        ),
        ElevatedButton(
          onPressed: () => enhanceDrawingExample(viewModel),
          child: const Text('Enhance with AI'),
        ),
        ElevatedButton(
          onPressed:
              () => textToDrawingExample(viewModel, 'a house with a tree'),
          child: const Text('Text to Drawing'),
        ),
      ],
    );
  }
}

/// Example curl command equivalent in Dart
class CurlEquivalentExample {
  /// This is equivalent to your curl command:
  /// ```bash
  /// curl https://openrouter.ai/api/v1/chat/completions \
  ///   -H "Content-Type: application/json" \
  ///   -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  ///   -d '{
  ///     "model": "anthropic/claude-sonnet-4",
  ///     "messages": [
  ///       {
  ///         "role": "user",
  ///         "content": [
  ///           {
  ///             "type": "text",
  ///             "text": "What is in this image?"
  ///           },
  ///           {
  ///             "type": "image_url",
  ///             "image_url": {
  ///               "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
  ///             }
  ///           }
  ///         ]
  ///       }
  ///     ]
  ///   }'
  /// ```
  static Future<void> curlEquivalent() async {
    const apiKey = 'your-openrouter-api-key';
    final service = OpenRouterService(apiKey: apiKey);

    try {
      final response = await service.sendMessageWithImageUrl(
        message: 'What is in this image?',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
        model:
            'anthropic/claude-sonnet-4', // Note: using claude-sonnet-4 as in your curl
        temperature: 0.7,
        maxTokens: 1000,
      );

      print('AI Response: ${response.text}');
      print('Usage: ${response.usage?.totalTokens} tokens');
    } catch (e) {
      print('Error: $e');
    }
  }
}

/// Configuration for environment variables
/// Add this to your .env file or set as environment variables:
/// ```
/// OPENROUTER_API_KEY=your-actual-api-key-here
/// ```
///
/// Then run your app with:
/// ```bash
/// flutter run --dart-define=OPENROUTER_API_KEY=your-actual-api-key-here
/// ```
