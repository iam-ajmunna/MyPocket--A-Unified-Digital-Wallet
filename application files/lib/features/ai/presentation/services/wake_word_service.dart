import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WakeWordService {
  static final WakeWordService _instance = WakeWordService._internal();
  factory WakeWordService() => _instance;
  WakeWordService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  VoidCallback? _onWakeWordCallback;

  bool get isListening => _isListening;

  /// Start background wake-word listener for "Hey Moon"
  Future<bool> startListeningForWakeWord({required VoidCallback onWakeWordDetected}) async {
    _onWakeWordCallback = onWakeWordDetected;
    bool available = await _speech.initialize(
      onError: (val) {
        if (_isListening) _restartListening();
      },
      onStatus: (val) {
        if (val == 'done' && _isListening) {
          _restartListening();
        }
      },
    );

    if (available) {
      _isListening = true;
      _listenLoop();
      return true;
    }
    return false;
  }

  void _listenLoop() {
    if (!_isListening) return;
    _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase();
        if (words.contains('hey moon') || words.contains('hay moon') || words.contains('hi moon') || words.contains('moon')) {
          _onWakeWordCallback?.call();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
    );
  }

  void _restartListening() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isListening) {
        _listenLoop();
      }
    });
  }

  /// Stop wake word listener
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }
}
