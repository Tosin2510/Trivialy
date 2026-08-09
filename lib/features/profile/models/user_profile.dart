
// A model for the user's profile, with their name and image...
class UserProfile {
  final String name;
  final String? imagePath;

  const UserProfile({
    required this.name,
    this.imagePath,
  });
  bool get hasCustomImage => imagePath != null;

// This part gets the initials of the user, 
// I added this in case the user selects no image.
  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}