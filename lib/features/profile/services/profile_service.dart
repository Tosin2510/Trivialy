import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivialy/features/profile/models/user_profile.dart';

// This service handles the user profile, saving of their data, loading and allowing image selection.
class ProfileService {
  static const String _nameKey = 'profile_name';
  static const String _imagePathKey = 'profile_image_path';

// Checks if the profile setup has been completed.
  Future<bool> hasCompletedSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_nameKey);
  }

// Allows loadin gof the user profile from shared preference
// I used shared preference mostly because of the user image, i didn't want to go through the stress of saving that to firebase.
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

// Saves the profile to shared preference as well as to firebase.
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, profile.name);

    if (profile.hasCustomImage) {
      await prefs.setString(_imagePathKey, profile.imagePath!);
    } else {
      await prefs.remove(_imagePathKey);
    }

    // I am saving the user name to firestore so that the name can reflect on the leaderboard for the weekly challenge.
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final existing = await docRef.get();

      final Map<String, dynamic> data = {'name' : profile.name};
      if (!existing.exists || existing.data()?['joinedAt'] == null) {
        data['joinedAt'] = FieldValue.serverTimestamp();
      }
      await docRef.set(data, SetOptions(merge: true));
    }
  }

// This part gets when the user joined the app.
  Future<DateTime?> getJoinedDate(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final Timestamp? timestamp = doc.data()?['joinedAt'] as Timestamp?;
    return timestamp?.toDate();
  }

// gets the path of the selected image by user and save it directlt to the app's own directory.
  Future<String> persistPickedImage(File pickedFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String extension = pickedFile.path.split('.').last;
    final String newPath = '${appDir.path}/profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final File savedFile = await pickedFile.copy(newPath);
    return savedFile.path;
  }
}