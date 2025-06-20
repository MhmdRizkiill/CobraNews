import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasbesar/models/user_models.dart';


class UserService {
  static const String _userKey = 'user_data';
  static UserModel? _currentUser;

  // Get current user
  static UserModel getCurrentUser() {
    return _currentUser ?? UserModel(
      id: '1',
      name: 'Dede Yamal',
      email: 'DedeYamal@Barca.id',
      phone: '+62 812-3456-7890',
      bio: 'Seorang pembaca berita yang antusias dan selalu update dengan informasi terkini.',
      joinDate: DateTime(2024, 1, 1),
    );
  }

  // Update user profile
  static Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(updatedUser.copyWith(
        lastUpdated: DateTime.now(),
      ).toJson());
      
      await prefs.setString(_userKey, userJson);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Load user from storage
  static Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // Save profile image
  static Future<String?> saveProfileImage(File imageFile) async {
    try {
      // In a real app, you would save to app documents directory
      // For now, we'll just return the file path
      return imageFile.path;
    } catch (e) {
      print('Error saving profile image: $e');
      return null;
    }
  }
}
