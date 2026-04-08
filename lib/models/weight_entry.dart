class WeightEntry {
  final String id;
  final double weightKg;
  final DateTime loggedAt;

  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        id: j['id']?.toString() ?? '',
        weightKg: (j['weightKg'] ?? 0).toDouble(),
        loggedAt: DateTime.tryParse(
                j['loggedAt'] ?? j['createdAt'] ?? '') ??
            DateTime.now(),
      );
}
