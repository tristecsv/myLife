import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mylife/shared/providers/theme_provider.dart';

class ThemeButton extends ConsumerWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeState.mode == ThemeMode.dark;

    return IconButton(
      tooltip: 'Cambiar tema',
      onPressed: () => notifier.toggleThemeMode(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (child, animation) {
          final rotateAnim =
              Tween<double>(begin: -0.25, end: 0.0).animate(animation);
          final scaleAnim =
              Tween<double>(begin: 0.06, end: 1.0).animate(animation);
          return RotationTransition(
            turns: rotateAnim,
            child: ScaleTransition(
              scale: scaleAnim,
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: isDark
            ? const Icon(LucideIcons.moon, key: ValueKey('moon'), size: 20)
            : const Icon(LucideIcons.sun, key: ValueKey('sun'), size: 20),
      ),
    );
  }
}
