import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingService {
  static const String _keyOnboardingDone = 'onboarding_completed';
  static const String _keyInterestsDone = 'interests_completed';
  static const String _keyGender = 'selected_gender';

  // ONBOARDING (gender)
  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<String?> getLocalGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGender);
  }

  static Future<void> saveOnboarding({required String gender}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGender, gender);
    await prefs.setBool(_keyOnboardingDone, true);
  }

  // INTERESTS
  static Future<bool> isInterestsDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInterestsDone) ?? false;
  }

  static Future<void> saveInterestsDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInterestsDone, true);
  }

  // FIRESTORE
  static Future<void> saveGenderToFirestore({
    required String uid,
    required String gender,
  }) async {
    if (gender.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'gender': gender,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}