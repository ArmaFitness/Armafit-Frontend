import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../models/user.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    final res = await ApiClient.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    return _saveAndReturn(res);
  }

  static Future<User> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    required bool isAthlete,
    required bool isCoach,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.register,
      {
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
        'isAthlete': isAthlete,
        'isCoach': isCoach,
      },
      auth: false,
    );
    return _saveAndReturn(res);
  }

  static Future<User> _saveAndReturn(dynamic res) async {
    final token = res['token'] ?? res['accessToken'] ?? res['jwt'];
    if (token != null) await StorageService.saveToken(token.toString());
    final userJson = res['user'] ?? res;
    final user = User.fromJson(userJson as Map<String, dynamic>);
    await StorageService.saveUserInfo(
      userId: user.id,
      name: user.name,
      surname: user.surname,
      isAthlete: user.isAthlete,
      isCoach: user.isCoach,
    );
    return user;
  }

  static Future<void> logout() => StorageService.clear();
}
