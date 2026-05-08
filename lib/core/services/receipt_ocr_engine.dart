import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

abstract class ReceiptOcrEngine {
  const ReceiptOcrEngine();

  Future<String> recognizeText(String imagePath);

  void dispose() {}
}

class MlKitReceiptOcrEngine extends ReceiptOcrEngine {
  MlKitReceiptOcrEngine()
      : _textRecognizer = TextRecognizer(
          script: TextRecognitionScript.latin,
        );

  final TextRecognizer _textRecognizer;

  @override
  Future<String> recognizeText(String imagePath) async {
    // ML Kit is fast and works offline, but in this app's receipt-scanning
    // tests it has been weak on noisy Cyrillic retail text. Keep it as a
    // reliable fallback for totals/dates when Tesseract is unavailable.
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognized =
        await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

class TesseractReceiptOcrEngine extends ReceiptOcrEngine {
  const TesseractReceiptOcrEngine({
    this.language = 'rus+eng',
  });

  final String language;

  @override
  Future<String> recognizeText(String imagePath) async {
    // Tesseract with rus traineddata is slower than ML Kit, but is better
    // suited for Russian Cyrillic receipts. This layer only extracts raw text;
    // ReceiptParsingPipeline still owns total/date/item/category parsing.
    await _ensureLanguageAssets();
    return TesseractOcr.extractText(
      imagePath,
      config: OCRConfig(
        language: language,
        engine: OCREngine.tesseract,
      ),
    );
  }

  Future<void> _ensureLanguageAssets() async {
    final List<String> missing = <String>[];
    for (final String code in language.split('+')) {
      final String normalizedCode = code.trim();
      if (normalizedCode.isEmpty) {
        continue;
      }
      final String assetPath = 'assets/tessdata/$normalizedCode.traineddata';
      try {
        final ByteData data = await rootBundle.load(assetPath);
        if (data.lengthInBytes == 0) {
          missing.add(assetPath);
        }
      } on FlutterError {
        missing.add(assetPath);
      }
    }

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing Tesseract traineddata assets: ${missing.join(', ')}. '
        'Add rus.traineddata and eng.traineddata to assets/tessdata/ '
        'to enable Cyrillic OCR.',
      );
    }
  }
}
