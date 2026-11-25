/// Represents a houseplant tracked in greenleaf.
class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.room,
    required this.waterEveryDays,
    required this.daysUntilWater,
    this.careTip = '',
    this.wateredToday = false,
    this.lastWateredAt,
  });

  final String id;
  final String name;
  final String emoji;
  final String room;
  final int waterEveryDays;
  final int daysUntilWater;
  final String careTip;
  final bool wateredToday;
  final DateTime? lastWateredAt;

  /// Builds a [Plant] from a Supabase `plants` table row.
  factory Plant.fromJson(Map<String, dynamic> json, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);

    final rawNextDate = json['next_water_date'] as String?;
    final parsedNext =
        rawNextDate != null ? DateTime.tryParse(rawNextDate) : null;
    final nextDay = parsedNext != null
        ? DateTime(parsedNext.year, parsedNext.month, parsedNext.day)
        : today;

    final rawLastWatered = json['last_watered_at'] as String?;
    final parsedLastWatered = rawLastWatered != null
        ? DateTime.tryParse(rawLastWatered)?.toLocal()
        : null;

    final wasWateredToday = parsedLastWatered != null &&
        parsedLastWatered.year == today.year &&
        parsedLastWatered.month == today.month &&
        parsedLastWatered.day == today.day;

    return Plant(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? 'Plant',
      emoji: (json['emoji'] as String?) ?? '🌱',
      room: (json['room'] as String?) ?? 'Living Room',
      waterEveryDays: (json['water_every_days'] as num?)?.toInt() ?? 5,
      daysUntilWater: nextDay.difference(today).inDays,
      careTip: (json['care_tip'] as String?) ?? '',
      wateredToday: wasWateredToday,
      lastWateredAt: parsedLastWatered,
    );
  }

  /// Whether this plant needs watering today (or is overdue).
  bool get isDueToday => daysUntilWater <= 0;

  /// Human-readable watering cadence label.
  String get scheduleLabel =>
      waterEveryDays == 1 ? 'Water every 1 day' : 'Water every $waterEveryDays days';

  /// Human-readable status for the next watering.
  String get dueStatusLabel {
    if (wateredToday) return 'Watered today';
    if (daysUntilWater < 0) {
      final overdue = -daysUntilWater;
      return overdue == 1 ? '1 day overdue' : '$overdue days overdue';
    }
    if (daysUntilWater == 0) return 'Water today';
    if (daysUntilWater == 1) return 'Water tomorrow';
    return 'In $daysUntilWater days';
  }

  /// Returns a copy of this plant with updated fields.
  Plant copyWith({
    String? id,
    String? name,
    String? emoji,
    String? room,
    int? waterEveryDays,
    int? daysUntilWater,
    String? careTip,
    bool? wateredToday,
    DateTime? lastWateredAt,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      room: room ?? this.room,
      waterEveryDays: waterEveryDays ?? this.waterEveryDays,
      daysUntilWater: daysUntilWater ?? this.daysUntilWater,
      careTip: careTip ?? this.careTip,
      wateredToday: wateredToday ?? this.wateredToday,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
    );
  }
}
