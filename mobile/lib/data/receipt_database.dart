import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:receipt_parser/domain/models/receipt_entry.dart';
import 'package:sqflite/sqflite.dart';

class ReceiptDatabase {
  ReceiptDatabase._();

  static final ReceiptDatabase instance = ReceiptDatabase._();
  static const _dbName = 'receipts.db';
  static const _dbVersion = 2;
  static const _table = 'receipts';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant TEXT,
            date TEXT,
            total TEXT,
            image_path TEXT,
            ocr_lines TEXT,
            created_at TEXT,
            is_manual INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_table ADD COLUMN is_manual INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<int> insertReceipt(ReceiptEntry entry) async {
    final db = await database;
    return db.insert(_table, {
      'merchant': entry.merchant,
      'date': entry.date,
      'total': entry.total,
      'image_path': entry.imagePath,
      'ocr_lines': entry.ocrLines.join('\n'),
      'created_at': entry.createdAt.toIso8601String(),
      'is_manual': entry.isManual ? 1 : 0,
    });
  }

  Future<List<ReceiptEntry>> fetchReceipts() async {
    final db = await database;
    final rows = await db.query(
      _table,
      orderBy: 'datetime(created_at) DESC',
    );

    return rows.map((r) {
      return ReceiptEntry(
        id: r['id'] as int?,
        merchant: r['merchant'] as String?,
        date: r['date'] as String?,
        total: r['total'] as String?,
        imagePath: r['image_path'] as String?,
        ocrLines: (r['ocr_lines'] as String? ?? '').split('\n'),
        createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
            DateTime.now(),
        isManual: (r['is_manual'] as int? ?? 0) == 1,
      );
    }).toList();
  }
}
