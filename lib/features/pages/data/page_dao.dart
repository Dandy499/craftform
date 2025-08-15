import 'package:sqflite/sqflite.dart';
import 'page_model.dart';

class PageDao {
  final Database db;
  PageDao(this.db);

  Future<List<PageRow>> byProject(int projectId) async {
    final rows = await db.query('pages',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'ord ASC',
    );
    return rows.map(PageRow.fromMap).toList();
  }

  Future<int> _nextOrd(int projectId) async {
    final r = await db.rawQuery(
      'SELECT COALESCE(MAX(ord), -1) + 1 as next_ord FROM pages WHERE project_id = ?',
      [projectId],
    );
    return (r.first['next_ord'] as int?) ?? (r.first['next_ord'] as num).toInt();
  }

  Future<int> insert(int projectId, String name) async {
    final ord = await _nextOrd(projectId);
    return db.insert('pages', {'name': name, 'ord': ord, 'project_id': projectId});
  }

  Future<int> rename(int id, String name) =>
      db.update('pages', {'name': name}, where: 'id = ?', whereArgs: [id]);

  Future<int> delete(int id) =>
      db.delete('pages', where: 'id = ?', whereArgs: [id]);

  Future<void> saveOrder(int projectId, List<PageRow> pages) async {
    final batch = db.batch();
    for (var i = 0; i < pages.length; i++) {
      final p = pages[i];
      if (p.id != null) {
        batch.update('pages', {'ord': i}, where: 'id = ?', whereArgs: [p.id]);
      }
    }
    await batch.commit(noResult: true);
  }
}
