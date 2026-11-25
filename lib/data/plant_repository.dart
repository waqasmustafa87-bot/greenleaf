import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sample_plants.dart';
import '../models/plant.dart';

/// Persistence contract for loading and updating plants and watering logs.
abstract class PlantRepository {
  bool get shouldAutoLoad => true;

  Future<List<Plant>> fetchPlants();

  Future<Plant> createPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required bool dueToday,
    String careTip = '',
  });

  Future<Plant> markWatered(Plant plant, {String note = ''});

  Future<void> deletePlant(String id);
}

/// Supabase-backed implementation reading/writing `plants` and `watering_log`.
class SupabasePlantRepository implements PlantRepository {
  SupabasePlantRepository({SupabaseClient? client}) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  @override
  bool get shouldAutoLoad => true;

  @override
  Future<List<Plant>> fetchPlants() async {
    final rows = await _client
        .from('plants')
        .select()
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => Plant.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<Plant> createPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required bool dueToday,
    String careTip = '',
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDate =
        dueToday ? today : today.add(Duration(days: waterEveryDays));

    final row = await _client
        .from('plants')
        .insert({
          'name': name.trim(),
          'emoji': emoji,
          'room': room.trim(),
          'water_every_days': waterEveryDays,
          'next_water_date': _formatDate(nextDate),
          'care_tip': careTip.trim(),
        })
        .select()
        .single();

    return Plant.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<Plant> markWatered(Plant plant, {String note = ''}) async {
    final nowLocal = DateTime.now();
    final nowUtc = nowLocal.toUtc();
    final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final nextDate = today.add(Duration(days: plant.waterEveryDays));

    await _client.from('watering_log').insert({
      'plant_id': plant.id,
      'plant_name': plant.name,
      'watered_at': nowUtc.toIso8601String(),
      'note': note,
    });

    final updated = await _client
        .from('plants')
        .update({
          'last_watered_at': nowUtc.toIso8601String(),
          'next_water_date': _formatDate(nextDate),
        })
        .eq('id', plant.id)
        .select()
        .single();

    return Plant.fromJson(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> deletePlant(String id) async {
    await _client.from('plants').delete().eq('id', id);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// In-memory repository used for offline preview and widget tests.
class InMemoryPlantRepository implements PlantRepository {
  InMemoryPlantRepository({List<Plant>? initialPlants})
      : _items = List<Plant>.from(initialPlants ?? buildSamplePlants());

  final List<Plant> _items;
  final List<Map<String, dynamic>> wateringLogs = [];

  @override
  bool get shouldAutoLoad => false;

  @override
  Future<List<Plant>> fetchPlants() async => List<Plant>.unmodifiable(_items);

  @override
  Future<Plant> createPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required bool dueToday,
    String careTip = '',
  }) async {
    final plant = Plant(
      id: 'plant-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      room: room.trim(),
      waterEveryDays: waterEveryDays,
      daysUntilWater: dueToday ? 0 : waterEveryDays,
      careTip: careTip.trim(),
    );
    _items.insert(0, plant);
    return plant;
  }

  @override
  Future<Plant> markWatered(Plant plant, {String note = ''}) async {
    final now = DateTime.now();
    wateringLogs.add({
      'plant_id': plant.id,
      'plant_name': plant.name,
      'watered_at': now.toIso8601String(),
      'note': note,
    });
    final updated = plant.copyWith(
      daysUntilWater: plant.waterEveryDays,
      wateredToday: true,
      lastWateredAt: now,
    );
    final idx = _items.indexWhere((p) => p.id == plant.id);
    if (idx != -1) _items[idx] = updated;
    return updated;
  }

  @override
  Future<void> deletePlant(String id) async {
    _items.removeWhere((p) => p.id == id);
  }
}
