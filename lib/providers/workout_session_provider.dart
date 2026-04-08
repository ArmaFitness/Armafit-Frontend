import 'package:flutter/foundation.dart';
import '../models/workout_session.dart';
import '../services/workout_session_service.dart';

class WorkoutSessionProvider extends ChangeNotifier {
  List<WorkoutSession> _sessions = [];
  WorkoutSession? _detail;
  bool _isLoading = false;
  String? _error;

  List<WorkoutSession> get sessions => _sessions;
  WorkoutSession? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await WorkoutSessionService.getSessions();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _detail = await WorkoutSessionService.getSession(id);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> logSession({
    String? workoutPlanId,
    String? notes,
    required List<SessionSet> sets,
  }) async {
    try {
      final session = await WorkoutSessionService.logSession(
        workoutPlanId: workoutPlanId,
        notes: notes,
        sets: sets,
      );
      _sessions.insert(0, session);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
  }
}
