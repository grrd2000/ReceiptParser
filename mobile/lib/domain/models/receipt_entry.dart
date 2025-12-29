class ReceiptEntry {
  final int? id;
  final String? merchant;
  final String? date;
  final String? total;
  final String? imagePath;
  final List<String> ocrLines;
  final DateTime createdAt;

  const ReceiptEntry({
    this.id,
    this.merchant,
    this.date,
    this.total,
    this.imagePath,
    required this.ocrLines,
    required this.createdAt,
  });

  ReceiptEntry copyWith({
    int? id,
    String? merchant,
    String? date,
    String? total,
    String? imagePath,
    List<String>? ocrLines,
    DateTime? createdAt,
  }) {
    return ReceiptEntry(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
      imagePath: imagePath ?? this.imagePath,
      ocrLines: ocrLines ?? this.ocrLines,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
