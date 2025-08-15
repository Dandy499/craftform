import 'package:sqflite/sqflite.dart';
import 'project_model.dart';

class ProjectDao {
  final Database db;
  ProjectDao(this.db);

  Future<int> insert(Project p) async {
    return db.insert('projects', p.toMap()..remove('id'));
  }

  Future<List<Project>> all() async {
    final rows = await db.query('projects', orderBy: 'created_at DESC');
    return rows.map(Project.fromMap).toList();
  }

  Future<int> remove(int id) async {
    return db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> rename(int id, String name) async {
    return db.update('projects', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }
}
