import 'package:flutter/foundation.dart';
import '../models/workout_plan.dart';
import '../services/workout_plan_service.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  List<WorkoutPlan> _plans = [];
  WorkoutPlan? _detail;
  bool _isLoading = false;
  String? _error;

  List<WorkoutPlan> get plans => _plans;
  WorkoutPlan? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _plans = await WorkoutPlanService.getPlans();
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
      _detail = await WorkoutPlanService.getPlan(id);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(WorkoutPlan plan) async {
    try {
      final created = await WorkoutPlanService.createPlan(plan);
      _plans.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assign(String planId, String userId) async {
    try {
      await WorkoutPlanService.assignPlan(planId, userId);
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
