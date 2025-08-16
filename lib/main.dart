import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylife/home.dart';
import 'package:mylife/shared/providers/theme_provider.dart';
import 'package:mylife/shared/services/hive_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final light = ref.watch(appThemeDataProvider);
    final dark = ref.watch(appThemeDataDarkProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myLife',
      theme: light,
      darkTheme: dark,
      themeMode: themeState.mode,
      home: const Home(),
    );
  }
}
