import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "core/theme/app_theme.dart";
import "providers/app_provider.dart";
import "providers/trace_mode_provider.dart";
import "features/home/screens/splash_screen.dart";

void main() {
  runApp(const TraceMateApp());
}

class TraceMateApp extends StatelessWidget {
  const TraceMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => TraceModeProvider()),
      ],
      child: MaterialApp(
        title: "TraceMate",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
