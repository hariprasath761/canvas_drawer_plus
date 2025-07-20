import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextViewmodel extends ChangeNotifier {
  String _recognizedText = '';

  String get recognizedText => _recognizedText;

  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;

  SpeechToTextViewmodel() {
    _initSpeech();
  }

  void _initSpeech() async {
    speechEnabled = await speechToText.initialize();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _recognizedText = result.recognizedWords;
    notifyListeners();
  }

  void startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    notifyListeners();
  }

  void stopListening() async {
    await speechToText.stop();
    notifyListeners();
  }

  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }
}
