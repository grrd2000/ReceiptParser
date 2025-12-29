import 'package:receipt_parser/domain/models/receipt_draft.dart';

class ReceiptBasicParser {
  ReceiptDraft parse(List<String> lines) {
    final merchant = _findMerchant(lines);
    final date = _findDate(lines);
    final total = _findTotal(lines);

    return ReceiptDraft(
      merchant: merchant,
      date: date,
      total: total,
    );
  }

  String? _findMerchant(List<String> lines) {
    for (final l in lines.take(8)) {
      final s = l.trim();
      if (s.isEmpty) continue;

      final upper = s.toUpperCase();
      final looksLikeJustNumbers = RegExp(r'^[\d\W]+$').hasMatch(s);

      if (looksLikeJustNumbers) continue;
      if (upper.contains('PARAGON')) continue;
      if (upper.contains('FISKAL')) continue;

      return s;
    }
    return null;
  }

  String? _findDate(List<String> lines) {
    final dateRegexes = <RegExp>[
      RegExp(r'\b(\d{2})[./-](\d{2})[./-](\d{4})\b'), // 29.12.2025
      RegExp(r'\b(\d{4})[./-](\d{2})[./-](\d{2})\b'), // 2025-12-29
    ];

    for (final l in lines) {
      for (final re in dateRegexes) {
        final m = re.firstMatch(l);
        if (m != null) return m.group(0);
      }
    }
    return null;
  }

  String? _findTotal(List<String> lines) {
    final keywords = ['SUMA', 'TOTAL', 'DO ZAPŁATY', 'RAZEM', 'KWOTA'];
    final amountRe = RegExp(r'(\d+[.,]\d{2})');

    for (final l in lines) {
      final upper = l.toUpperCase();
      if (!keywords.any(upper.contains)) continue;

      final matches = amountRe.allMatches(l).toList();
      if (matches.isNotEmpty) return matches.last.group(1);
    }

    // fallback: ostatnia kwota w całym tekście
    for (final l in lines.reversed) {
      final matches = amountRe.allMatches(l).toList();
      if (matches.isNotEmpty) return matches.last.group(1);
    }

    return null;
  }
}
