import 'package:flutter/material.dart';
import 'package:receipt_parser/domain/models/receipt_draft.dart';

class ReceiptEditScreen extends StatefulWidget {
  final ReceiptDraft draft;
  final List<String> ocrLines;

  const ReceiptEditScreen({
    super.key,
    required this.draft,
    required this.ocrLines,
  });

  @override
  State<ReceiptEditScreen> createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends State<ReceiptEditScreen> {
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _totalCtrl;

  @override
  void initState() {
    super.initState();
    _merchantCtrl = TextEditingController(text: widget.draft.merchant ?? '');
    _dateCtrl = TextEditingController(text: widget.draft.date ?? '');
    _totalCtrl = TextEditingController(text: widget.draft.total ?? '');
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _dateCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // Na razie: tylko pokazujemy, co by było zapisane.
    final merchant = _merchantCtrl.text.trim();
    final date = _dateCtrl.text.trim();
    final total = _totalCtrl.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Zapis (MVP): $merchant | $date | $total')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edycja paragonu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _merchantCtrl,
              decoration: const InputDecoration(
                labelText: 'Sklep / merchant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(
                labelText: 'Data',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Kwota total',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Zapisz'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: widget.ocrLines.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, i) => Text(widget.ocrLines[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
