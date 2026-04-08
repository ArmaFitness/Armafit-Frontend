import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/weight_entry.dart';

class WeightService {
  static Future<List<WeightEntry>> getEntries() async {
    final res = await ApiClient.get(ApiConstants.weight);
    return (res as List).map((e) => WeightEntry.fromJson(e)).toList();
  }

  static Future<WeightEntry> logWeight(double weightKg) async {
    final res = await ApiClient.post(ApiConstants.weight, {'weightKg': weightKg});
    return WeightEntry.fromJson(res);
  }
}
