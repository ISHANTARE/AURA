import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Thrown when OCR could not run at all (unreadable file, missing plugin, …)
/// — distinct from "image contains no text".
class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => message;
}

class OcrDataSource {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract text from an image file path using Google ML Kit on-device OCR.
  ///
  /// Returns '' for images with no recognizable text; throws [OcrException]
  /// when OCR itself failed so the caller can surface the difference.
  Future<String> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      throw OcrException('Could not read text from this image ($e)');
    } finally {
      // One-shot usage per share — close the recognizer so it cannot leak.
      dispose();
    }
  }

  void dispose() {
    try {
      _textRecognizer.close();
    } catch (_) {
      // Already closed / not yet initialized — nothing to do.
    }
  }
}
