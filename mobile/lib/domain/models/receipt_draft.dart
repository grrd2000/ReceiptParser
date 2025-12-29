class ReceiptDraft {
  final String? merchant;
  final String? date;
  final String? total;

  const ReceiptDraft({
    this.merchant,
    this.date,
    this.total,
  });

  ReceiptDraft copyWith({String? merchant, String? date, String? total}) {
    return ReceiptDraft(
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
    );
  }
}
