import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/core/services/auth_service.dart';
import 'package:trivialy/features/home/presentation/home_screen.dart';
import 'package:trivialy/features/profile/services/profile_service.dart';
import 'package:trivialy/features/profile/presentation/profile_setupscreen.dart';
import 'package:trivialy/features/auth/presentation/sign_in_screen.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges, 
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final User? user = authSnapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        return FutureBuilder<bool>(
          future: ProfileService().hasCompletedSetup(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final bool hasProfile = profileSnapshot.data ?? false;
            return hasProfile ? const HomeScreen() : const ProfileSetupScreen();
          }
        );
      }
    );
  }

}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}