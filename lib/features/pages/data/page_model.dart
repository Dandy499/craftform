class PageRow {
  final int? id;
  final String name;
  final int ord;
  final int projectId;

  const PageRow({this.id, required this.name, required this.ord, required this.projectId});

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'ord': ord,
    'project_id': projectId,
  };

  static PageRow fromMap(Map<String, Object?> m) => PageRow(
    id: (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
    name: m['name'] as String,
    ord: (m['ord'] as int?) ?? (m['ord'] as num).toInt(),
    projectId: (m['project_id'] as int?) ?? (m['project_id'] as num).toInt(),
  );
}
