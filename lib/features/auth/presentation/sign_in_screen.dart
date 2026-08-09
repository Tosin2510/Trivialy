import 'package:flutter/material.dart';
import 'package:trivialy/core/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// This is the Google sign-in screen.
class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningIn = false;
  String? _errorMessage;

// This handles google sign in and any error that occur due to signing in.
  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try{
      final result = await _authService.signInWithGoogle();
      if (result == null && mounted) {
        setState(() => _isSigningIn = false);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Sign-in error: $e');
        setState(() {
          _errorMessage = 'Sign-in failed. Please try again.';
          _isSigningIn = false;
        });
      }
    }
  }

// Handles the build part.
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.all((screenWidth * 0.08).clamp(24.0, 32.0)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      // I added an asset image for the icon.
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                    )
                  ),
                  const SizedBox(height: 24,),
                  const Text(
                    'Welcome to Trivialy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  const Text(
                    'Sign in to save your progress and compete on the leaderboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // This handles any error that happens when signing in.
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626),  fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSigningIn ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      // Handles sign in and shows an indicator in the process of signing.
                      child: _isSigningIn
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2,),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              // The google sign in logo. It gets loaded from the internet.
                              'https://developers.google.com/identity/images/g-logo.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.login, size: 20);
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}