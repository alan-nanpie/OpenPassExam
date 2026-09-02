class TtsVoiceService {
  bool _isPlaying = false;
  String _currentText = '';

  bool get isPlaying => _isPlaying;
  String get currentText => _currentText;

  Future<void> speak(String text) async {
    _isPlaying = true;
    _currentText = text;
  }

  Future<void> pause() async {
    _isPlaying = false;
  }

  Future<void> stop() async {
    _isPlaying = false;
    _currentText = '';
  }
}
