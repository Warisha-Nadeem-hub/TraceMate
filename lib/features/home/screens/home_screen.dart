import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/app_provider.dart';
import '../../../models/sketch_item.dart';
import 'sketch_generator_screen.dart';
import 'trace_mode_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'draw_sketch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppProvider>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildHeroSection(context),
          const SizedBox(height: 32),
          _buildRecentProjects(context),
          const SizedBox(height: 32),
          _buildActionButtons(context),
        ]))),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(AppStrings.welcomeTitle, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 4), Text(AppStrings.welcomeSubtitle, style: Theme.of(context).textTheme.bodySmall)]),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]), child: const Icon(Icons.brush, color: AppTheme.primaryColor)),
    ]);
  }

  Widget _buildHeroSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return GradientCard(
          onTap: () => _showImageSourceDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.onPrimaryColor),
                  ),
                  const Spacer(),
                  if (provider.isLoading)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimaryColor)),
                ],
              ),
              const SizedBox(height: 16),
              Text(AppStrings.uploadImage, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.onPrimaryColor)),
              const SizedBox(height: 8),
              Text(
                provider.hasImage ? provider.selectedImage!.path.split('/').last : 'Tap to select an image',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentProjects(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, child) {
      if (provider.recentProjects.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recent Projects', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())), child: const Text('View All'))]),
        const SizedBox(height: 12),
        SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: provider.recentProjects.length, itemBuilder: (context, index) => _buildRecentProjectCard(context, provider.recentProjects[index], provider))),
      ]);
    });
  }

  Widget _buildRecentProjectCard(BuildContext context, SketchItem project, AppProvider provider) {
    return GestureDetector(
      onTap: () { provider.loadProject(project); Navigator.push(context, MaterialPageRoute(builder: (_) => const SketchGeneratorScreen())); },
      child: Container(width: 100, margin: const EdgeInsets.only(right: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: project.sketchImagePath != null ? Image.file(File(project.sketchImagePath!), fit: BoxFit.cover, width: double.infinity) : const Icon(Icons.image, color: AppTheme.textTertiary)))),
          const SizedBox(height: 8),
          Text(project.projectName, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _ActionCard(icon: Icons.edit, title: AppStrings.convertToSketch, color: AppTheme.primaryColor, onTap: () {
          if (!context.read<AppProvider>().hasImage) {
            _showImageSourceDialog(context);
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SketchGeneratorScreen()));
        })),
        const SizedBox(width: 16),
        Expanded(child: _ActionCard(icon: Icons.gesture, title: 'Free Draw', color: AppTheme.tertiaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DrawSketchScreen())))),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _ActionCard(icon: Icons.grid_on, title: AppStrings.traceMode, color: AppTheme.secondaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraceModeScreen())))),
        const SizedBox(width: 16),
        Expanded(child: _ActionCard(icon: Icons.history, title: AppStrings.viewHistory, color: AppTheme.primaryContainer, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())))),
      ]),
      const SizedBox(height: 16),
      _ActionCard(icon: Icons.settings, title: AppStrings.settings, color: AppTheme.secondaryContainer, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ]);
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(currentIndex: 0, onTap: (index) { switch (index) { case 0: break; case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())); break; case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); break; } }, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home), BottomNavigationBarItem(icon: Icon(Icons.history), label: AppStrings.history), BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settings)]);
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.surfaceColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(AppStrings.selectImage, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 20), ListTile(leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor), title: const Text(AppStrings.camera), onTap: () { Navigator.pop(context); context.read<AppProvider>().pickImageFromCamera(); }), ListTile(leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor), title: const Text(AppStrings.gallery), onTap: () { Navigator.pop(context); context.read<AppProvider>().pickImageFromGallery(); })])));
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => AppCard(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), const SizedBox(height: 12), Text(title, style: Theme.of(context).textTheme.titleSmall)]));
}


