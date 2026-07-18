import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivialy/user_profile.dart';

class ProfileService {
  static const String _nameKey = 'profile_name';
  static const String _imagePathKey = 'profile_image_path';

  Future<bool> hasCompletedSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_nameKey);
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString(_nameKey);
    if (name == null) return null;

    final String? imagePath = prefs.getString(_imagePathKey);
    return UserProfile(
      name: name,
      imagePath: imagePath
      );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, profile.name);

    if (profile.hasCustomImage) {
      await prefs.setString(_imagePathKey, profile.imagePath!);
    } else {
      await prefs.remove(_imagePathKey);
    }
  }

  Future<String> persistPickedImage(File pickedFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String extension = pickedFile.path.split('.').last;
    final String newPath = '${appDir.path}/profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final File savedFile = await pickedFile.copy(newPath);
    return savedFile.path;
  }
}