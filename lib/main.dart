import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DebtManagerApp());
}

class DebtManagerApp extends StatelessWidget {
  const DebtManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debt Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}



