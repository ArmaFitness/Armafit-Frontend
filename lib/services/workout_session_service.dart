import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/workout_session.dart';

class WorkoutSessionService {
  static Future<List<WorkoutSession>> getSessions() async {
    final res = await ApiClient.get(ApiConstants.workoutSessions);
    return (res as List).map((s) => WorkoutSession.fromJson(s)).toList();
  }

  static Future<WorkoutSession> getSession(String id) async {
    final res = await ApiClient.get('${ApiConstants.workoutSessions}/$id');
    return WorkoutSession.fromJson(res);
  }

  static Future<WorkoutSession> logSession({
    String? workoutPlanId,
    String? notes,
    required List<SessionSet> sets,
  }) async {
    final body = <String, dynamic>{
      'sets': sets.map((s) => s.toJson()).toList(),
    };
    if (workoutPlanId != null) body['workoutPlanId'] = workoutPlanId;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    final res = await ApiClient.post(ApiConstants.workoutSessions, body);
    return WorkoutSession.fromJson(res);
  }
}
