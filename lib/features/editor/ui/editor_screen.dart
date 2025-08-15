import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/db/app_db.dart';
import '../../assets/data/asset_dao.dart';
import '../../assets/data/asset_model.dart';

class EditorScreen extends StatefulWidget {
  final int pageId;
  final String pageName;
  const EditorScreen({super.key, required this.pageId, required this.pageName});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final AssetDao _assetDao;
  bool _ready = false;

  @override
  void initState() { super.initState(); _boot(); }

  Future<void> _boot() async {
    await AppDb.I.open();
    _assetDao = AssetDao(AppDb.I.db);
    setState(() => _ready = true);
  }

  Future<void> _saveDummy() async {
    final json = jsonEncode({
      'kind': 'rect', 'x': 24, 'y': 24, 'w': 160, 'h': 100, 'fill': '#6C9EFF', 'radius': 16
    });
    await _assetDao.insert(AssetRow(
      name: 'Rectangle', type: 'shape', dataJson: json, pageId: widget.pageId, createdAt: DateTime.now(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asset saved to page.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('Editor  ${widget.pageName}'), actions: [
        IconButton(onPressed: _saveDummy, icon: const Icon(Icons.save))
      ]),
      body: const _EditorCanvas(),
      floatingActionButton: FloatingActionButton.extended(onPressed: _saveDummy, icon: const Icon(Icons.add), label: const Text('Save Asset')),
    );
  }
}

class _EditorCanvas extends StatelessWidget {
  const _EditorCanvas();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return CustomPaint(painter: _CanvasPainter(), child: SizedBox(width: c.maxWidth, height: c.maxHeight));
    });
  }
}

class _CanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF5F6FA);
    canvas.drawRect(Offset.zero & size, bg);

    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(24, 24, 160, 100), const Radius.circular(16));
    final fill = Paint()..color = const Color(0xFF6C9EFF);
    canvas.drawRRect(r, fill);

    final stroke = Paint()..color = const Color(0xFF3B5BCC)..style = PaintingStyle.stroke..strokeWidth = 2;
    const dash = 6.0;
    double x = 24, y = 24, w = 160, h = 100;
    for (double i = x; i < x + w; i += dash * 2) {
      canvas.drawLine(Offset(i, y), Offset(i + dash, y), stroke);
      canvas.drawLine(Offset(i, y + h), Offset(i + dash, y + h), stroke);
    }
    for (double i = y; i < y + h; i += dash * 2) {
      canvas.drawLine(Offset(x + w, i), Offset(x + w, i + dash), stroke);
      canvas.drawLine(Offset(x, i), Offset(x, i + dash), stroke);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
