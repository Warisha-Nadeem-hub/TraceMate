import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/trace_mode_provider.dart';
import '../../../providers/app_provider.dart';

class TraceModeScreen extends StatefulWidget {
  const TraceModeScreen({super.key});
  @override
  State<TraceModeScreen> createState() => _TraceModeScreenState();
}

class _TraceModeScreenState extends State<TraceModeScreen> {
  final TransformationController _transformController = TransformationController();
  bool _isUpdatingFromController = false;
  double _rotation = 0.0;
  bool _flipH = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    if (_isUpdatingFromController) return;
    final scale = _transformController.value.getMaxScaleOnAxis();
    final provider = context.read<TraceModeProvider>();
    if ((provider.zoom - scale).abs() > 0.01) provider.setZoom(scale);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text(AppStrings.traceMode), backgroundColor: AppTheme.surfaceColor, actions: [
        IconButton(icon: const Icon(Icons.rotate_right), onPressed: () => setState(() => _rotation += 1.5707963267948966)),
        IconButton(icon: const Icon(Icons.flip), onPressed: () => setState(() => _flipH = !_flipH)),
        Consumer<TraceModeProvider>(builder: (context, provider, child) => IconButton(icon: Icon(provider.showGrid ? Icons.grid_off : Icons.grid_on), onPressed: () => provider.toggleGrid())),
      ]),
      body: Consumer2<AppProvider, TraceModeProvider>(
        builder: (context, appProvider, traceProvider, child) {
          return Column(
            children: [
              Expanded(child: _buildImageViewer(appProvider, traceProvider)),
              _buildControls(context, traceProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageViewer(AppProvider appProvider, TraceModeProvider traceProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: InteractiveViewer(transformationController: _transformController, minScale: AppConstants.minZoom, maxScale: AppConstants.maxZoom, child: Stack(fit: StackFit.expand, children: [
            if (appProvider.selectedImage != null) Transform(alignment: Alignment.center, transform: Matrix4.identity()..scale(_flipH ? -1.0 : 1.0, 1.0)..rotateZ(_rotation), child: Opacity(opacity: traceProvider.opacity, child: Image.file(appProvider.selectedImage!, fit: BoxFit.contain)))
            else Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.image, size: 60, color: AppTheme.textTertiary), const SizedBox(height: 16), Text(AppStrings.noImageSelected), const SizedBox(height: 8), TextButton(onPressed: () => _showImagePicker(context), child: Text(AppStrings.uploadImage))])),
            if (traceProvider.showGrid) _buildGridOverlay(traceProvider),
          ]))),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.surfaceColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(AppStrings.selectImage, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 20), ListTile(leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor), title: const Text(AppStrings.camera), onTap: () { Navigator.pop(context); context.read<AppProvider>().pickImageFromCamera(); }), ListTile(leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor), title: const Text(AppStrings.gallery), onTap: () { Navigator.pop(context); context.read<AppProvider>().pickImageFromGallery(); })])));
  }

  Widget _buildGridOverlay(TraceModeProvider provider) {
    if (provider.gridSize <= 0) return const SizedBox.shrink();
    return CustomPaint(painter: _GridPainter(gridSize: provider.gridSize, color: AppTheme.primaryColor.withValues(alpha: 0.5)));
  }

  Widget _buildControls(BuildContext context, TraceModeProvider provider) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))]), child: Column(children: [
        _buildSlider(context, label: AppStrings.opacity, value: provider.opacity, min: AppConstants.minOpacity, max: AppConstants.maxOpacity, onChanged: (v) => provider.setOpacity(v)),
        const SizedBox(height: 16),
        _buildZoomSlider(context, provider),
        const SizedBox(height: 16),
        _buildGridSelector(context, provider),
      ]));
  }

  Widget _buildSlider(BuildContext context, {required String label, required double value, required double min, required double max, required ValueChanged<double> onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: Theme.of(context).textTheme.titleSmall), Text(value.toStringAsFixed(2), style: Theme.of(context).textTheme.bodySmall)]), Slider(value: value, min: min, max: max, onChanged: onChanged)]);
  }

  Widget _buildZoomSlider(BuildContext context, TraceModeProvider provider) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Zoom', style: Theme.of(context).textTheme.titleSmall), Text((provider.zoom * 100).toInt().toString() + '%', style: Theme.of(context).textTheme.bodySmall)]), Slider(value: provider.zoom, min: AppConstants.minZoom, max: AppConstants.maxZoom, onChanged: (value) { _isUpdatingFromController = true; provider.setZoom(value); _transformController.value = Matrix4.identity()..scale(value, value); _isUpdatingFromController = false; })]);
  }

  Widget _buildGridSelector(BuildContext context, TraceModeProvider provider) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(AppStrings.gridOverlay, style: Theme.of(context).textTheme.titleSmall), const SizedBox(height: 8), Row(children: AppConstants.gridOptions.map((size) { final isSelected = provider.gridSize == size; return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(label: Text(size.toString() + 'x' + size.toString()), selected: isSelected, onSelected: (_) => provider.setGridSize(size), selectedColor: AppTheme.primaryColor))); }).toList())]);
  }
}

class _GridPainter extends CustomPainter {
  final int gridSize;
  final Color color;
  _GridPainter({required this.gridSize, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;
    for (int i = 1; i < gridSize; i++) { canvas.drawLine(Offset(cellWidth * i, 0), Offset(cellWidth * i, size.height), paint); canvas.drawLine(Offset(0, cellHeight * i), Offset(size.width, cellHeight * i), paint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



