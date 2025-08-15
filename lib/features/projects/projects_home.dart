import 'package:flutter/material.dart';
import '../../core/db/app_db.dart';
import 'data/project_dao.dart';
import 'data/project_model.dart';

class ProjectsHome extends StatefulWidget {
  const ProjectsHome({super.key});
  @override
  State<ProjectsHome> createState() => _ProjectsHomeState();
}

class _ProjectsHomeState extends State<ProjectsHome> {
  late final ProjectDao _dao;
  List<Project> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AppDb.I.open();
    _dao = ProjectDao(AppDb.I.db);
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    _projects = await _dao.all();
    setState(() => _loading = false);
  }

  Future<void> _createProject() async {
    final controller = TextField(controller: TextEditingController());
    final textCtrl = (controller.controller as TextEditingController);

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Project'),
        content: controller,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, textCtrl.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    await _dao.insert(Project(name: name, createdAt: DateTime.now()));
    await _loadProjects();
  }

  Future<void> _deleteProject(Project p) async {
    if (p.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('This will remove ${p.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await _dao.remove(p.id!);
      await _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CraftForm  Projects')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
              ),
              itemCount: _projects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _AddProjectCard(onTap: _createProject);
                final project = _projects[index - 1];
                return _ProjectCard(
                  name: project.name,
                  onLongPress: () => _deleteProject(project),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        label: const Text('New Project'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _AddProjectCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProjectCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(child: Icon(Icons.add_circle_outline, size: 40)),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String name;
  final VoidCallback? onLongPress;
  const _ProjectCard({required this.name, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
