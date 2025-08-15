class Project {
  final int? id;
  final String name;
  final DateTime createdAt;

  const Project({this.id, required this.name, required this.createdAt});

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };

  static Project fromMap(Map<String, Object?> m) => Project(
    id: (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
    name: m['name'] as String,
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
