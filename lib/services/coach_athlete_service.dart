import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/coach_athlete.dart';

class CoachAthleteService {
  static Future<void> assignAthlete(String athleteEmail) async {
    await ApiClient.post(ApiConstants.assignAthlete, {'athleteEmail': athleteEmail});
  }

  static Future<void> assignCoach(String coachEmail) async {
    await ApiClient.post(ApiConstants.assignCoach, {'coachEmail': coachEmail});
  }

  static Future<List<CoachAthleteUser>> getAthletes() async {
    final res = await ApiClient.get(ApiConstants.athletes);
    return (res as List).map((u) => CoachAthleteUser.fromJson(u)).toList();
  }

  static Future<List<CoachAthleteUser>> getCoaches() async {
    final res = await ApiClient.get(ApiConstants.coaches);
    return (res as List).map((u) => CoachAthleteUser.fromJson(u)).toList();
  }
}
