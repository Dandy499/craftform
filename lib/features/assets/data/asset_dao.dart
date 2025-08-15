import 'package:sqflite/sqflite.dart';
import 'asset_model.dart';

class AssetDao {
  final Database db;
  AssetDao(this.db);

  Future<int> insert(AssetRow a) => db.insert('assets', a.toMap());

  Future<List<AssetRow>> byPage(int pageId) async {
    final rows = await db.query('assets', where: 'page_id = ?', whereArgs: [pageId], orderBy: 'created_at DESC');
    return rows.map(AssetRow.fromMap).toList();
  }

  Future<int> delete(int id) => db.delete('assets', where: 'id = ?', whereArgs: [id]);
}
