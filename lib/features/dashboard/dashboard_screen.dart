import 'package:flutter/material.dart';
import '../../core/db/app_db.dart';
import '../pages/data/page_dao.dart';
import '../pages/data/page_model.dart';
import '../editor/ui/editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  const DashboardScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageDao _dao;
  List<PageRow> _pages = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    await AppDb.I.open();
    _dao = PageDao(AppDb.I.db);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _pages = await _dao.byProject(widget.projectId);
    setState(() => _loading = false);
  }

  Future<void> _addPage() async {
    final ctrl = TextEditingController(text: 'Landing');
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Page'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Page name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _dao.insert(widget.projectId, name);
    await _load();
  }

  Future<void> _rename(PageRow p) async {
    final ctrl = TextEditingController(text: p.name);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Rename Page'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == p.name) return;
    await _dao.rename(p.id!, name);
    await _load();
  }

  Future<void> _delete(PageRow p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Page?'),
        content: Text('Remove "${p.name}" and all its assets?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) { await _dao.delete(p.id!); await _load(); }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });
    await _dao.saveOrder(widget.projectId, _pages);
  }

  void _open(PageRow p) {
    if (p.id == null) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditorScreen(pageId: p.id!, pageName: p.name),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project  ${widget.projectName}')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _pages.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('No pages yet'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _addPage, child: const Text('Add first page')),
            ]))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onReorder: _reorder,
              itemCount: _pages.length,
              itemBuilder: (context, i) {
                final p = _pages[i];
                return Dismissible(
                  key: ValueKey(p.id ?? '${p.name}-$i'),
                  background: Container(color: Theme.of(context).colorScheme.errorContainer),
                  confirmDismiss: (_) async { await _delete(p); return false; },
                  child: ListTile(
                    leading: const Icon(Icons.drag_indicator),
                    title: Text(p.name),
                    subtitle: Text('Order: ${p.ord}'),
                    onTap: () => _open(p),
                    onLongPress: () => _rename(p),
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _rename(p)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPage, icon: const Icon(Icons.add), label: const Text('Add Page'),
      ),
    );
  }
}
