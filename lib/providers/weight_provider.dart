import 'package:flutter/foundation.dart';
import '../models/weight_entry.dart';
import '../services/weight_service.dart';

class WeightProvider extends ChangeNotifier {
  List<WeightEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<WeightEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _entries = await WeightService.getEntries();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> log(double weightKg) async {
    try {
      final entry = await WeightService.logWeight(weightKg);
      _entries.insert(0, entry);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
