import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylife/core/constants/color_constants.dart';
import 'package:mylife/shared/services/hive_services.dart';

class ThemeState {
  final ThemeMode mode;
  final Color primary;

  const ThemeState({required this.mode, required this.primary});

  ThemeState copyWith({ThemeMode? mode, Color? primary}) {
    return ThemeState(
        mode: mode ?? this.mode, primary: primary ?? this.primary);
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(
          HiveService.settingsBox.isOpen
              ? ThemeState(
                  mode: HiveService.settingsBox.get(
                    ColorConstants.keyIsDark,
                    defaultValue: false,
                  )
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  primary: Color(
                    HiveService.settingsBox.get(
                      ColorConstants.keyPrimaryColor,
                      defaultValue: ColorConstants.green.value,
                    ),
                  ),
                )
              : const ThemeState(
                  mode: ThemeMode.system, primary: ColorConstants.green),
        );

  Future<void> toggleThemeMode() async {
    final isDark = state.mode == ThemeMode.dark;
    state = state.copyWith(mode: isDark ? ThemeMode.light : ThemeMode.dark);

    // persistir
    final box = HiveService.settingsBox;
    await box.put(ColorConstants.keyIsDark, !isDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final box = HiveService.settingsBox;
    await box.put(ColorConstants.keyIsDark, mode == ThemeMode.dark);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primary: color);
    final box = HiveService.settingsBox;
    await box.put(ColorConstants.keyPrimaryColor, color.value);
  }

  Future<void> resetToDefaults() async {
    state =
        const ThemeState(mode: ThemeMode.system, primary: ColorConstants.green);
    final box = HiveService.settingsBox;
    await box.put(ColorConstants.keyIsDark, ThemeMode.system == ThemeMode.dark);
    await box.put(ColorConstants.keyPrimaryColor, ColorConstants.green.value);
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) => ThemeNotifier());

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeNotifierProvider);
  return _buildTheme(state.primary, Brightness.light);
});

final appThemeDataDarkProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeNotifierProvider);
  return _buildTheme(state.primary, Brightness.dark);
});

ThemeData _buildTheme(Color primary, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  const darkBackground = Color(0xFF0A0A0A);
  const darkMenuBackground = Color(0xFF212121);
  const lightBackground = Color(0xFFFFFFFF);
  const lightMenuBackground = Color(0xFFE0E0E0);

  final scaffoldBg = isDark ? darkBackground : lightBackground;
  final menuBg = isDark ? darkMenuBackground : lightMenuBackground;

  final baseScheme =
      ColorScheme.fromSeed(seedColor: primary, brightness: brightness);
  final colorScheme = baseScheme.copyWith(
    background: scaffoldBg,
    surface: isDark ? const Color(0xFF0F0F0F) : Colors.white,
    primary: baseScheme.primary,
    onPrimary: baseScheme.onPrimary,
  );

  final textTheme =
      (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme).apply(
    bodyColor: colorScheme.onBackground,
    displayColor: colorScheme.onBackground,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: scaffoldBg,
    drawerTheme: DrawerThemeData(
      backgroundColor: menuBg,
      elevation: 0,
      scrimColor: colorScheme.onBackground.withOpacity(0.5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      titleTextStyle: textTheme.titleLarge
          ?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardTheme(
      color: isDark ? const Color(0xFF111111) : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      iconColor: colorScheme.primary,
      textColor: colorScheme.onBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
    ),
    dividerColor: colorScheme.onSurface.withOpacity(0.08),
    iconTheme: IconThemeData(color: colorScheme.onBackground),
    textTheme: textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkRipple.splashFactory,
  );
}
