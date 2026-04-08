// TODO: Change baseUrl to match your backend
// Android emulator → http://10.0.2.2:3000
// iOS simulator / web → http://localhost:3000
// Physical device → http://<your-machine-ip>:3000
// Production → https://your-api-domain.com
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // Bodyweight
  static const String weight = '/api/weight';

  // Workout Plans
  static const String workoutPlans = '/api/workout-plans';

  // Workout Sessions
  static const String workoutSessions = '/api/workout-sessions';

  // Coach-Athlete
  static const String assignAthlete = '/api/coach-athlete/assign-athlete';
  static const String assignCoach = '/api/coach-athlete/assign-coach';
  static const String athletes = '/api/coach-athlete/athletes';
  static const String coaches = '/api/coach-athlete/coaches';

  // Messages
  static const String messages = '/api/messages';
  static const String conversations = '/api/messages/conversations';
}
