import 'receipt_item.dart';

class ReceiptEntry {
  final int? id;
  final String? merchant;
  final String? date;
  final String? total;
  final String? imagePath;
  final List<ReceiptItem> items;
  final List<String> ocrLines;
  final DateTime createdAt;
  final bool isManual;

  const ReceiptEntry({
    this.id,
    this.merchant,
    this.date,
    this.total,
    this.imagePath,
    this.items = const [],
    required this.ocrLines,
    required this.createdAt,
    this.isManual = false,
  });

  ReceiptEntry copyWith({
    int? id,
    String? merchant,
    String? date,
    String? total,
    String? imagePath,
    List<ReceiptItem>? items,
    List<String>? ocrLines,
    DateTime? createdAt,
    bool? isManual,
  }) {
    return ReceiptEntry(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
      imagePath: imagePath ?? this.imagePath,
      items: items ?? this.items,
      ocrLines: ocrLines ?? this.ocrLines,
      createdAt: createdAt ?? this.createdAt,
      isManual: isManual ?? this.isManual,
    );
  }
}
