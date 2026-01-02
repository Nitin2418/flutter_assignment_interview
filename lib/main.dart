import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  print('[APP] ========================================');
  print('[APP] Flutter Assignment App Starting...');
  print('[APP] ========================================');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('[APP] Building MaterialApp');
    return MaterialApp(
      title: 'Flutter Assignment - Range Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
