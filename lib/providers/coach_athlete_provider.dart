import 'package:flutter/foundation.dart';
import '../models/coach_athlete.dart';
import '../services/coach_athlete_service.dart';

class CoachAthleteProvider extends ChangeNotifier {
  List<CoachAthleteUser> _athletes = [];
  List<CoachAthleteUser> _coaches = [];
  bool _isLoading = false;
  String? _error;

  List<CoachAthleteUser> get athletes => _athletes;
  List<CoachAthleteUser> get coaches => _coaches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAthletes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _athletes = await CoachAthleteService.getAthletes();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCoaches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _coaches = await CoachAthleteService.getCoaches();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> assignAthlete(String email) async {
    try {
      await CoachAthleteService.assignAthlete(email);
      await loadAthletes();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignCoach(String email) async {
    try {
      await CoachAthleteService.assignCoach(email);
      await loadCoaches();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
