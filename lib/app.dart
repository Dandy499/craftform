import 'package:flutter/material.dart';
import 'features/projects/projects_home.dart';

class CraftFormApp extends StatelessWidget {
  const CraftFormApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftForm',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const ProjectsHome(),
    );
  }
}
