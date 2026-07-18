import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trivialy/home_screen.dart';
import 'package:trivialy/profile_service.dart';
import 'package:trivialy/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>{
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  String get _previewInitials {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final List<String> parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
  Future<void> _pickFromGallery() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _handleContinue() async {
    if (!_canContinue) return;

    setState(() => _isSaving = true);

    String? permanentImagePath;
    if (_selectedImage != null) {
      permanentImagePath = await _profileService.persistPickedImage(_selectedImage!);
    }

    final profile = UserProfile(
      name: _nameController.text.trim(),
      imagePath: permanentImagePath,
      );
      await _profileService.saveProfile(profile);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen()),
      );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(
            (screenWidth * 0.06).clamp(20.0, 28.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Welcome to Trivialy!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A)
                )
              ),
              const SizedBox(height: 6,),
              const Text(
                'Let\'s set up your profile before you get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickFromGallery,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2563EB),
                        ),
                        child:  _selectedImage != null
                            ? ClipOval(
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                            : Center(
                              child: Text(
                                _previewInitials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800
                                ),
                              )
                            )
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9), width: 2)
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF2563EB)),
                        )
                      )
                    ],
                  )
                ),
              ),
              const SizedBox(height: 10,),
              Center(
                child: Text(
                  _selectedImage != null ? 'Tap to change photo' : 'Tap to add a photo(optional)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                )
              ),
              const SizedBox(height: 32),
              const Text(
                'What should we call you?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                )
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4)
                    )
                  ]
                ),
                child: TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.normal,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue && !_isSaving
                    ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                   child: _isSaving
                     ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                     )
                     : const Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                     )
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}