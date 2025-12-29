import 'package:flutter/material.dart';
import 'package:receipt_parser/data/receipt_database.dart';
import 'package:receipt_parser/domain/models/receipt_entry.dart';
import 'package:receipt_parser/domain/models/receipt_item.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen>
    with SingleTickerProviderStateMixin {
  final _merchantCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_ItemControllers> _itemCtrls = [_ItemControllers()];
  final ValueNotifier<double> _totalValueNotifier = ValueNotifier(0);

  late final AnimationController _addButtonController;
  late final Animation<double> _addButtonScale;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _addButtonScale = CurvedAnimation(
      parent: _addButtonController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    _updateTotalFromItems();
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _dateCtrl.dispose();
    _totalCtrl.dispose();
    _notesCtrl.dispose();
    _addButtonController.dispose();
    _totalValueNotifier.dispose();
    for (final c in _itemCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final merchant = _merchantCtrl.text.trim();
    final date = _dateCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final items = _buildItems();
    final total = _updateTotalFromItems();

    if (merchant.isEmpty && date.isEmpty && notes.isEmpty && items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uzupełnij przynajmniej jedno pole, aby zapisać.'),
        ),
      );
      return;
    }

    final ocrLines = [
      ...items.map(
        (i) => i.price == null || i.price!.isEmpty
            ? i.name
            : '${i.name} - ${i.price}',
      ),
      ...notes
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList(),
    ];

    setState(() => _saving = true);
    try {
      final entry = ReceiptEntry(
        merchant: merchant.isEmpty ? null : merchant,
        date: date.isEmpty ? null : date,
        total: total.isEmpty ? null : total,
        imagePath: null,
        items: items,
        ocrLines: ocrLines,
        createdAt: DateTime.now(),
        isManual: true,
      );

      await ReceiptDatabase.instance.insertReceipt(entry);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paragon dodany ręcznie do historii.')),
      );
      _merchantCtrl.clear();
      _dateCtrl.clear();
      _notesCtrl.clear();
      setState(() {
        for (final item in _itemCtrls) {
          item.dispose();
        }
        _itemCtrls
          ..clear()
          ..add(_ItemControllers());
      });
      _totalCtrl.clear();
      _totalValueNotifier.value = 0;
      _updateTotalFromItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<ReceiptItem> _buildItems() {
    return _itemCtrls
        .map(
          (c) => ReceiptItem(
            name: c.nameCtrl.text.trim(),
            price: c.priceCtrl.text.trim().isEmpty
                ? null
                : c.priceCtrl.text.trim(),
          ),
        )
        .where((item) => !item.isEmpty)
        .toList();
  }

  String _updateTotalFromItems() {
    double runningTotal = 0;
    for (final ctrl in _itemCtrls) {
      final parsed = _parsePrice(ctrl.priceCtrl.text);
      if (parsed != null) {
        runningTotal += parsed;
      }
    }

    _totalValueNotifier.value = runningTotal;
    final formatted = _formatCurrency(runningTotal);
    if (_totalCtrl.text != formatted) {
      _totalCtrl.value = _totalCtrl.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return formatted;
  }

  double? _parsePrice(String raw) {
    final sanitized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (sanitized.isEmpty) return null;
    return double.tryParse(sanitized);
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _addItemRow() {
    setState(() {
      _itemCtrls.add(_ItemControllers());
    });
    _updateTotalFromItems();
  }

  void _removeItemRow(int index) {
    if (_itemCtrls.length == 1) return;
    setState(() {
      final removed = _itemCtrls.removeAt(index);
      removed.dispose();
    });
    _updateTotalFromItems();
  }

  void _handleAddItem() {
    _addButtonController.forward(from: 0).then((_) => _addButtonController.reverse());
    _addItemRow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj paragon ręcznie'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.edit_note,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ręczne dodawanie',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Wpisz dane paragonu samodzielnie. Trafi on do historii z oznaczeniem ręcznym.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dane paragonu',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: 'Sklep / merchant',
                        controller: _merchantCtrl,
                        hint: 'np. Market 24/7',
                      ),
                      const SizedBox(height: 12),
                      _LabeledField(
                        label: 'Data',
                        controller: _dateCtrl,
                        hint: 'DD.MM.RRRR',
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pozycje z paragonu',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          ScaleTransition(
                            scale: _addButtonScale,
                            child: IconButton.filledTonal(
                              onPressed: _saving ? null : _handleAddItem,
                              icon: const Icon(Icons.add),
                              tooltip: 'Dodaj pozycję',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(_itemCtrls.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == _itemCtrls.length - 1 ? 0 : 10),
                          child: _ItemRow(
                            nameCtrl: _itemCtrls[i].nameCtrl,
                            priceCtrl: _itemCtrls[i].priceCtrl,
                            onRemove:
                                _itemCtrls.length == 1 || _saving ? null : () => _removeItemRow(i),
                            onPriceChanged: _updateTotalFromItems,
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<double>(
                        valueListenable: _totalValueNotifier,
                        builder: (context, total, _) {
                          final displayed = _formatCurrency(total);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Kwota total',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(width: 10),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                    child: Container(
                                      key: ValueKey(displayed),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$displayed PLN',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _totalCtrl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'np. 123,45',
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'PLN',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minHeight: 0,
                                    minWidth: 0,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: 'Uwagi (opcjonalne)',
                        controller: _notesCtrl,
                        hint: 'Każda linia zostanie zapisana osobno',
                        maxLines: 4,
                        minLines: 3,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Zapisywanie...' : 'Zapisz'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemControllers {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;

  _ItemControllers()
      : nameCtrl = TextEditingController(),
        priceCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _ItemRow extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final VoidCallback? onRemove;
  final VoidCallback? onPriceChanged;

  const _ItemRow({
    required this.nameCtrl,
    required this.priceCtrl,
    this.onRemove,
    this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nazwa produktu',
              hintText: 'np. Chleb',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextField(
            controller: priceCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cena',
              hintText: 'np. 12,34',
              suffixText: 'PLN',
            ),
            onChanged: (_) => onPriceChanged?.call(),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close),
          tooltip: 'Usuń pozycję',
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines,
    this.minLines,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix,
                  ),
            suffixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
          ),
        ),
      ],
    );
  }
}
