import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../mock/mock_data.dart';
import 'receipt_ocr_engine.dart';

class ReceiptItemDraft {
  const ReceiptItemDraft({
    required this.name,
    required this.amount,
    this.suggestedCategoryKey,
    required this.confidence,
    required this.sourceLine,
  });

  final String name;
  final double amount;
  final String? suggestedCategoryKey;
  final double confidence;
  final String sourceLine;

  ReceiptItemDraft copyWith({
    String? name,
    double? amount,
    String? suggestedCategoryKey,
    double? confidence,
    String? sourceLine,
  }) {
    return ReceiptItemDraft(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      suggestedCategoryKey: suggestedCategoryKey ?? this.suggestedCategoryKey,
      confidence: confidence ?? this.confidence,
      sourceLine: sourceLine ?? this.sourceLine,
    );
  }
}

class ReceiptScanResult {
  const ReceiptScanResult({
    this.totalAmount,
    this.date,
    this.suggestedCategoryKey,
    this.items = const <ReceiptItemDraft>[],
    required this.rawText,
    this.debugInfo,
  });

  final double? totalAmount;
  final DateTime? date;
  final String? suggestedCategoryKey;
  final List<ReceiptItemDraft> items;
  final String rawText;
  final ReceiptParseDebugInfo? debugInfo;

  // Compatibility for existing review UI/tests while callers migrate.
  double? get amount => totalAmount;
}

class ReceiptParseDebugInfo {
  const ReceiptParseDebugInfo({
    this.amountCandidates = const <ReceiptAmountCandidateDebug>[],
  });

  final List<ReceiptAmountCandidateDebug> amountCandidates;
}

class ReceiptAmountCandidateDebug {
  const ReceiptAmountCandidateDebug({
    required this.value,
    required this.score,
    required this.confidence,
    required this.lineIndex,
    required this.sourceLine,
    required this.positiveContext,
    required this.negativeContext,
  });

  final double value;
  final double score;
  final double confidence;
  final int lineIndex;
  final String sourceLine;
  final bool positiveContext;
  final bool negativeContext;
}

class ReceiptScannerService {
  ReceiptScannerService({
    ReceiptOcrEngine? primaryOcrEngine,
    ReceiptOcrEngine? fallbackOcrEngine,
    ImagePicker? imagePicker,
  })  : _primaryOcrEngine =
            primaryOcrEngine ?? const TesseractReceiptOcrEngine(),
        _fallbackOcrEngine = fallbackOcrEngine ?? MlKitReceiptOcrEngine(),
        _picker = imagePicker ?? ImagePicker();

  final ReceiptOcrEngine _primaryOcrEngine;
  final ReceiptOcrEngine _fallbackOcrEngine;
  final ImagePicker _picker;

  static ReceiptScanResult parseText(String text) {
    return const ReceiptParsingPipeline().parse(text);
  }

  Future<ReceiptScanResult> scanFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) {
      throw Exception('No image selected');
    }

    final String rawText = await _recognizeText(image.path);

    return parseText(rawText);
  }

  Future<String> _recognizeText(String imagePath) async {
    Object primaryError;
    StackTrace primaryStackTrace;

    try {
      final String text = await _primaryOcrEngine.recognizeText(imagePath);
      if (text.trim().isNotEmpty) {
        return text;
      }
      primaryError = StateError('Primary OCR returned no text');
      primaryStackTrace = StackTrace.current;
    } catch (error, stackTrace) {
      primaryError = error;
      primaryStackTrace = stackTrace;
    }

    if (kDebugMode) {
      debugPrint(
        'Primary receipt OCR failed, falling back to ML Kit: $primaryError',
      );
      debugPrint(primaryStackTrace.toString());
    }

    return _fallbackOcrEngine.recognizeText(imagePath);
  }

  void dispose() {
    _primaryOcrEngine.dispose();
    _fallbackOcrEngine.dispose();
  }
}

class ReceiptParsingPipeline {
  const ReceiptParsingPipeline({
    this.normalizer = const ReceiptTextNormalizer(),
    this.amountParser = const ReceiptAmountParser(),
    this.dateParser = const ReceiptDateParser(),
    this.itemParser = const ReceiptItemParser(),
    this.categoryGuesser = const ReceiptCategoryGuesser(),
  });

  final ReceiptTextNormalizer normalizer;
  final ReceiptAmountParser amountParser;
  final ReceiptDateParser dateParser;
  final ReceiptItemParser itemParser;
  final ReceiptCategoryGuesser categoryGuesser;

  ReceiptScanResult parse(String rawText) {
    final ReceiptText text = normalizer.normalize(rawText);
    final ReceiptAmountParseResult amountResult = amountParser.parse(text);
    final String? overallCategory = categoryGuesser.guess(text.normalizedText);
    final List<ReceiptItemDraft> items = itemParser.parse(
      text,
      totalAmount: amountResult.amount,
      fallbackCategoryKey: overallCategory,
      categoryGuesser: categoryGuesser,
    );

    return ReceiptScanResult(
      totalAmount: amountResult.amount,
      date: dateParser.parse(text),
      suggestedCategoryKey: overallCategory,
      items: items,
      rawText: rawText,
      debugInfo: kDebugMode
          ? ReceiptParseDebugInfo(
              amountCandidates: amountResult.debugCandidates,
            )
          : null,
    );
  }
}

class ReceiptTextNormalizer {
  const ReceiptTextNormalizer();

  ReceiptText normalize(String rawText) {
    final List<String> rawLines = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00a0', ' ')
        .replaceAll('₽', ' руб ')
        .split('\n')
        .map((String line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    return ReceiptText(
      rawText: rawText,
      lines: <ReceiptLine>[
        for (int index = 0; index < rawLines.length; index++)
          ReceiptLine(
            index: index,
            raw: rawLines[index],
            normalized: _normalizeLine(rawLines[index]),
          ),
      ],
    );
  }

  String _normalizeLine(String line) {
    return line
        .replaceAll('ё', 'е')
        .replaceAll('Ё', 'Е')
        .replaceAll('₽', ' руб ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }
}

class ReceiptText {
  const ReceiptText({
    required this.rawText,
    required this.lines,
  });

  final String rawText;
  final List<ReceiptLine> lines;

  String get normalizedText {
    return lines.map((ReceiptLine line) => line.normalized).join('\n');
  }
}

class ReceiptLine {
  const ReceiptLine({
    required this.index,
    required this.raw,
    required this.normalized,
  });

  final int index;
  final String raw;
  final String normalized;
}

class ReceiptAmountParseResult {
  const ReceiptAmountParseResult({
    required this.amount,
    required this.confidence,
    required this.debugCandidates,
  });

  final double? amount;
  final double confidence;
  final List<ReceiptAmountCandidateDebug> debugCandidates;
}

class ReceiptAmountParser {
  const ReceiptAmountParser();

  ReceiptAmountParseResult parse(ReceiptText text) {
    final List<_AmountCandidate> candidates = _collectCandidates(text);
    if (candidates.isEmpty) {
      return const ReceiptAmountParseResult(
        amount: null,
        confidence: 0,
        debugCandidates: <ReceiptAmountCandidateDebug>[],
      );
    }

    final Map<int, int> repetitions = <int, int>{};
    for (final _AmountCandidate candidate in candidates) {
      repetitions.update(candidate.cents, (int count) => count + 1,
          ifAbsent: () => 1);
    }

    final List<_ScoredAmountCandidate> scored = candidates
        .map(
          (_AmountCandidate candidate) => _ScoredAmountCandidate(
            candidate: candidate,
            score: _score(candidate, text, repetitions[candidate.cents] ?? 1),
          ),
        )
        .toList()
      ..sort((_ScoredAmountCandidate a, _ScoredAmountCandidate b) {
        final int scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return b.candidate.value.compareTo(a.candidate.value);
      });

    final List<ReceiptAmountCandidateDebug> debug =
        scored.take(10).map((_ScoredAmountCandidate scoredCandidate) {
      final _AmountCandidate candidate = scoredCandidate.candidate;
      final String context = _window(text.lines, candidate.line.index);
      return ReceiptAmountCandidateDebug(
        value: candidate.value,
        score: scoredCandidate.score,
        confidence: _confidence(scoredCandidate.score),
        lineIndex: candidate.line.index,
        sourceLine: candidate.line.raw,
        positiveContext: ReceiptKeywordMatcher.hasPositiveAmountContext(
          context,
        ),
        negativeContext: ReceiptKeywordMatcher.hasNegativeAmountContext(
          context,
        ),
      );
    }).toList();

    _logDebugCandidates(debug);

    for (final _ScoredAmountCandidate scoredCandidate in scored) {
      final _AmountCandidate candidate = scoredCandidate.candidate;
      final double confidence = _confidence(scoredCandidate.score);
      if (_isReliable(
              scoredCandidate, text, repetitions[candidate.cents] ?? 1) &&
          confidence >= 0.62) {
        return ReceiptAmountParseResult(
          amount: candidate.value,
          confidence: confidence,
          debugCandidates: debug,
        );
      }
    }

    return ReceiptAmountParseResult(
      amount: null,
      confidence: 0,
      debugCandidates: debug,
    );
  }

  List<_AmountCandidate> _collectCandidates(ReceiptText text) {
    final RegExp moneyPattern = RegExp(
      r'(^|[^\d])([=~:\-–—]?\s*(?:\d{1,3}(?:[ \u00a0]\d{3})+|\d{1,6})[,.]\d{1,2})(?!\d)',
    );
    final List<_AmountCandidate> candidates = <_AmountCandidate>[];

    for (final ReceiptLine line in text.lines) {
      for (final RegExpMatch match
          in moneyPattern.allMatches(line.normalized)) {
        final String raw = match.group(2)!;
        final int start = match.start + match.group(1)!.length;
        final int end = start + raw.length;
        if (ReceiptDateParser.looksLikeDatePart(line.normalized, start, end)) {
          continue;
        }

        final _ParsedMoney? parsed = _parseMoney(raw);
        if (parsed == null || parsed.value <= 0 || parsed.value > 1000000) {
          continue;
        }

        candidates.add(
          _AmountCandidate(
            line: line,
            raw: raw,
            value: parsed.value,
            decimalPlaces: parsed.decimalPlaces,
            hasEqualsMarker: raw.contains('=') ||
                line.normalized
                    .substring(math.max(0, start - 2), start)
                    .contains('='),
            start: start,
            end: end,
          ),
        );
      }
    }

    return candidates;
  }

  double _score(
    _AmountCandidate candidate,
    ReceiptText text,
    int repetitionCount,
  ) {
    final List<ReceiptLine> lines = text.lines;
    final String line = candidate.line.normalized;
    final String context = _window(lines, candidate.line.index);
    final bool linePositive =
        ReceiptKeywordMatcher.hasPositiveAmountContext(line);
    final bool contextPositive =
        ReceiptKeywordMatcher.hasPositiveAmountContext(context);
    final bool lineStrong =
        ReceiptKeywordMatcher.hasStrongPositiveAmountContext(line);
    final bool contextStrong =
        ReceiptKeywordMatcher.hasStrongPositiveAmountContext(context);
    final bool lineNegative =
        ReceiptKeywordMatcher.hasNegativeAmountContext(line);
    final bool contextNegative =
        ReceiptKeywordMatcher.hasNegativeAmountContext(context);
    final bool lineItem = ReceiptKeywordMatcher.hasItemContext(line);
    final bool contextItem = ReceiptKeywordMatcher.hasItemContext(context);
    final bool bottom = _position(candidate.line.index, lines.length) >= 0.6;
    final bool nearEnd = _amountNearLineEnd(candidate);

    double score = 0;
    score += candidate.decimalPlaces == 2 ? 25 : 6;
    if (candidate.hasEqualsMarker) {
      score += bottom ? 20 : 10;
    }
    if (nearEnd) {
      score += bottom ? 10 : 4;
    }
    if (lineStrong) {
      score += candidate.hasEqualsMarker ? 48 : 36;
    } else if (linePositive) {
      score += candidate.hasEqualsMarker ? 36 : 24;
    } else if (contextStrong) {
      score += candidate.hasEqualsMarker ? 28 : 16;
    } else if (contextPositive) {
      score += candidate.hasEqualsMarker ? 18 : 8;
    }
    if (bottom) {
      score += 10;
    } else if (_position(candidate.line.index, lines.length) < 0.45) {
      score -= 8;
    }
    if (repetitionCount > 1) {
      score += bottom ? 18 : 8;
    }
    if (lineNegative) {
      score -= 70;
    } else if (contextNegative && !lineStrong) {
      score -= 28;
    }
    if (lineItem && !linePositive && !lineStrong) {
      score -= 34;
    } else if (contextItem && !linePositive && !lineStrong) {
      score -= 16;
    }
    if (candidate.value < 10 && !linePositive && !contextStrong) {
      score -= 18;
    }

    return score;
  }

  bool _isReliable(
    _ScoredAmountCandidate scored,
    ReceiptText text,
    int repetitionCount,
  ) {
    final _AmountCandidate candidate = scored.candidate;
    if (candidate.decimalPlaces != 2) {
      return false;
    }

    final String line = candidate.line.normalized;
    final String context = _window(text.lines, candidate.line.index);
    final bool linePositive =
        ReceiptKeywordMatcher.hasPositiveAmountContext(line);
    final bool lineStrong =
        ReceiptKeywordMatcher.hasStrongPositiveAmountContext(line);
    final bool contextPositive =
        ReceiptKeywordMatcher.hasPositiveAmountContext(context);
    final bool lineNegative =
        ReceiptKeywordMatcher.hasNegativeAmountContext(line);
    final bool lineItem = ReceiptKeywordMatcher.hasItemContext(line);
    final bool contextItem = ReceiptKeywordMatcher.hasItemContext(context);
    final bool bottom =
        _position(candidate.line.index, text.lines.length) >= 0.6;

    if (lineNegative) {
      return false;
    }
    if (lineItem && !linePositive && !lineStrong) {
      return false;
    }
    if (contextItem && !linePositive && !lineStrong) {
      return false;
    }
    if (scored.score < 46) {
      return false;
    }

    return linePositive ||
        contextPositive ||
        (bottom && candidate.hasEqualsMarker && repetitionCount > 1);
  }

  static _ParsedMoney? _parseMoney(String raw) {
    final String normalized =
        raw.replaceAll(RegExp(r'[=\s\u00a0:]'), '').replaceAll(',', '.');
    final String numeric = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
    if (numeric.isEmpty) {
      return null;
    }
    final int dotIndex = numeric.indexOf('.');
    if (dotIndex == -1) {
      return null;
    }
    final double? value = double.tryParse(numeric);
    if (value == null) {
      return null;
    }
    return _ParsedMoney(
      value: _roundMoney(value),
      decimalPlaces: numeric.length - dotIndex - 1,
    );
  }

  static String _window(List<ReceiptLine> lines, int lineIndex) {
    final int start = math.max(0, lineIndex - 1);
    final int end = math.min(lines.length - 1, lineIndex + 1);
    return lines
        .sublist(start, end + 1)
        .map((ReceiptLine line) => line.normalized)
        .join(' ');
  }

  static bool _amountNearLineEnd(_AmountCandidate candidate) {
    final String suffix = candidate.line.normalized.substring(candidate.end);
    return suffix.trim().isEmpty ||
        ReceiptKeywordMatcher.hasCurrencyContext(suffix) ||
        RegExp(r'^[\sруб.,]*$').hasMatch(suffix);
  }

  static double _position(int lineIndex, int lineCount) {
    if (lineCount <= 1) {
      return 0;
    }
    return lineIndex / (lineCount - 1);
  }

  static double _confidence(double score) {
    return (score / 90).clamp(0, 1).toDouble();
  }

  static double _roundMoney(double value) {
    return (value * 100).round() / 100;
  }

  static void _logDebugCandidates(
    List<ReceiptAmountCandidateDebug> candidates,
  ) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('Receipt amount candidates (top ${candidates.length}):');
    for (final ReceiptAmountCandidateDebug candidate in candidates) {
      debugPrint(
        'value=${candidate.value.toStringAsFixed(2)} '
        'score=${candidate.score.toStringAsFixed(1)} '
        'confidence=${candidate.confidence.toStringAsFixed(2)} '
        'line=${candidate.lineIndex} '
        'positive=${candidate.positiveContext} '
        'negative=${candidate.negativeContext} '
        'text="${candidate.sourceLine}"',
      );
    }
  }
}

class ReceiptDateParser {
  const ReceiptDateParser();

  DateTime? parse(ReceiptText text) {
    final String normalized = text.normalizedText
        .replaceAll(RegExp(r'[oо]', caseSensitive: false), '0')
        .replaceAll(RegExp(r'\s+'), ' ');
    final List<RegExp> patterns = <RegExp>[
      RegExp(r'\b(\d{4})\s*[.\/-]\s*(\d{1,2})\s*[.\/-]\s*(\d{1,2})\b'),
      RegExp(
        r'\b(\d{1,2})\s*[.\/-]\s*(\d{1,2})\s*[.\/-]\s*(\d{2}|\d{4})\b',
      ),
    ];

    for (final RegExp pattern in patterns) {
      for (final RegExpMatch match in pattern.allMatches(normalized)) {
        final bool yearFirst = match.group(1)!.length == 4;
        final int year =
            _parseYear(yearFirst ? match.group(1)! : match.group(3)!);
        final int month = int.parse(match.group(2)!);
        final int day =
            int.parse(yearFirst ? match.group(3)! : match.group(1)!);
        final DateTime? date = _validDate(year, month, day);
        if (date != null) {
          return date;
        }
      }
    }

    return null;
  }

  static bool looksLikeDatePart(String line, int start, int end) {
    final String normalized =
        line.replaceAll(RegExp(r'[oо]', caseSensitive: false), '0');
    final List<RegExp> datePatterns = <RegExp>[
      RegExp(r'\b\d{4}\s*[.\/-]\s*\d{1,2}\s*[.\/-]\s*\d{1,2}\b'),
      RegExp(r'\b\d{1,2}\s*[.\/-]\s*\d{1,2}\s*[.\/-]\s*\d{2,4}\b'),
    ];
    for (final RegExp pattern in datePatterns) {
      for (final RegExpMatch match in pattern.allMatches(normalized)) {
        if (start < match.end && end > match.start) {
          return true;
        }
      }
    }

    final bool followedByDateTail = end + 1 < line.length &&
        _isDateSeparator(line[end]) &&
        _isDigit(line[end + 1]);
    final bool precededByDateHead = start >= 2 &&
        _isDateSeparator(line[start - 1]) &&
        _isDigit(line[start - 2]);
    return followedByDateTail || precededByDateHead;
  }

  static int _parseYear(String rawYear) {
    final int year = int.parse(rawYear);
    return rawYear.length == 2 ? 2000 + year : year;
  }

  static DateTime? _validDate(int year, int month, int day) {
    if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1) {
      return null;
    }
    final DateTime date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static bool _isDateSeparator(String value) {
    return value == '.' || value == '/' || value == '-';
  }

  static bool _isDigit(String value) {
    return value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
  }
}

class ReceiptItemParser {
  const ReceiptItemParser();

  List<ReceiptItemDraft> parse(
    ReceiptText text, {
    required double? totalAmount,
    required String? fallbackCategoryKey,
    required ReceiptCategoryGuesser categoryGuesser,
  }) {
    final List<ReceiptItemDraft> items = <ReceiptItemDraft>[];
    final Set<String> seen = <String>{};

    for (int index = 0; index < text.lines.length; index++) {
      final ReceiptLine line = text.lines[index];
      if (!_isItemNameLine(line)) {
        continue;
      }

      final _ParsedItemAmount? amount = _findAmountNear(text.lines, index);
      if (amount == null || _sameMoney(amount.value, totalAmount)) {
        continue;
      }

      final String name = _cleanItemName(
        line.raw,
        amount.lineIndex == index ? amount.start : null,
      );
      if (!_usableName(name)) {
        continue;
      }

      final String key =
          '${_compactForDedupe(name)}:${(amount.value * 100).round()}';
      if (seen.contains(key)) {
        continue;
      }
      seen.add(key);

      final String categoryText = <String>[
        line.normalized,
        if (amount.lineIndex != index) text.lines[amount.lineIndex].normalized,
      ].join(' ');
      final String? suggestedCategoryKey =
          categoryGuesser.guess(categoryText) ?? fallbackCategoryKey;

      items.add(
        ReceiptItemDraft(
          name: name,
          amount: amount.value,
          suggestedCategoryKey:
              MockData.categoryByKey(suggestedCategoryKey) == null
                  ? null
                  : suggestedCategoryKey,
          confidence: amount.confidence,
          sourceLine: line.raw,
        ),
      );
    }

    return items;
  }

  _ParsedItemAmount? _findAmountNear(List<ReceiptLine> lines, int index) {
    final int end = math.min(lines.length - 1, index + 2);
    final List<ReceiptLine> window = lines.sublist(index, end + 1);
    return _explicitLineTotal(window, index) ??
        _computedUnitTotal(window, index) ??
        _plainLineAmount(window, index);
  }

  _ParsedItemAmount? _explicitLineTotal(List<ReceiptLine> lines, int index) {
    final RegExp pattern = RegExp(
      r'(^|[^\d])=\s*((?:\d{1,3}(?:[ \u00a0]\d{3})+|\d{1,6})[,.]\d{1,2})(?!\d)',
    );
    for (final ReceiptLine line in lines) {
      if (line.index != index && _isServiceLine(line.normalized)) {
        continue;
      }
      if (line.index != index && _looksLikeOwnItemAmountLine(line.normalized)) {
        continue;
      }
      if (_hasSeparateProductLineBetween(lines, index, line.index)) {
        continue;
      }
      for (final RegExpMatch match in pattern.allMatches(line.normalized)) {
        final String raw = match.group(2)!;
        final _ParsedMoney? money = ReceiptAmountParser._parseMoney(raw);
        if (money == null || !_realisticItemAmount(money.value)) {
          continue;
        }
        return _ParsedItemAmount(
          value: money.value,
          lineIndex: line.index,
          start: line.normalized.indexOf(raw, match.start),
          confidence: line.index == index ? 0.9 : 0.82,
        );
      }
    }
    return null;
  }

  _ParsedItemAmount? _computedUnitTotal(List<ReceiptLine> lines, int index) {
    final RegExp pattern = RegExp(
      r'(^|[^\d])((?:\d{1,3}(?:[ \u00a0]\d{3})+|\d{1,6})[,.]\d{1,3})\s*[*xх]\s*(\d{1,3}(?:[,.]\d{1,3})?)(?!\d)',
    );
    for (final ReceiptLine line in lines) {
      if (line.index != index && _isServiceLine(line.normalized)) {
        continue;
      }
      if (line.index != index && _looksLikeOwnItemAmountLine(line.normalized)) {
        continue;
      }
      if (_hasSeparateProductLineBetween(lines, index, line.index)) {
        continue;
      }
      for (final RegExpMatch match in pattern.allMatches(line.normalized)) {
        final String unitRaw = match.group(2)!;
        final String quantityRaw = match.group(3)!;
        final _ParsedMoney? unitPrice =
            ReceiptAmountParser._parseMoney(unitRaw);
        final double? quantity =
            double.tryParse(quantityRaw.replaceAll(',', '.'));
        if (unitPrice == null ||
            quantity == null ||
            !_plausibleQuantity(quantityRaw, quantity)) {
          continue;
        }
        final double value = ReceiptAmountParser._roundMoney(
          unitPrice.value * quantity,
        );
        if (!_realisticItemAmount(value)) {
          continue;
        }
        return _ParsedItemAmount(
          value: value,
          lineIndex: line.index,
          start: line.normalized.indexOf(unitRaw, match.start),
          confidence: quantity == 1 ? 0.72 : 0.64,
        );
      }
    }
    return null;
  }

  _ParsedItemAmount? _plainLineAmount(List<ReceiptLine> lines, int index) {
    final RegExp pattern = RegExp(
      r'(^|[^\d])((?:\d{1,3}(?:[ \u00a0]\d{3})+|\d{1,6})[,.]\d{1,2})(?![\d%a-zа-я])',
    );
    for (final ReceiptLine line in lines) {
      if (line.index != index && _isServiceLine(line.normalized)) {
        continue;
      }
      if (line.index != index && _looksLikeOwnItemAmountLine(line.normalized)) {
        continue;
      }
      if (_hasSeparateProductLineBetween(lines, index, line.index)) {
        continue;
      }
      final List<RegExpMatch> matches =
          pattern.allMatches(line.normalized).toList();
      for (final RegExpMatch match in matches.reversed) {
        final String raw = match.group(2)!;
        final _ParsedMoney? money = ReceiptAmountParser._parseMoney(raw);
        if (money == null ||
            money.value < 5 ||
            !_realisticItemAmount(money.value)) {
          continue;
        }
        final int start = line.normalized.indexOf(raw, match.start);
        if (!_plainAmountLooksLikeItem(line.normalized, start, raw)) {
          continue;
        }
        return _ParsedItemAmount(
          value: money.value,
          lineIndex: line.index,
          start: start,
          confidence: line.index == index ? 0.58 : 0.52,
        );
      }
    }
    return null;
  }

  bool _isItemNameLine(ReceiptLine line) {
    if (_isServiceLine(line.normalized) ||
        _isStandaloneAmountLine(line.normalized)) {
      return false;
    }
    final int letters = RegExp(r'[a-zа-я]').allMatches(line.normalized).length;
    if (letters < 2) {
      return false;
    }
    final int digits = RegExp(r'\d').allMatches(line.normalized).length;
    return !(digits >= 12 && letters < 5);
  }

  bool _isServiceLine(String line) {
    return ReceiptKeywordMatcher.hasPositiveAmountContext(line) ||
        ReceiptKeywordMatcher.hasNegativeAmountContext(line) ||
        RegExp(r'https?://|www\.|\.ru\b|\.com\b|@|qr').hasMatch(line);
  }

  bool _looksLikeOwnItemAmountLine(String line) {
    final int letters = RegExp(r'[a-zа-я]').allMatches(line).length;
    if (letters < 2 || !RegExp(r'\d+[,.]\d').hasMatch(line)) {
      return false;
    }
    return ReceiptKeywordMatcher.hasItemContext(line) ||
        RegExp(r'^\d{1,3}\s+').hasMatch(line);
  }

  bool _isStandaloneAmountLine(String line) {
    return RegExp(
      r'^\s*[=~:\-–—]?\s*\d{1,6}[,.]\d{1,2}\s*(руб\.?|rur|rub|\$|usd|eur)?\s*$',
    ).hasMatch(line);
  }

  bool _hasSeparateProductLineBetween(
    List<ReceiptLine> lines,
    int itemLineIndex,
    int amountLineIndex,
  ) {
    if (amountLineIndex <= itemLineIndex + 1) {
      return false;
    }
    for (final ReceiptLine line in lines) {
      if (line.index <= itemLineIndex || line.index >= amountLineIndex) {
        continue;
      }
      if (RegExp(r'[a-zа-я]').allMatches(line.normalized).length > 3) {
        return true;
      }
    }
    return false;
  }

  bool _plainAmountLooksLikeItem(String line, int start, String rawAmount) {
    if (start < 0) {
      return false;
    }
    final String suffix = line.substring(start + rawAmount.length).trim();
    final String prefix = line.substring(0, start).trim();
    return (prefix.isEmpty && suffix.isEmpty) ||
        suffix.isEmpty ||
        ReceiptKeywordMatcher.hasCurrencyContext(suffix);
  }

  String _cleanItemName(String rawLine, int? amountStart) {
    final String original = rawLine.trim();
    String name = rawLine;
    if (amountStart != null && amountStart > 0 && amountStart <= name.length) {
      name = name.substring(0, amountStart);
    }
    name = name
        .replaceAll(
            RegExp(r'\d{1,6}[,.]\d{1,3}\s*[*xх]\s*\d{1,3}(?:[,.]\d{1,3})?'),
            ' ')
        .replaceAll(RegExp(r'=\s*\d{1,6}[,.]\d{1,2}'), ' ')
        .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final List<String> tokens = name
        .split(' ')
        .where((String token) => token.trim().isNotEmpty)
        .toList();
    while (tokens.length > 1 && _dropLeadingToken(tokens.first)) {
      tokens.removeAt(0);
    }
    final String cleaned = _trimPunctuation(tokens.join(' '));
    return cleaned.isEmpty ? original : cleaned;
  }

  bool _dropLeadingToken(String token) {
    final String cleaned =
        token.toLowerCase().replaceAll(RegExp(r'[\[\]().,:;№#+-]+'), '');
    return cleaned.isEmpty ||
        <String>{'шт', 'кг', 'гр', 'г', 'pcs', 'kg'}.contains(cleaned) ||
        RegExp(r'^\d{1,3}$').hasMatch(cleaned) ||
        RegExp(r'^\d{4,14}$').hasMatch(cleaned) ||
        RegExp(r'^[a-zа-я]*\d{3,14}$').hasMatch(cleaned);
  }

  String _trimPunctuation(String value) {
    return value
        .replaceAll(RegExp(r'^[^a-zA-Zа-яА-Я0-9]+|[^a-zA-Zа-яА-Я0-9%]+$'), '')
        .trim();
  }

  bool _usableName(String name) {
    return RegExp(r'[a-zа-яA-ZА-Я]').allMatches(name).length >= 2 &&
        !_isServiceLine(name.toLowerCase());
  }

  String _compactForDedupe(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
  }

  bool _plausibleQuantity(String raw, double quantity) {
    if (quantity <= 0 || quantity > 100) {
      return false;
    }
    final String normalized = raw.replaceAll(',', '.');
    final int dot = normalized.indexOf('.');
    if (dot == -1) {
      return true;
    }
    final int decimalPlaces = normalized.length - dot - 1;
    if (decimalPlaces > 3) {
      return false;
    }
    if (decimalPlaces == 3 && quantity > 5) {
      return false;
    }
    return quantity <= 20;
  }

  bool _realisticItemAmount(double value) {
    return value >= 0.01 && value <= 100000;
  }

  bool _sameMoney(double value, double? other) {
    return other != null && (value * 100).round() == (other * 100).round();
  }
}

class ReceiptCategoryGuesser {
  const ReceiptCategoryGuesser();

  String? guess(String text) {
    final Map<String, List<String>> keywords = <String, List<String>>{
      'food': <String>[
        'продукт',
        'супермаркет',
        'гипермаркет',
        'магазин',
        'молоко',
        'молоч',
        'хлеб',
        'картоф',
        'сыр',
        'яйц',
        'мясо',
        'фарш',
        'рыба',
        'рис',
        'яблок',
        'морков',
        'лук',
        'масло',
        'сок',
        'вода',
        'напит',
        'водка',
        'петруш',
        'кинз',
        'банан',
        'лимон',
        'перец',
        'хумус',
        'кукуруз',
        'сливк',
        'халва',
        'вафл',
        'батон',
        'сгущ',
        'чипс',
        'овощ',
        'фрукт',
        'пятерочка',
        'магнит',
        'дикси',
        'ашан',
        'лента',
        'перекресток',
        'самбери',
        'food',
        'grocery',
        'supermarket',
        'market',
        'milk',
        'bread',
        'egg',
        'moloko',
        'hleb',
        'xleb',
        'kartof',
        'produkt',
        'magnit',
      ],
      'transport': <String>[
        'такси',
        'метро',
        'автобус',
        'бензин',
        'азс',
        'заправ',
        'taxi',
        'transport',
        'fuel',
        'gas',
        'parking',
      ],
      'health': <String>[
        'аптека',
        'фармац',
        'клиник',
        'больниц',
        'медицин',
        'pharmacy',
        'clinic',
        'hospital',
        'medical',
      ],
      'entertainment': <String>[
        'кино',
        'театр',
        'концерт',
        'музей',
        'cinema',
        'theatre',
        'concert',
        'museum',
      ],
      'communication': <String>[
        'мтс',
        'билайн',
        'мегафон',
        'теле2',
        'интернет',
        'телефон',
        'mobile',
        'internet',
        'phone',
      ],
      'clothing': <String>[
        'одежда',
        'обувь',
        'zara',
        'adidas',
        'nike',
        'clothing',
        'shoes',
        'fashion',
      ],
      'housing': <String>[
        'жкх',
        'коммунальн',
        'аренда',
        'квартплат',
        'rent',
        'utilities',
        'electricity',
      ],
      'sport': <String>[
        'фитнес',
        'спортзал',
        'спорт',
        'fitness',
        'gym',
        'sport',
      ],
    };

    int bestScore = 0;
    String? bestKey;
    for (final MapEntry<String, List<String>> entry in keywords.entries) {
      int score = 0;
      for (final String keyword in entry.value) {
        if (ReceiptKeywordMatcher.containsKeyword(text, keyword)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestKey = entry.key;
      }
    }

    return MockData.categoryByKey(bestKey) == null ? null : bestKey;
  }
}

class ReceiptKeywordMatcher {
  const ReceiptKeywordMatcher._();

  static bool hasPositiveAmountContext(String text) {
    return _containsAny(text, _positiveKeywords) ||
        _containsNoisyTotal(text) ||
        _containsNoisyPayment(text);
  }

  static bool hasStrongPositiveAmountContext(String text) {
    return _containsAny(text, _strongPositiveKeywords) ||
        (_containsNoisyTotal(text) && _containsNoisyPayment(text));
  }

  static bool hasNegativeAmountContext(String text) {
    return _containsAny(text, _negativeKeywords);
  }

  static bool hasCurrencyContext(String text) {
    return _containsAny(text, _currencyKeywords);
  }

  static bool hasItemContext(String text) {
    final String normalized = text
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return RegExp(r'[*xх]\s*\d').hasMatch(normalized) ||
        RegExp(r'\d[,.]\d{1,3}\s*[*xх]').hasMatch(normalized) ||
        RegExp(r'(^|\s)(шт|кг|гр|г|pcs|kg|x)\b').hasMatch(normalized);
  }

  static bool containsKeyword(String text, String keyword) {
    final String normalized = _normalizeForKeyword(text);
    final String folded = _foldLookalikes(normalized);
    final String compact = normalized.replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
    final String foldedCompact =
        folded.replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
    final String normalizedKeyword = _normalizeForKeyword(keyword);
    final String foldedKeyword = _foldLookalikes(normalizedKeyword);
    final String compactKeyword =
        normalizedKeyword.replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
    final String foldedCompactKeyword =
        foldedKeyword.replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');

    return normalized.contains(normalizedKeyword) ||
        folded.contains(foldedKeyword) ||
        (compactKeyword.isNotEmpty && compact.contains(compactKeyword)) ||
        (foldedCompactKeyword.isNotEmpty &&
            foldedCompact.contains(foldedCompactKeyword));
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final String keyword in keywords) {
      if (containsKeyword(text, keyword)) {
        return true;
      }
    }
    return false;
  }

  static bool _containsNoisyTotal(String text) {
    final String compact = _noisyCompact(text).replaceAll('g', 'г');
    return <String>[
      'итог',
      'итого',
      'мтог',
      'мтого',
      'itog',
      'itogo',
      'mtog',
      'mtogo',
    ].any(compact.contains);
  }

  static bool _containsNoisyPayment(String text) {
    final String compact = _noisyCompact(text);
    return <String>['оплат', 'oplata', 'oplate'].any(compact.contains);
  }

  static String _noisyCompact(String text) {
    return _foldLookalikes(_normalizeForKeyword(text))
        .replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
  }

  static String _normalizeForKeyword(String text) {
    return text
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll('0', 'о')
        .replaceAll('1', 'и')
        .replaceAll('3', 'з')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _foldLookalikes(String text) {
    const Map<String, String> replacements = <String, String>{
      'a': 'а',
      'b': 'в',
      'c': 'с',
      'd': 'д',
      'e': 'е',
      'h': 'н',
      'i': 'и',
      'k': 'к',
      'm': 'м',
      'o': 'о',
      'p': 'р',
      'r': 'г',
      't': 'т',
      'x': 'х',
      'y': 'у',
    };

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(replacements[text[i]] ?? text[i]);
    }
    return buffer.toString();
  }

  static const List<String> _positiveKeywords = <String>[
    'итого',
    'итог',
    'итого к оплате',
    'к оплате',
    'оплате',
    'всего',
    'сумма к оплате',
    'оплачено',
    'безналичными',
    'наличными',
    'картой',
    'total',
    'paid',
    'to pay',
    'amount due',
  ];

  static const List<String> _strongPositiveKeywords = <String>[
    'итого',
    'итого к оплате',
    'к оплате',
    'сумма к оплате',
    'оплачено',
    'безналичными',
    'наличными',
    'картой',
    'total',
    'paid',
    'to pay',
    'amount due',
  ];

  static const List<String> _negativeKeywords = <String>[
    'ндс',
    'сумма ндс',
    'vat',
    'tax',
    'скидка',
    'скидки',
    'discount',
    'экономия',
    'эконом',
    'сдача',
    'change',
    'налог',
    'nalog',
    'фн',
    'фд',
    'фп',
    'инн',
    'ккт',
    'касса',
    'кассир',
    'чек',
    'receipt no',
    'qr',
    'сайт',
    'тел',
    'телефон',
    'смена',
    'офд',
    'ofd',
  ];

  static const List<String> _currencyKeywords = <String>[
    'руб',
    'руб.',
    'рубль',
    'рублей',
    'rur',
    'rub',
    '\$',
    'usd',
    'eur',
  ];
}

class _AmountCandidate {
  const _AmountCandidate({
    required this.line,
    required this.raw,
    required this.value,
    required this.decimalPlaces,
    required this.hasEqualsMarker,
    required this.start,
    required this.end,
  });

  final ReceiptLine line;
  final String raw;
  final double value;
  final int decimalPlaces;
  final bool hasEqualsMarker;
  final int start;
  final int end;

  int get cents => (value * 100).round();
}

class _ScoredAmountCandidate {
  const _ScoredAmountCandidate({
    required this.candidate,
    required this.score,
  });

  final _AmountCandidate candidate;
  final double score;
}

class _ParsedMoney {
  const _ParsedMoney({
    required this.value,
    required this.decimalPlaces,
  });

  final double value;
  final int decimalPlaces;
}

class _ParsedItemAmount {
  const _ParsedItemAmount({
    required this.value,
    required this.lineIndex,
    required this.start,
    required this.confidence,
  });

  final double value;
  final int lineIndex;
  final int start;
  final double confidence;
}
