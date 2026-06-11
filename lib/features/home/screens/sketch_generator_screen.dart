import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/sketch_item.dart';
import '../../../providers/app_provider.dart';

class SketchGeneratorScreen extends StatelessWidget {
  const SketchGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.convertToSketch),
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePreview(context, provider),
                const SizedBox(height: 24),
                _buildSketchTypes(context, provider),
                const SizedBox(height: 24),
                if (provider.hasSketch) _buildSketchPreview(context, provider),
                if (provider.hasSketch) const SizedBox(height: 24),
                if (provider.hasSketch) _buildSaveButton(context, provider),
                if (provider.errorMessage != null)
                  _buildErrorMessage(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, AppProvider provider) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: provider.selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(provider.selectedImage!, fit: BoxFit.contain),
            )
          : const Center(
              child: Icon(Icons.image, size: 60, color: AppTheme.textTertiary),
            ),
    );
  }

  Widget _buildSketchTypes(BuildContext context, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Sketch Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SketchTypeCard(
                title: AppStrings.pencilSketch,
                icon: Icons.edit,
                isSelected:
                    provider.selectedSketchType == SketchType.pencilSketch,
                onTap: () => provider.generateSketch(SketchType.pencilSketch),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SketchTypeCard(
                title: AppStrings.outlineSketch,
                icon: Icons.border_color,
                isSelected:
                    provider.selectedSketchType == SketchType.outlineSketch,
                onTap: () => provider.generateSketch(SketchType.outlineSketch),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SketchTypeCard(
                title: AppStrings.highContrastSketch,
                icon: Icons.contrast,
                isSelected:
                    provider.selectedSketchType ==
                    SketchType.highContrastSketch,
                onTap: () =>
                    provider.generateSketch(SketchType.highContrastSketch),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SketchTypeCard(
                title: 'Smooth',
                icon: Icons.blur_on,
                isSelected:
                    provider.selectedSketchType == SketchType.smoothSketch,
                onTap: () => provider.generateSketch(SketchType.smoothSketch),
              ),
            ),
          ],
        ),
        if (provider.isProcessing)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.processingImage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSketchPreview(BuildContext context, AppProvider provider) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(provider.sketchBytes!, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppProvider provider) {
    return AppButton(
      text: AppStrings.save,
      icon: Icons.save,
      onPressed: () => _showSaveDialog(context, provider),
      isLoading: provider.isLoading,
    );
  }

  void _showSaveDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController(
      text: 'Project_' + DateTime.now().millisecondsSinceEpoch.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Project Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.saveSketch(projectName: nameController.text);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.errorMessage!,
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SketchTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _SketchTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.outlineColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.onPrimaryColor
                  : AppTheme.textPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppTheme.onPrimaryColor
                    : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
