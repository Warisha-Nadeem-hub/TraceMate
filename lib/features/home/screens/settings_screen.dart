import "package:flutter/material.dart";
import "../../../core/constants/app_constants.dart";
import "../../../core/constants/app_strings.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/widgets/app_card.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfo(context),
            const SizedBox(height: 24),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.brush,
              size: 40,
              color: AppTheme.onPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            "Version ${AppConstants.appVersion}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                context,
                Icons.info_outline,
                "Description",
                "TraceMate helps you convert images into beautiful sketches and tracing templates.",
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                Icons.palette_outlined,
                "Features",
                "Pencil Sketch, Outline Sketch, High Contrast Sketch, Trace Mode, Grid Overlay",
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                Icons.code,
                "Built with",
                "Flutter & Material 3",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
