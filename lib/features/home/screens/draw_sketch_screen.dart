import 'dart:async';
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
  final List<StrokePath> _drawings = <StrokePath>[];
  StrokePath? _currentStroke;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;
  bool _isImageBackground = true; // Tracing app standard default
  bool _isPlayingBack = false;

  // For Speed Draw Playback tracking
  List<StrokePath> _playbackDrawings = <StrokePath>[];

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
          'Speed Trace Studio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          IconButton(
            icon: Icon(
              _isPlayingBack ? Icons.stop : Icons.play_arrow,
              color: Colors.green,
            ),
            onPressed: _drawings.isEmpty
                ? null
                : (_isPlayingBack ? _stopPlayback : _startSpeedDraw),
          ),
          IconButton(
            icon: Icon(
              _isImageBackground ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () =>
                setState(() => _isImageBackground = !_isImageBackground),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: (_drawings.isNotEmpty && !_isPlayingBack) ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: !_isPlayingBack ? _clear : null,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) => Column(
          children: [
            Expanded(child: _buildCanvas(provider)),
            if (!_isPlayingBack) _buildQuickColorBar(),
            if (!_isPlayingBack) _buildToolbar(),
            if (_isPlayingBack) _buildPlaybackBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(AppProvider provider) {
    return AbsorbPointer(
      absorbing: _isPlayingBack, // Block human input during playback
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Underlying Template Image for Tracing Mode
                if (_isImageBackground && provider.selectedImage != null)
                  Opacity(
                    opacity:
                        0.4, // Dim template for better line tracing clarity
                    child: Image.file(
                      provider.selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                CustomPaint(
                  painter: SmoothDrawingPainter(
                    // Show current active state or dynamic playback frame state
                    drawings: _isPlayingBack ? _playbackDrawings : _drawings,
                    currentStroke: _isPlayingBack ? null : _currentStroke,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Smooth Path Mechanics ---
  void _onPanStart(DragStartDetails d) {
    final startTime = DateTime.now();
    setState(() {
      _currentStroke = StrokePath(
        color: _isEraser ? AppTheme.surfaceColor : _selectedColor,
        strokeWidth: _strokeWidth,
        points: [TimedPoint(offset: d.localPosition, time: startTime)],
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_currentStroke == null) return;
    setState(() {
      _currentStroke!.points.add(
        TimedPoint(offset: d.localPosition, time: DateTime.now()),
      );
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_currentStroke != null && _currentStroke!.points.isNotEmpty) {
      setState(() {
        _drawings.add(_currentStroke!);
        _currentStroke = null;
      });
    }
  }

  // --- Roblox Style Speed Draw Playback Engine ---
  void _startSpeedDraw() async {
    setState(() {
      _isPlayingBack = true;
      _playbackDrawings = [];
    });

    // Flatten history to find exact timeline stamps
    for (var originalStroke in _drawings) {
      if (!_isPlayingBack) break; // Interrupted exit

      List<TimedPoint> simulatedPoints = [];
      StrokePath activePlaybackStroke = StrokePath(
        color: originalStroke.color,
        strokeWidth: originalStroke.strokeWidth,
        points: simulatedPoints,
      );

      setState(() {
        _playbackDrawings.add(activePlaybackStroke);
      });

      for (int i = 0; i < originalStroke.points.length; i++) {
        if (!_isPlayingBack) break;

        final currentPt = originalStroke.points[i];
        simulatedPoints.add(currentPt);
        setState(() {}); // Trigger continuous canvas frame updates

        // Simulate identical delay between stroke sequences
        if (i < originalStroke.points.length - 1) {
          final nextPt = originalStroke.points[i + 1];
          final delay = nextPt.time.difference(currentPt.time);
          // Speed up playback safely to match Roblox style hyper-lapse pacing
          await Future.delayed(delay ~/ 2);
        }
      }
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Gap between separate strokes
    }

    _stopPlayback();
  }

  void _stopPlayback() {
    setState(() {
      _isPlayingBack = false;
      _playbackDrawings = [];
    });
  }

  // --- Basic Tracing UI Compositions ---
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
                shape: BoxShape.rectangle,
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
                _buildToolButton(
                  Icons.brush,
                  'Draw',
                  !_isEraser,
                  () => setState(() => _isEraser = false),
                ),
                _buildToolButton(
                  Icons.auto_fix_normal,
                  'Eraser',
                  _isEraser,
                  () => setState(() => _isEraser = true),
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

  Widget _buildPlaybackBanner() {
    return Container(
      width: double.infinity,
      color: Colors.green.shade700,
      padding: const EdgeInsets.all(12),
      child: const Center(
        child: Text(
          'Rendering Speed Draw Playback...',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _undo() => setState(() {
    if (_drawings.isNotEmpty) _drawings.removeLast();
  });
  void _clear() => setState(() {
    _drawings.clear();
    _currentStroke = null;
  });
} // --- Smooth Drawing Performance Painter (Using Quadratic Bézier Curves) ---class SmoothDrawingPainter extends CustomPainter {final List drawings;final StrokePath? currentStroke;SmoothDrawingPainter({required this.drawings, this.currentStroke});@overridevoid paint(Canvas canvas, Size size) {for (final stroke in drawings) {_drawSmoothStroke(canvas, stroke);}if (currentStroke != null) {_drawSmoothStroke(canvas, currentStroke!);}}void _drawSmoothStroke(Canvas canvas, StrokePath stroke) {if (stroke.points.isEmpty) return;final paint = Paint()..color = stroke.color..strokeWidth = stroke.strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;final path = Path();if (stroke.points.length == 1) {// Single tap makes a solid circular dotcanvas.drawCircle(stroke.points.first.offset, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);return;}path.moveTo(stroke.points[0].offset.dx, stroke.points[0].offset.dy);for (int i = 0; i < stroke.points.length - 1; i++) {final p0 = stroke.points[i].offset;final p1 = stroke.points[i + 1].offset;// Calculate midpoint vectors for the Quadratic Curve segment interpolationsfinal midPointX = (p0.dx + p1.dx) / 2;final midPointY = (p0.dy + p1.dy) / 2;// Smooth pathing connectionspath.quadraticBezierTo(p0.dx, p0.dy, midPointX, midPointY);}// Connect final terminal node cleanlypath.lineTo(stroke.points.last.offset.dx, stroke.points.last.offset.dy);canvas.drawPath(path, paint);}@overridebool shouldRepaint(covariant SmoothDrawingPainter oldDelegate) => true;}// --- Performance Optimizing Object Models ---class TimedPoint {final Offset offset;final DateTime time;TimedPoint({required this.offset, required this.time});}class StrokePath {final Color color;final double strokeWidth;final List points;StrokePath({required this.color,required this.strokeWidth,required this.points,});}

//======================================================================
// PASTE THESE AT THE VERY BOTTOM OF YOUR FILE (OUTSIDE ALL OTHER CLASSES)
//======================================================================

class StrokePath {
  final Color color;
  final double strokeWidth;
  final List<TimedPoint> points;

  StrokePath({
    required this.color,
    required this.strokeWidth,
    required this.points,
  });
}

class TimedPoint {
  final Offset offset;
  final DateTime time;
  TimedPoint({required this.offset, required this.time});
}

class SmoothDrawingPainter extends CustomPainter {
  final List<StrokePath> drawings;
  final StrokePath? currentStroke;

  SmoothDrawingPainter({required this.drawings, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in drawings) {
      _drawSmoothStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawSmoothStroke(canvas, currentStroke!);
    }
  }

  void _drawSmoothStroke(Canvas canvas, StrokePath stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first.offset,
        stroke.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    path.moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i].offset;
      final p1 = stroke.points[i + 1].offset;

      final midPointX = (p0.dx + p1.dx) / 2;
      final midPointY = (p0.dy + p1.dy) / 2;

      path.quadraticBezierTo(p0.dx, p0.dy, midPointX, midPointY);
    }

    path.lineTo(stroke.points.last.offset.dx, stroke.points.last.offset.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SmoothDrawingPainter oldDelegate) => true;
}
