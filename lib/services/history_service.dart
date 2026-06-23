import 'dart:convert';

import 'package:barcode_app/models/qr_content.dart';
import 'package:barcode_app/models/qr_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HistoryService {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  static const _key = 'qr_history_v1';
  final _uuid = const Uuid();
  List<QrRecord> _records = [];

  List<QrRecord> get records => List.unmodifiable(_records);

  List<QrRecord> get favorites =>
      _records.where((record) => record.isFavorite).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _records = list
          .map((item) => QrRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _records = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_records.map((record) => record.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<QrRecord> addScanned(QrContent content) {
    return add(
      title: content.title,
      content: content.raw,
      kind: QrRecordKind.scanned,
      category: content.category,
      previewUrl: content.imageUrl ?? content.actionUrl,
    );
  }

  Future<QrRecord> addGenerated({
    required String title,
    required String content,
    required QrRecordCategory category,
    String? previewUrl,
  }) {
    return add(
      title: title,
      content: content,
      kind: QrRecordKind.generated,
      category: category,
      previewUrl: previewUrl,
    );
  }

  Future<QrRecord> add({
    required String title,
    required String content,
    required QrRecordKind kind,
    required QrRecordCategory category,
    String? previewUrl,
  }) async {
    final record = QrRecord(
      id: _uuid.v4(),
      title: title,
      content: content,
      kind: kind,
      category: category,
      createdAt: DateTime.now(),
      previewUrl: previewUrl,
    );
    _records.insert(0, record);
    if (_records.length > 200) {
      _records = _records.take(200).toList();
    }
    await _save();
    return record;
  }

  Future<void> toggleFavorite(String id) async {
    _records = _records
        .map(
          (record) => record.id == id
              ? record.copyWith(isFavorite: !record.isFavorite)
              : record,
        )
        .toList();
    await _save();
  }

  Future<void> delete(String id) async {
    _records = _records.where((record) => record.id != id).toList();
    await _save();
  }

  Future<void> clearAll() async {
    _records = [];
    await _save();
  }

  List<QrRecord> search(String query, {QrRecordCategory? filter}) {
    final q = query.trim().toLowerCase();
    return _records.where((record) {
      if (filter != null && record.category != filter) return false;
      if (q.isEmpty) return true;
      return record.title.toLowerCase().contains(q) ||
          record.content.toLowerCase().contains(q);
    }).toList();
  }
}
