import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userSurnameKey = 'user_surname';
  static const _isAthleteKey = 'is_athlete';
  static const _isCoachKey = 'is_coach';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserInfo({
    required String userId,
    required String name,
    required String surname,
    required bool isAthlete,
    required bool isCoach,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userSurnameKey, surname);
    await prefs.setBool(_isAthleteKey, isAthlete);
    await prefs.setBool(_isCoachKey, isCoach);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    if (userId == null) return null;
    return {
      'userId': userId,
      'name': prefs.getString(_userNameKey) ?? '',
      'surname': prefs.getString(_userSurnameKey) ?? '',
      'isAthlete': prefs.getBool(_isAthleteKey) ?? false,
      'isCoach': prefs.getBool(_isCoachKey) ?? false,
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
