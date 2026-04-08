import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../core/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get initialized => _initialized;

  Future<void> init() async {
    final info = await StorageService.getUserInfo();
    final token = await StorageService.getToken();
    if (info != null && token != null) {
      _user = User(
        id: info['userId'] ?? '',
        name: info['name'] ?? '',
        surname: info['surname'] ?? '',
        email: '',
        isAthlete: info['isAthlete'] ?? false,
        isCoach: info['isCoach'] ?? false,
      );
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await AuthService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    required bool isAthlete,
    required bool isCoach,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await AuthService.register(
        name: name,
        surname: surname,
        email: email,
        password: password,
        isAthlete: isAthlete,
        isCoach: isCoach,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
