import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/core/services/auth_service.dart';
import 'package:trivialy/features/home/presentation/home_screen.dart';
import 'package:trivialy/features/profile/services/profile_service.dart';
import 'package:trivialy/features/profile/presentation/profile_setupscreen.dart';
import 'package:trivialy/features/auth/presentation/sign_in_screen.dart';

// This basically checks if a user is signed in and if they have setup their profile.
class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // This part uses a stream buildr to check if the user is signed in and if their profile is set already.
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges, 
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        // This takes the user to the sign in if they are not sign in already.
        final User? user = authSnapshot.data;
        if (user == null) {
          return const SignInScreen();
        }


        // Uses a future builder so as to check if a user has their profile screen set up already.
        return FutureBuilder<bool>(
          future: ProfileService().hasCompletedSetup(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }
            // If the user has set up their profile, this take them to home screen.
            final bool hasProfile = profileSnapshot.data ?? false;
            return hasProfile ? const HomeScreen() : const ProfileSetupScreen();
          }
        );
      }
    );
  }

}

// Handles the loading screen so the user will not think the app is not working.
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