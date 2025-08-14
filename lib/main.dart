import 'package:flutter/material.dart';
import 'package:mylife/shared/widgets/drawer/app_drawer.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final drawerController = MyDrawerController();
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ZoomDrawer(
          controller: drawerController,
          menuBackgroundColor: Colors.black38,
          menuScreen: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                const SizedBox(height: 80),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => drawerController.close!(),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => drawerController.close!(),
                ),
              ],
            ),
          ),
          mainScreen: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => drawerController.toggle!(),
              ),
              title: const Text('myLife'),
            ),
            body: const Center(child: Text('Main content')),
          ),
        ),
      ),
    );
  }
}
