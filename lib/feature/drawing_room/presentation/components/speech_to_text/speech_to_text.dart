import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'speech_to_text_viewmodel.dart';

class SpeechToTextAlert extends StatelessWidget {
  final void Function(String) onpressed;
  const SpeechToTextAlert({super.key, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextViewmodel>.value(
      value: SpeechToTextViewmodel(),
      child: Consumer<SpeechToTextViewmodel>(
        builder:
            (context, model, _) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.record_voice_over,
                                  color: Colors.blue.shade700,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Speech to Drawing',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      'Speak and watch your words come to life',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Speech visualization
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Microphone animation container
                                GestureDetector(
                                  onTap: () {
                                    if (model.speechToText.isListening) {
                                      model.stopListening();
                                    } else {
                                      model.startListening();
                                    }
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          model.speechToText.isListening
                                              ? Colors.red.shade100
                                              : Colors.grey.shade100,
                                      border: Border.all(
                                        color:
                                            model.speechToText.isListening
                                                ? Colors.red.shade300
                                                : Colors.grey.shade300,
                                        width: 3,
                                      ),
                                    ),
                                    child:
                                        model.speechToText.isListening
                                            ? AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              child: Icon(
                                                Icons.mic,
                                                size: 36,
                                                color: Colors.red.shade600,
                                              ),
                                            )
                                            : Icon(
                                              Icons.mic_off,
                                              size: 36,
                                              color: Colors.grey.shade500,
                                            ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Status text
                                Text(
                                  model.speechToText.isListening
                                      ? 'Listening...'
                                      : 'Tap microphone to start',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        model.speechToText.isListening
                                            ? Colors.red.shade600
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (model.recognizedText.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.text_fields,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recognized Text:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (model.recognizedText.isNotEmpty)
                                        GestureDetector(
                                          onTap:
                                              () => model.clearRecognizedText(),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.clear,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      model.recognizedText.isNotEmpty
                                          ? model.recognizedText
                                          : 'No speech recognized yet...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            model.recognizedText.isNotEmpty
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade500,
                                        fontStyle:
                                            model.recognizedText.isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 32),

                          // Action buttons
                          Row(
                            children: [
                              // Microphone toggle button
                              const SizedBox(width: 12),

                              // Draw button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      model.recognizedText.isNotEmpty
                                          ? () {
                                            onpressed(model.recognizedText);
                                          }
                                          : null,
                                  icon: const Icon(Icons.auto_awesome),
                                  label: const Text('Generate '),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade400,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
