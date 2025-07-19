import 'package:canvas_drawer_plus/env/env.dart';

/// Configuration class for AI services in Canvas Drawer Plus
class AIConfig {
  // OpenRouter API Configuration
  static const String openRouterApiKey = Env.openRouterAPIKey;

  static const String defaultAnalysisModel = 'anthropic/claude-3.5-sonnet';
  static const String defaultEnhancementModel = 'anthropic/claude-3.5-sonnet';
  static const String defaultTextToImageModel = 'anthropic/claude-3.5-sonnet';
  static const String defaultVisionModel = 'anthropic/claude-3.5-sonnet';

  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1500;
  static const int defaultTimeout = 30;

  static bool get isOpenRouterConfigured => openRouterApiKey.isNotEmpty;

  // Get API key from environment or return empty string
  static String getOpenRouterApiKey() {
    return openRouterApiKey;
  }

  // Validate configuration
  static String? validateConfiguration() {
    if (!isOpenRouterConfigured) {
      return 'OpenRouter API key not configured. Set OPENROUTER_API_KEY environment variable.';
    }
    return null;
  }

  // Available drawing analysis prompts
  static const Map<String, String> analysisPrompts = {
    'identify':
        'What objects or shapes do you see in this drawing? Identify the main elements.',
    'complete':
        'How can this drawing be completed or improved? Suggest missing elements.',
    'style':
        'What drawing style or technique is being used here? Provide artistic feedback.',
    'meaning':
        'What might this drawing represent or symbolize? Interpret the meaning.',
    'technical':
        'Analyze the technical aspects of this drawing - composition, balance, etc.',
  };

  // Text-to-drawing prompts
  static const Map<String, String> textToDrawingPrompts = {
    'simple': 'Create a simple drawing representation of: ',
    'detailed': 'Create a detailed drawing with multiple elements for: ',
    'artistic': 'Create an artistic interpretation drawing of: ',
    'technical': 'Create a technical diagram or schematic for: ',
    'cartoon': 'Create a cartoon-style drawing of: ',
  };
}

/// Extension to add helper methods for AI configuration
extension AIConfigExtension on AIConfig {
  /// Get a formatted prompt for analysis
  static String getAnalysisPrompt(String type, {String? customPrompt}) {
    if (customPrompt != null && customPrompt.isNotEmpty) {
      return customPrompt;
    }
    return AIConfig.analysisPrompts[type] ??
        AIConfig.analysisPrompts['identify']!;
  }

  /// Get a formatted prompt for text-to-drawing
  static String getTextToDrawingPrompt(String type, String text) {
    final basePrompt =
        AIConfig.textToDrawingPrompts[type] ??
        AIConfig.textToDrawingPrompts['simple']!;
    return basePrompt + text;
  }
}
