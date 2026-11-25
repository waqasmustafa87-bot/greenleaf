import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/plant_card.dart';

/// Screen listing all plants with room filtering.
class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({
    super.key,
    required this.store,
    required this.onOpenPlant,
  });

  final PlantStore store;
  final ValueChanged<Plant> onOpenPlant;

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  String _selectedRoom = 'All';

  @override
  Widget build(BuildContext context) {
    final rooms = ['All', ...widget.store.availableRooms];
    if (!rooms.contains(_selectedRoom)) {
      _selectedRoom = 'All';
    }

    final filteredPlants = _selectedRoom == 'All'
        ? widget.store.plants
        : widget.store.plants
            .where((plant) => plant.room == _selectedRoom)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Plants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: GreenleafColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: GreenleafColors.softYellow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.store.plants.length} plants',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: GreenleafColors.sunText,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isSelected = room == _selectedRoom;
              return ChoiceChip(
                label: Text(room),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedRoom = room),
                selectedColor: GreenleafColors.primaryGreen,
                backgroundColor: GreenleafColors.pureWhite,
                side: BorderSide(
                  color: isSelected
                      ? GreenleafColors.primaryGreen
                      : GreenleafColors.borderLight,
                ),
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? GreenleafColors.pureWhite
                      : GreenleafColors.textPrimary,
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filteredPlants.isEmpty
              ? const Center(
                  child: Text(
                    'No plants in this room yet.',
                    style: TextStyle(color: GreenleafColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filteredPlants.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final plant = filteredPlants[index];
                    return PlantCard(
                      plant: plant,
                      onTap: () => widget.onOpenPlant(plant),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
