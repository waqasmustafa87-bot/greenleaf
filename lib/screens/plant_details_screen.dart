import 'package:material_ui/material_ui.dart';

import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';

/// Displays full details and care actions for a single plant.
class PlantDetailsScreen extends StatefulWidget {
  const PlantDetailsScreen({
    super.key,
    required this.store,
    required this.plantId,
  });

  final PlantStore store;
  final String plantId;

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  String? _happyMessage;
  bool _isBusy = false;

  Future<void> _markWatered() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final message = await widget.store.waterPlant(widget.plantId);
      if (!mounted) return;
      setState(() => _happyMessage = message);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('$error'),
          ),
        );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmDelete(String plantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove $plantName?'),
        content: const Text(
          'This removes the plant from your greenleaf collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.store.deletePlant(widget.plantId);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Removed $plantName.')));
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade700,
              content: Text('$error'),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final plant = widget.store.findById(widget.plantId);
        if (plant == null) {
          return const Scaffold(
            body: Center(child: Text('Plant not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Plant Details',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Remove plant',
                onPressed: () => _confirmDelete(plant.name),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: plant.isDueToday
                          ? const [
                              GreenleafColors.softYellow,
                              GreenleafColors.mintSurface,
                            ]
                          : const [
                              GreenleafColors.mintSurface,
                              GreenleafColors.pureWhite,
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: GreenleafColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: GreenleafColors.pureWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GreenleafColors.warmYellow,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          plant.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        plant.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: GreenleafColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: GreenleafColors.pureWhite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: GreenleafColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.room_outlined,
                              size: 15,
                              color: GreenleafColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plant.room,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: GreenleafColors.deepGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_happyMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GreenleafColors.softYellow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: GreenleafColors.warmYellow),
                    ),
                    child: Row(
                      children: [
                        const Text('🌞', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _happyMessage!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: GreenleafColors.sunText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.schedule_rounded,
                        label: 'Schedule',
                        value: plant.scheduleLabel,
                        accentBg: GreenleafColors.mintSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.water_drop_outlined,
                        label: 'Status',
                        value: plant.dueStatusLabel,
                        accentBg: plant.isDueToday
                            ? GreenleafColors.softYellow
                            : GreenleafColors.mintSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GreenleafColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GreenleafColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            size: 18,
                            color: GreenleafColors.sunGold,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Care Tip',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: GreenleafColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant.careTip.isEmpty
                            ? 'Check soil moisture with your finger before watering and keep in bright indirect light.'
                            : plant.careTip,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: GreenleafColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _isBusy ? null : _markWatered,
                    style: FilledButton.styleFrom(
                      backgroundColor: GreenleafColors.primaryGreen,
                      foregroundColor: GreenleafColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.water_drop_rounded),
                    label: Text(
                      _isBusy ? 'Saving...' : 'Watered',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentBg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GreenleafColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: GreenleafColors.deepGreen),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GreenleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: GreenleafColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
