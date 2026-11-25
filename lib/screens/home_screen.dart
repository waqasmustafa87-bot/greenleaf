import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';
import '../widgets/plant_card.dart';

/// Home screen displaying today's plants that need watering.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.onOpenPlant,
    required this.onWaterPlant,
    required this.onGoToAllPlants,
  });

  final PlantStore store;
  final ValueChanged<Plant> onOpenPlant;
  final Future<void> Function(Plant) onWaterPlant;
  final VoidCallback onGoToAllPlants;

  @override
  Widget build(BuildContext context) {
    if (store.isLoading && store.plants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: GreenleafColors.primaryGreen),
            SizedBox(height: 12),
            Text(
              'Loading plants from Supabase...',
              style: TextStyle(
                color: GreenleafColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final duePlants = store.dueTodayPlants;
    final wateredToday = store.wateredTodayPlants;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (store.errorMessage != null) ...[
          _SupabaseNoticeCard(
            message: store.errorMessage!,
            onRetry: store.loadPlants,
          ),
          const SizedBox(height: 14),
        ],
        _TodaySummaryBanner(
          dueCount: duePlants.length,
          totalCount: store.plants.length,
          wateredTodayCount: wateredToday.length,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Watering",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: GreenleafColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${duePlants.length} due',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: GreenleafColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (duePlants.isEmpty)
          _AllCaughtUpCard(onBrowsePlants: onGoToAllPlants)
        else
          ...duePlants.map(
            (plant) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlantCard(
                plant: plant,
                onTap: () => onOpenPlant(plant),
                onWater: () => onWaterPlant(plant),
              ),
            ),
          ),
        if (wateredToday.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Watered Today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GreenleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...wateredToday.map(
            (plant) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlantCard(
                plant: plant,
                onTap: () => onOpenPlant(plant),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SupabaseNoticeCard extends StatelessWidget {
  const _SupabaseNoticeCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GreenleafColors.softYellow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GreenleafColors.warmYellow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: GreenleafColors.sunText,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Supabase Setup Needed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: GreenleafColors.sunText,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12.5,
              color: GreenleafColors.sunText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryBanner extends StatelessWidget {
  const _TodaySummaryBanner({
    required this.dueCount,
    required this.totalCount,
    required this.wateredTodayCount,
  });

  final int dueCount;
  final int totalCount;
  final int wateredTodayCount;

  @override
  Widget build(BuildContext context) {
    final allDone = dueCount == 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allDone
              ? const [GreenleafColors.mintSurface, GreenleafColors.softYellow]
              : const [GreenleafColors.primaryGreen, GreenleafColors.deepGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: allDone
            ? Border.all(color: GreenleafColors.borderLight)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: allDone
                  ? GreenleafColors.pureWhite
                  : GreenleafColors.softYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              allDone ? '🌞' : '💧',
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone
                      ? 'All plants are happy!'
                      : '$dueCount ${dueCount == 1 ? 'plant needs' : 'plants need'} water',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: allDone
                        ? GreenleafColors.deepGreen
                        : GreenleafColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allDone
                      ? 'You watered $wateredTodayCount today across $totalCount plants.'
                      : 'Tap "Watered" once you give them a fresh drink.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: allDone
                        ? GreenleafColors.textSecondary
                        : const Color(0xFFE0F2E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCaughtUpCard extends StatelessWidget {
  const _AllCaughtUpCard({required this.onBrowsePlants});

  final VoidCallback onBrowsePlants;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: GreenleafColors.softYellow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GreenleafColors.warmYellow),
      ),
      child: Column(
        children: [
          const Text('🌿✨', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 8),
          const Text(
            'Nothing left to water today!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: GreenleafColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your greenleaf garden is thriving and hydrated.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: GreenleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBrowsePlants,
            style: OutlinedButton.styleFrom(
              foregroundColor: GreenleafColors.deepGreen,
              side: const BorderSide(color: GreenleafColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'View My Plants',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
