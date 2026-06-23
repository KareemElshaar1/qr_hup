enum QrRecordKind { scanned, generated }

enum QrRecordCategory {
  text,
  url,
  phone,
  email,
  whatsapp,
  wifi,
  location,
  profile,
  pdf,
  image,
  other,
}

class QrRecord {
  const QrRecord({
    required this.id,
    required this.title,
    required this.content,
    required this.kind,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
    this.previewUrl,
  });

  final String id;
  final String title;
  final String content;
  final QrRecordKind kind;
  final QrRecordCategory category;
  final DateTime createdAt;
  final bool isFavorite;
  final String? previewUrl;

  QrRecord copyWith({
    String? title,
    String? content,
    bool? isFavorite,
    String? previewUrl,
  }) {
    return QrRecord(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      kind: kind,
      category: category,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      previewUrl: previewUrl ?? this.previewUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'kind': kind.name,
        'category': category.name,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
        'previewUrl': previewUrl,
      };

  factory QrRecord.fromJson(Map<String, dynamic> json) {
    return QrRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      kind: QrRecordKind.values.byName(json['kind'] as String),
      category: QrRecordCategory.values.byName(json['category'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      previewUrl: json['previewUrl'] as String?,
    );
  }
}
