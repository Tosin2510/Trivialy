import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/auth/presentation/auth_gate.dart';
import 'package:trivialy/core/config/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  
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
        home: AuthGate(),
    );
  }
}

