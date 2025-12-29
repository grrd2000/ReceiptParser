import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_parser/data/receipt_database.dart';
import 'package:receipt_parser/domain/models/receipt_entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ReceiptEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReceiptDatabase.instance.fetchReceipts();
  }

  void reload() {
    setState(() {
      _future = ReceiptDatabase.instance.fetchReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia zapisów'),
      ),
      body: FutureBuilder<List<ReceiptEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Brak zapisanych paragonów.\nZeskanuj pierwszy i zapisz go tutaj.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              reload();
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final subtitleParts = [
                  if (item.date != null && item.date!.isNotEmpty)
                    'Data: ${item.date}',
                  if (item.total != null && item.total!.isNotEmpty)
                    'Kwota: ${item.total} PLN',
                ];

                final created = item.createdAt.toLocal();
                final createdLabel =
                    '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} '
                    '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

                return Card(
                  child: ListTile(
                    leading: _ReceiptThumbnail(path: item.imagePath),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(item.merchant ?? 'Paragon #${item.id ?? '?'}'),
                        ),
                        if (item.isManual)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_note,
                                    size: 16, color: Colors.orange.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Ręcznie',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subtitleParts.isNotEmpty)
                          Text(subtitleParts.join(' • ')),
                        Text(
                          'Dodano: $createdLabel',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                        if (item.isManual)
                          Text(
                            'Dodano ręcznie',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                    onTap: () => _showOcrDialog(item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showOcrDialog(ReceiptEntry entry) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_snippet_outlined),
                    const SizedBox(width: 10),
                    Text(
                      'Tekst OCR (${entry.ocrLines.length} linii)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: entry.ocrLines.isEmpty
                      ? Center(
                          child: Text(
                            'Brak zapisanych linii OCR.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                        )
                      : ListView.separated(
                          itemCount: entry.ocrLines.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, i) => Text(entry.ocrLines[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReceiptThumbnail extends StatelessWidget {
  final String? path;
  const _ReceiptThumbnail({this.path});

  @override
  Widget build(BuildContext context) {
    final file = path != null ? File(path!) : null;
    final imageWidget = file != null && file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.receipt_long, size: 28);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        width: 56,
        color: Colors.grey.shade200,
        child: imageWidget,
      ),
    );
  }
}
