class ReceiptItem {
  final String name;
  final String? price;

  const ReceiptItem({
    required this.name,
    this.price,
  });

  bool get isEmpty => name.trim().isEmpty && (price?.trim().isEmpty ?? true);

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };

  factory ReceiptItem.fromMap(Map<String, dynamic> map) => ReceiptItem(
        name: (map['name'] as String?) ?? '',
        price: map['price'] as String?,
      );
}
