// lib/utils/shared_prefs.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  // Keys
  static const String _candidateIdKey = 'candidate_id';
  static const String _dobKey = 'candidate_dob';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save candidate credentials after successful login
  Future<void> saveCredentials(String candidateId, String dob) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_candidateIdKey, candidateId);
      await prefs.setString(_dobKey, dob);
      await prefs.setBool(_isLoggedInKey, true);
      debugPrint('Credentials saved successfully');
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Get candidate ID
  Future<String?> getCandidateId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_candidateIdKey);
    } catch (e) {
      debugPrint('Error getting candidate ID: $e');
      return null;
    }
  }

  // Get candidate DOB
  Future<String?> getCandidateDob() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_dobKey);
    } catch (e) {
      debugPrint('Error getting candidate DOB: $e');
      return null;
    }
  }

  // Clear all credentials (logout)
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_candidateIdKey);
      await prefs.remove(_dobKey);
      await prefs.setBool(_isLoggedInKey, false);
      debugPrint('Credentials cleared successfully');
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }
}
