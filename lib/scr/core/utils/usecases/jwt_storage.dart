import 'package:shared_preferences/shared_preferences.dart';

class JwtStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';
  static const String _profileIdKey = 'profile_id';

  static const String _doctorIdKey = 'doctor_id';
  static const String _doctorFullNameKey = 'doctor_full_name';

  static Future<void> saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_doctorIdKey, doctorId);
  }

  static Future<int?> getDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_doctorIdKey);
  }

  static Future<void> saveDoctorFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doctorFullNameKey, fullName);
  }

  static Future<String?> getDoctorFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_doctorFullNameKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> saveProfileId(int profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_profileIdKey, profileId);
  }

  static Future<int?> getProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileIdKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_profileIdKey);
  }
}