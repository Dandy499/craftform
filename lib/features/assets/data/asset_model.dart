class AssetRow {
  final int? id;
  final String name;
  final String type;
  final String dataJson;
  final int pageId;
  final DateTime createdAt;

  const AssetRow({
    this.id,
    required this.name,
    required this.type,
    required this.dataJson,
    required this.pageId,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'data_json': dataJson,
    'page_id': pageId,
    'created_at': createdAt.toIso8601String(),
  };

  static AssetRow fromMap(Map<String, Object?> m) => AssetRow(
    id: (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
    name: m['name'] as String,
    type: m['type'] as String,
    dataJson: m['data_json'] as String,
    pageId: (m['page_id'] as int?) ?? (m['page_id'] as num).toInt(),
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
