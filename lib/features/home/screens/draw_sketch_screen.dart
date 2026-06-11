import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_provider.dart';

class DrawSketchScreen extends StatefulWidget {
  const DrawSketchScreen({super.key});
  @override
  State<DrawSketchScreen> createState() => _DrawSketchScreenState();
}

class _DrawSketchScreenState extends State<DrawSketchScreen> {
  // FIX: Separate finished paths cleanly
  final List<List<DrawingPoint>> _drawings = <List<DrawingPoint>>[];
  List<DrawingPoint> _currentDrawing = <DrawingPoint>[];

  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false; // NEW: Roblox style eraser toggle
  bool _isImageBackground = false;

  final List<Color> _colorOptions = <Color>[
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Roblox Free Draw',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              _isImageBackground ? Icons.image : Icons.image_not_supported,
            ),
            onPressed: () =>
                setState(() => _isImageBackground = !_isImageBackground),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _drawings.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: (_drawings.isNotEmpty || _currentDrawing.isNotEmpty)
                ? _clear
                : null,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) => Column(
          children: [
            // FIX 1: Wrap in Expanded so the canvas scales nicely inside the Column
            Expanded(child: _buildCanvas(provider)),
            _buildQuickColorBar(), // NEW: Roblox style direct access colors
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(AppProvider provider) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(
            8,
          ), // Roblox prefers blockier corners
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand, // This now works safely inside Expanded
            children: [
              if (_isImageBackground && provider.selectedImage != null)
                Image.file(provider.selectedImage!, fit: BoxFit.cover),
              CustomPaint(
                painter: DrawingPainter(
                  drawings: _drawings,
                  currentDrawing: _currentDrawing,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickColorBar() {
    return Container(
      height: 50,
      color: AppTheme.surfaceColor.withOpacity(0.5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _colorOptions.length,
        itemBuilder: (context, index) {
          final color = _colorOptions[index];
          final isSelected = _selectedColor == color && !_isEraser;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              _isEraser = false;
            }),
            child: Container(
              width: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle, // Blocky Roblox feel
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.black26,
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(Icons.brush, 'Draw', !_isEraser, () {
                  setState(() => _isEraser = false);
                }),
                _buildToolButton(
                  Icons.auto_fix_normal,
                  'Eraser',
                  _isEraser,
                  () {
                    setState(() => _isEraser = true);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Size: ${_strokeWidth.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 2,
                    max: 24,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() => _strokeWidth = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? Colors.white : AppTheme.primaryColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _currentDrawing = [
        DrawingPoint(
          offset: d.localPosition,
          color: _isEraser ? AppTheme.surfaceColor : _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      ];
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _currentDrawing.add(
        DrawingPoint(
          offset: d.localPosition,
          color: _isEraser ? AppTheme.surfaceColor : _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_currentDrawing.isNotEmpty) {
      setState(() {
        _drawings.add(List<DrawingPoint>.from(_currentDrawing));
        _currentDrawing =
            <
              DrawingPoint
            >[]; // FIX 2: Re-instantiate array instead of wiping reference
      });
    }
  }

  void _undo() => setState(() {
    if (_drawings.isNotEmpty) _drawings.removeLast();
  });
  void _clear() => setState(() {
    _drawings.clear();
    _currentDrawing.clear();
  });
}

// Ensure you use a solid DrawingPainter snippet to render the list collection
class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> drawings;
  final List<DrawingPoint> currentDrawing;
  DrawingPainter({required this.drawings, required this.currentDrawing});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in drawings) {
      _drawStroke(canvas, stroke);
    }
    _drawStroke(canvas, currentDrawing);
  }

  void _drawStroke(Canvas canvas, List<DrawingPoint> points) {
    if (points.isEmpty) return;
    for (int i = 0; i < points.length - 1; i++) {
      final paint = Paint()
        ..color = points[i].color
        ..strokeWidth = points[i].strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}
