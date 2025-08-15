import 'package:flutter/material.dart';
import 'package:mylife/home.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'myLife',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const Home(),
    );
  }
}
