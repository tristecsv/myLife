import 'package:flutter/material.dart';
import 'package:mylife/shared/models/menu_entry.dart';
import 'package:mylife/shared/widgets/menu/menu_button.dart';

class MenuDrawer extends StatelessWidget {
  final List<MenuEntry> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onSettings;

  const MenuDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, child: Icon(Icons.person)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'miLife',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final active = index == selectedIndex;
                  return MenuButton(
                    label: item.label,
                    icon: item.icon,
                    active: active,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton.icon(
                onPressed: onSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Ajustes'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
