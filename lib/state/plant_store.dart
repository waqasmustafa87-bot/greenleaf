import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/plant_repository.dart';
import '../data/sample_plants.dart';
import '../models/plant.dart';

/// Holds and mutates the user's plant collection for greenleaf.
class PlantStore extends ChangeNotifier {
  PlantStore({
    PlantRepository? repository,
    List<Plant>? initialPlants,
  })  : _repository = repository ?? InMemoryPlantRepository(initialPlants: initialPlants),
        _plants = List<Plant>.from(initialPlants ??
            ((repository == null || !repository.shouldAutoLoad)
                ? buildSamplePlants()
                : const []));

  final PlantRepository _repository;
  List<Plant> _plants;
  int _happyMessageIndex = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get shouldAutoLoad => _repository.shouldAutoLoad;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Plant> get plants => List.unmodifiable(_plants);

  List<Plant> get dueTodayPlants =>
      _plants.where((plant) => plant.isDueToday).toList();

  List<Plant> get wateredTodayPlants =>
      _plants.where((plant) => plant.wateredToday).toList();

  List<String> get availableRooms {
    final rooms = <String>{};
    for (final plant in _plants) {
      rooms.add(plant.room);
    }
    return rooms.toList()..sort();
  }

  Plant? findById(String id) {
    for (final plant in _plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  /// Loads plants from the configured repository (Supabase in production).
  Future<void> loadPlants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = await _repository.fetchPlants();
    } on PostgrestException catch (error) {
      _errorMessage = error.code == 'PGRST205'
          ? 'Supabase connected, but the "plants" table does not exist yet. Run the SQL in your Supabase SQL Editor, then tap Retry.'
          : 'Supabase error: ${error.message}';
    } catch (error) {
      _errorMessage = 'Could not load plants from Supabase: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs a watering event in `watering_log` and updates the plant's next date.
  Future<String> waterPlant(String id) async {
    final index = _plants.indexWhere((plant) => plant.id == id);
    if (index == -1) return 'Plant watered!';

    final plant = _plants[index];
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.markWatered(plant);
      final currentIndex = _plants.indexWhere((p) => p.id == id);
      if (currentIndex != -1) {
        _plants[currentIndex] = updated;
      }

      final suffix = happyWateringMessages[
          _happyMessageIndex % happyWateringMessages.length];
      _happyMessageIndex++;
      return '${updated.emoji} Yay! ${updated.name} $suffix';
    } on PostgrestException catch (error) {
      throw Exception('Failed to save watering_log: ${error.message}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Adds a new plant to Supabase `plants` and updates local state.
  Future<Plant> addPlant({
    required String name,
    required String emoji,
    required String room,
    required int waterEveryDays,
    required bool dueToday,
    String careTip = '',
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createPlant(
        name: name,
        emoji: emoji,
        room: room,
        waterEveryDays: waterEveryDays,
        dueToday: dueToday,
        careTip: careTip,
      );
      _plants.insert(0, created);
      return created;
    } on PostgrestException catch (error) {
      throw Exception('Failed to save plant: ${error.message}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Deletes a plant by [id] from Supabase and local state.
  Future<void> deletePlant(String id) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.deletePlant(id);
      _plants.removeWhere((plant) => plant.id == id);
    } on PostgrestException catch (error) {
      throw Exception('Failed to delete plant: ${error.message}');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
