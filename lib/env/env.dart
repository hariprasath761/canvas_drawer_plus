import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GEMINI_API_KEY')
  static const String geminiAPIKey = _Env.geminiAPIKey;

  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static const String openRouterAPIKey = _Env.openRouterAPIKey;

  @EnviedField(varName: 'HUGGING_FACE_API_KEY')
  static const String huggingFaceAPIKey = _Env.huggingFaceAPIKey;
}
