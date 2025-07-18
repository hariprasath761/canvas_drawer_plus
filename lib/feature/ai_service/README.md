# OpenRouter AI Integration for Canvas Drawer Plus

This document explains how to integrate and use OpenRouter AI capabilities in your Canvas Drawer Plus application.

## Overview

OpenRouter provides access to multiple AI models including Claude, GPT-4, Gemini, and more through a single API. This integration adds powerful AI capabilities to your drawing app:

- **Drawing Analysis**: Analyze what users have drawn and provide insights
- **Drawing Enhancement**: AI suggests improvements and additions to drawings
- **Text-to-Drawing**: Convert text descriptions into drawing instructions
- **Image Analysis**: Analyze drawing images using vision models

## Setup

### 1. Get OpenRouter API Key

1. Visit [OpenRouter.ai](https://openrouter.ai/)
2. Sign up for an account
3. Get your API key from the dashboard

### 2. Configure API Key

**Option A: Environment Variable (Recommended)**
```bash
# Set environment variable
export OPENROUTER_API_KEY="your-api-key-here"

# Run Flutter app with the environment variable
flutter run --dart-define=OPENROUTER_API_KEY="your-api-key-here"
```

**Option B: Direct Configuration**
```dart
// In your app initialization
final viewModel = DrawingCanvasViewModel(/*...*/);
viewModel.initializeOpenRouter("your-api-key-here");
```

### 3. Add Dependencies

Ensure you have the required dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.4.0
  flutter: 
    sdk: flutter
```

## Usage

### Initialize OpenRouter Service

```dart
import 'package:canvas_drawer_plus/feature/ai_service/ai_config.dart';

// In your widget or initialization code
if (AIConfig.isOpenRouterConfigured) {
  viewModel.initializeOpenRouter(AIConfig.getOpenRouterApiKey());
}
```

### Drawing Analysis

```dart
// Analyze what the user has drawn
await viewModel.analyzeDrawingWithOpenRouter(
  analysisPrompt: "What objects do you see in this drawing?",
  model: OpenRouterModels.claude35Sonnet,
);
```

### Drawing Enhancement

```dart
// Let AI suggest improvements to the drawing
await viewModel.enhanceDrawingWithOpenRouter(
  model: OpenRouterModels.claude35Sonnet,
);
```

### Text to Drawing

```dart
// Convert text description to drawing
await viewModel.convertTextToDrawingWithOpenRouter(
  text: "a house with a tree and a sun",
  model: OpenRouterModels.claude35Sonnet,
);
```

### Image Analysis

```dart
// Analyze a drawing image
await viewModel.analyzeDrawingImageWithOpenRouter(
  imageBytes: drawingImageBytes,
  analysisPrompt: "Describe this drawing in detail",
  model: OpenRouterModels.claude35Sonnet,
);
```

## API Reference

### OpenRouterService

Main service class for interacting with OpenRouter API.

#### Methods

**sendTextMessage()**
```dart
Future<OpenRouterResponse> sendTextMessage({
  required String message,
  String model = 'anthropic/claude-3-sonnet',
  double? temperature,
  int? maxTokens,
})
```

**sendMessageWithImage()**
```dart
Future<OpenRouterResponse> sendMessageWithImage({
  required String message,
  required Uint8List imageBytes,
  String model = 'anthropic/claude-3-sonnet',
  double? temperature,
  int? maxTokens,
})
```

**sendMessageWithImageUrl()**
```dart
Future<OpenRouterResponse> sendMessageWithImageUrl({
  required String message,
  required String imageUrl,
  String model = 'anthropic/claude-3-sonnet',
  double? temperature,
  int? maxTokens,
})
```

### Available Models

```dart
class OpenRouterModels {
  static const String claude3Sonnet = 'anthropic/claude-3-sonnet';
  static const String claude35Sonnet = 'anthropic/claude-3.5-sonnet';
  static const String claude3Haiku = 'anthropic/claude-3-haiku';
  static const String gpt4Vision = 'openai/gpt-4-vision-preview';
  static const String gpt4Turbo = 'openai/gpt-4-turbo';
  static const String geminiPro = 'google/gemini-pro';
  static const String geminiProVision = 'google/gemini-pro-vision';
}
```

## Example: Complete Integration

```dart
import 'package:flutter/material.dart';
import 'package:canvas_drawer_plus/feature/ai_service/openrouter_service.dart';
import 'package:canvas_drawer_plus/feature/ai_service/ai_config.dart';

class AIDrawingControls extends StatelessWidget {
  final DrawingCanvasViewModel viewModel;
  
  const AIDrawingControls({Key? key, required this.viewModel}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Initialize OpenRouter if not already done
        if (!AIConfig.isOpenRouterConfigured)
          ElevatedButton(
            onPressed: () => _showApiKeyDialog(context),
            child: const Text('Setup OpenRouter API'),
          ),
        
        // AI Analysis
        ElevatedButton(
          onPressed: () => viewModel.analyzeDrawingWithOpenRouter(
            analysisPrompt: "Analyze this drawing and identify objects",
          ),
          child: const Text('Analyze Drawing'),
        ),
        
        // AI Enhancement
        ElevatedButton(
          onPressed: () => viewModel.enhanceDrawingWithOpenRouter(),
          child: const Text('Enhance with AI'),
        ),
        
        // Text to Drawing
        ElevatedButton(
          onPressed: () => _showTextToDrawingDialog(context),
          child: const Text('Text to Drawing'),
        ),
      ],
    );
  }
  
  void _showApiKeyDialog(BuildContext context) {
    // Show dialog to input API key
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OpenRouter API Key'),
        content: TextField(
          onSubmitted: (apiKey) {
            viewModel.initializeOpenRouter(apiKey);
            Navigator.pop(context);
          },
          decoration: const InputDecoration(
            hintText: 'Enter your OpenRouter API key',
          ),
        ),
      ),
    );
  }
  
  void _showTextToDrawingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text to Drawing'),
        content: TextField(
          onSubmitted: (text) {
            viewModel.convertTextToDrawingWithOpenRouter(text: text);
            Navigator.pop(context);
          },
          decoration: const InputDecoration(
            hintText: 'Describe what you want to draw',
          ),
        ),
      ),
    );
  }
}
```

## Curl Command Equivalent

Your original curl command:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{
    "model": "anthropic/claude-sonnet-4",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What is in this image?"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg"
            }
          }
        ]
      }
    ]
  }'
```

Is equivalent to this Dart code:

```dart
final service = OpenRouterService(apiKey: 'your-api-key');

final response = await service.sendMessageWithImageUrl(
  message: 'What is in this image?',
  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
  model: 'anthropic/claude-sonnet-4',
);

print('Response: ${response.text}');
```

## Error Handling

```dart
try {
  final response = await service.sendTextMessage(
    message: 'Hello, AI!',
    model: OpenRouterModels.claude35Sonnet,
  );
  print('Success: ${response.text}');
} on OpenRouterException catch (e) {
  print('OpenRouter Error: ${e.message}');
} catch (e) {
  print('General Error: $e');
}
```

## Best Practices

1. **Store API keys securely**: Use environment variables or secure storage
2. **Handle rate limits**: Implement proper error handling and retry logic
3. **Cache responses**: Consider caching AI responses to reduce API calls
4. **User feedback**: Show loading indicators and clear error messages
5. **Model selection**: Choose appropriate models based on your use case:
   - Claude 3.5 Sonnet: Best for complex analysis and reasoning
   - Claude 3 Haiku: Fast and cost-effective for simple tasks
   - GPT-4 Vision: Excellent for image analysis
   - Gemini Pro: Good balance of performance and cost

## Troubleshooting

**Common Issues:**

1. **API Key not working**: Ensure the key is correctly set and has proper permissions
2. **Network errors**: Check internet connection and firewall settings
3. **Rate limits**: Implement exponential backoff for retries
4. **Image size limits**: Ensure images are within API size limits
5. **Model availability**: Some models may have regional restrictions

**Debug Mode:**

Enable logging to debug issues:

```dart
import 'package:flutter/foundation.dart';

// Enable debug logging
if (kDebugMode) {
  // OpenRouter service will automatically log requests/responses
}
```

## Cost Optimization

1. **Choose appropriate models**: Haiku models are cheaper than Sonnet
2. **Limit token usage**: Set reasonable maxTokens limits
3. **Cache results**: Don't re-analyze the same content
4. **Batch requests**: Combine multiple questions in one request when possible

## Security Considerations

1. **Never expose API keys in client code**
2. **Use environment variables or secure storage**
3. **Implement proper authentication in your app**
4. **Consider using a backend proxy for API calls**
5. **Validate all user inputs before sending to AI**

For more information, visit the [OpenRouter Documentation](https://openrouter.ai/docs).
