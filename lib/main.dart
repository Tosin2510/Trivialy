import 'package:flutter/material.dart';
import 'package:trivialy/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivialy',
      theme: ThemeData(
        useMaterial3: true,
        ),
        home: const HomeScreen(),
    );
  }
}

