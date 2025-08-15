import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mylife/shared/models/menu_entry.dart';
import 'package:mylife/shared/widgets/drawer/app_drawer.dart';
import 'package:mylife/shared/widgets/menu/menu_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MyDrawerController _drawerController = MyDrawerController();

  static const List<MenuEntry> menuItems = [
    MenuEntry(id: 'dashboard', label: 'Dashboard', icon: LucideIcons.house),
    MenuEntry(id: 'expenses', label: 'Gastos', icon: LucideIcons.dollarSign),
    MenuEntry(id: 'exercise', label: 'Ejercicio', icon: LucideIcons.dumbbell),
    MenuEntry(id: 'notes', label: 'Notas', icon: LucideIcons.notebookPen),
    MenuEntry(id: 'calendar', label: 'Calendario', icon: LucideIcons.calendar),
    MenuEntry(
        id: 'school_notes',
        label: 'Notas Escolares',
        icon: LucideIcons.graduationCap),
    MenuEntry(id: 'schedules', label: 'Horarios', icon: LucideIcons.clock),
    MenuEntry(id: 'habits', label: 'Hábitos', icon: LucideIcons.target),
  ];

  int _selectedIndex = 0;

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
    if (_drawerController.close != null) _drawerController.close!();
  }

  Widget _buildMain() {
    // muestra contenido según _selectedIndex (placeholder)
    final entry = menuItems[_selectedIndex];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _drawerController.toggle?.call(),
        ),
        title: Text(entry.label),
      ),
      body: Center(
        child: Text(
          'Pantalla: ${entry.label}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Acción en ${entry.label}')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomDrawer(
        controller: _drawerController,
        drawerShadowsBackgroundColor: Theme.of(context).colorScheme.background,
        menuBackgroundColor: Colors.grey.shade300,
        mainScreen: _buildMain(),
        menuScreen: MenuDrawer(
          items: menuItems,
          onSelect: _onSelect,
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }
}
