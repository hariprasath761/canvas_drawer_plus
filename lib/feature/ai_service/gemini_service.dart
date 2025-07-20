import 'package:canvas_drawer_plus/env/env.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  static void init() {
    Gemini.init(apiKey: Env.geminiAPIKey);
  }

  static Future<String?> sendTextMessage({required String message}) async {
    try {
      final geminiInstance = Gemini.instance;
      await geminiInstance
          .prompt(parts: [Part.text(message)])
          .then((value) {
            return value?.output;
          })
          .catchError((e) {
            throw GeminiException('Failed to send text message: $e');
          });
    } catch (e) {
      throw GeminiException('Failed to send text message: $e');
    }
    return null;
  }
}
