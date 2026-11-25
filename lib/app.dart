import 'package:material_ui/material_ui.dart';

import 'models/plant.dart';
import 'screens/add_plant_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_plants_screen.dart';
import 'screens/plant_details_screen.dart';
import 'state/plant_store.dart';
import 'theme/greenleaf_theme.dart';
import 'widgets/phone_frame.dart';

/// Root widget for the greenleaf plant care app.
class GreenleafApp extends StatefulWidget {
  const GreenleafApp({super.key, this.store});

  final PlantStore? store;

  @override
  State<GreenleafApp> createState() => _GreenleafAppState();
}

class _GreenleafAppState extends State<GreenleafApp> {
  late final PlantStore _store = widget.store ?? PlantStore();
  late final bool _ownsStore = widget.store == null;

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'greenleaf',
      debugShowCheckedModeBanner: false,
      theme: buildGreenleafTheme(),
      builder: (context, child) {
        return PhoneFrameWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: GreenleafShell(store: _store),
    );
  }
}

/// Main tabbed shell with Home, My Plants, and Add Plant navigation.
class GreenleafShell extends StatefulWidget {
  const GreenleafShell({super.key, required this.store});

  final PlantStore store;

  @override
  State<GreenleafShell> createState() => _GreenleafShellState();
}

class _GreenleafShellState extends State<GreenleafShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.store.shouldAutoLoad) {
      Future.microtask(widget.store.loadPlants);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError ? Colors.red.shade700 : GreenleafColors.deepGreen,
          content: Row(
            children: [
              Text(isError ? '⚠️' : '✨', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _openPlantDetails(Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailsScreen(
          store: widget.store,
          plantId: plant.id,
        ),
      ),
    );
  }

  Future<void> _waterPlant(Plant plant) async {
    try {
      final message = await widget.store.waterPlant(plant.id);
      _showToast(message);
    } catch (error) {
      _showToast('$error', isError: true);
    }
  }

  void _handlePlantAdded(String confirmationMessage) {
    setState(() => _selectedIndex = 0);
    _showToast(confirmationMessage);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final pages = [
          HomeScreen(
            store: widget.store,
            onOpenPlant: _openPlantDetails,
            onWaterPlant: _waterPlant,
            onGoToAllPlants: () => setState(() => _selectedIndex = 1),
          ),
          MyPlantsScreen(
            store: widget.store,
            onOpenPlant: _openPlantDetails,
          ),
          AddPlantScreen(
            store: widget.store,
            onPlantAdded: _handlePlantAdded,
            onError: (msg) => _showToast(msg, isError: true),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: GreenleafColors.mintSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GreenleafColors.borderLight),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🌱', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'greenleaf',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: GreenleafColors.deepGreen,
                  ),
                ),
              ],
            ),
            actions: [
              if (widget.store.shouldAutoLoad)
                IconButton(
                  tooltip: 'Refresh from Supabase',
                  onPressed:
                      widget.store.isLoading ? null : widget.store.loadPlants,
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_florist_outlined),
                selectedIcon: Icon(Icons.local_florist_rounded),
                label: 'My Plants',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded),
                label: 'Add Plant',
              ),
            ],
          ),
        );
      },
    );
  }
}
