import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/workout_plan.dart';

class WorkoutPlanService {
  static Future<List<WorkoutPlan>> getPlans() async {
    final res = await ApiClient.get(ApiConstants.workoutPlans);
    return (res as List).map((p) => WorkoutPlan.fromJson(p)).toList();
  }

  static Future<WorkoutPlan> getPlan(String id) async {
    final res = await ApiClient.get('${ApiConstants.workoutPlans}/$id');
    return WorkoutPlan.fromJson(res);
  }

  static Future<WorkoutPlan> createPlan(WorkoutPlan plan) async {
    final res = await ApiClient.post(ApiConstants.workoutPlans, {
      'title': plan.title,
      'description': plan.description,
      'workouts': plan.workouts.map((w) => w.toJson()).toList(),
    });
    return WorkoutPlan.fromJson(res);
  }

  static Future<void> assignPlan(String planId, String userId) async {
    await ApiClient.post('${ApiConstants.workoutPlans}/$planId/assign', {'userId': userId});
  }
}
