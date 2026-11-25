import 'package:material_ui/material_ui.dart';

import '../data/sample_plants.dart';
import '../state/plant_store.dart';
import '../theme/greenleaf_theme.dart';

/// Form screen for adding a new plant to greenleaf.
class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({
    super.key,
    required this.store,
    required this.onPlantAdded,
    this.onError,
  });

  final PlantStore store;
  final ValueChanged<String> onPlantAdded;
  final ValueChanged<String>? onError;

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _careTipController = TextEditingController();

  String _selectedEmoji = plantEmojiChoices.first;
  String _selectedRoom = roomChoices.first;
  int _waterEveryDays = 5;
  bool _dueToday = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _careTipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final added = await widget.store.addPlant(
        name: _nameController.text,
        emoji: _selectedEmoji,
        room: _selectedRoom,
        waterEveryDays: _waterEveryDays,
        dueToday: _dueToday,
        careTip: _careTipController.text,
      );

      if (!mounted) return;
      _nameController.clear();
      _careTipController.clear();
      setState(() {
        _selectedEmoji = plantEmojiChoices.first;
        _selectedRoom = roomChoices.first;
        _waterEveryDays = 5;
        _dueToday = true;
      });

      widget.onPlantAdded(
        '${added.emoji} ${added.name} saved to ${added.room}!',
      );
    } catch (error) {
      widget.onError?.call('$error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          const Text(
            'Add Plant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: GreenleafColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a new green friend to your watering schedule.',
            style: TextStyle(
              fontSize: 13,
              color: GreenleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Pick an Emoji'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plantEmojiChoices.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? GreenleafColors.softYellow
                        : GreenleafColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? GreenleafColors.primaryGreen
                          : GreenleafColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Plant Name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('e.g. Monstera, Jasmine'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a plant name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Room'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roomChoices.map((room) {
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
            }).toList(),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Watering Schedule'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: GreenleafColors.mintSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GreenleafColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _waterEveryDays == 1
                        ? 'Water every 1 day'
                        : 'Water every $_waterEveryDays days',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: GreenleafColors.deepGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperButton(
                      icon: Icons.remove_rounded,
                      onPressed: _waterEveryDays > 1
                          ? () => setState(() => _waterEveryDays--)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _StepperButton(
                      icon: Icons.add_rounded,
                      onPressed: _waterEveryDays < 60
                          ? () => setState(() => _waterEveryDays++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _dueToday,
            onChanged: (value) => setState(() => _dueToday = value),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            tileColor: GreenleafColors.softYellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: GreenleafColors.warmYellow),
            ),
            activeThumbColor: GreenleafColors.primaryGreen,
            title: const Text(
              'Needs water today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: GreenleafColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Show right away on the Home screen',
              style: TextStyle(
                fontSize: 12,
                color: GreenleafColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Care Tip (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _careTipController,
            maxLines: 2,
            decoration: _inputDecoration('Sunlight or soil notes...'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: GreenleafColors.primaryGreen,
                foregroundColor: GreenleafColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: GreenleafColors.pureWhite,
                      ),
                    )
                  : const Icon(Icons.add_circle_outline_rounded),
              label: Text(
                _isSubmitting ? 'Saving...' : 'Save Plant',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GreenleafColors.pureWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GreenleafColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: GreenleafColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: GreenleafColors.primaryGreen,
          width: 1.8,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: GreenleafColors.textPrimary,
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GreenleafColors.pureWhite,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: GreenleafColors.deepGreen,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
