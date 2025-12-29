import 'package:flutter/material.dart';
import 'package:receipt_parser/data/receipt_database.dart';
import 'package:receipt_parser/domain/models/receipt_entry.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _merchantCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _dateCtrl.dispose();
    _totalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final merchant = _merchantCtrl.text.trim();
    final date = _dateCtrl.text.trim();
    final total = _totalCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (merchant.isEmpty && date.isEmpty && total.isEmpty && notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uzupełnij przynajmniej jedno pole, aby zapisać.'),
        ),
      );
      return;
    }

    final ocrLines = notes
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    setState(() => _saving = true);
    try {
      final entry = ReceiptEntry(
        merchant: merchant.isEmpty ? null : merchant,
        date: date.isEmpty ? null : date,
        total: total.isEmpty ? null : total,
        imagePath: null,
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
      _totalCtrl.clear();
      _notesCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                      _LabeledField(
                        label: 'Kwota total',
                        controller: _totalCtrl,
                        hint: 'np. 123,45',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        suffix: Container(
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
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: 'Pozycje / uwagi (opcjonalne)',
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
