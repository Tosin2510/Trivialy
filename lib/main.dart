import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/auth/presentation/auth_gate.dart';
import 'package:trivialy/core/config/firebase_options.dart';

// The main entry poinf of the app.
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// The main build of the entire application.
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

