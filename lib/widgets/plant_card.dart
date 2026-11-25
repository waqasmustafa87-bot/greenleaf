import 'package:material_ui/material_ui.dart';

import '../models/plant.dart';
import '../theme/greenleaf_theme.dart';

/// Reusable card displaying a plant's emoji, room, watering schedule, and
/// an optional quick "Watered" action button.
class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.onWater,
  });

  final Plant plant;
  final VoidCallback onTap;
  final VoidCallback? onWater;

  @override
  Widget build(BuildContext context) {
    final isDue = plant.isDueToday;
    final avatarBg =
        isDue ? GreenleafColors.softYellow : GreenleafColors.mintSurface;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDue
                            ? GreenleafColors.warmYellow
                            : GreenleafColors.borderLight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      plant.emoji,
                      style: const TextStyle(fontSize: 27),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: GreenleafColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${plant.room}  •  ${plant.scheduleLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: GreenleafColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (onWater == null) ...[
                          const SizedBox(height: 6),
                          _StatusPill(plant: plant),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: GreenleafColors.textSecondary,
                  ),
                ],
              ),
              if (onWater != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(child: _StatusPill(plant: plant)),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: onWater,
                      style: FilledButton.styleFrom(
                        backgroundColor: GreenleafColors.primaryGreen,
                        foregroundColor: GreenleafColors.pureWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.water_drop_rounded, size: 15),
                      label: const Text(
                        'Watered',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final isDue = plant.isDueToday;
    final bgColor =
        isDue ? GreenleafColors.softYellow : GreenleafColors.mintSurface;
    final textColor =
        isDue ? GreenleafColors.sunText : GreenleafColors.deepGreen;
    final icon = isDue
        ? Icons.wb_sunny_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              plant.dueStatusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
