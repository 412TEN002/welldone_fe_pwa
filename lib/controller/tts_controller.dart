import 'package:flutter_tts/flutter_tts.dart';

class TTSController {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  void stop() {
    _flutterTts.stop();
  }
}
