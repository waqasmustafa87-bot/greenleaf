import 'package:flutter_test/flutter_test.dart';
import 'package:greenleaf/app.dart';
import 'package:greenleaf/data/plant_repository.dart';
import 'package:greenleaf/data/sample_plants.dart';
import 'package:greenleaf/models/plant.dart';
import 'package:greenleaf/state/plant_store.dart';
import 'package:greenleaf/widgets/phone_frame.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('Plant.fromJson computes due days and wateredToday accurately', () {
    final now = DateTime(2026, 11, 25, 14, 0);
    final duePlant = Plant.fromJson({
      'id': 'uuid-1',
      'name': 'Money Plant',
      'emoji': '🌿',
      'room': 'Living Room',
      'water_every_days': 5,
      'next_water_date': '2026-11-25',
      'last_watered_at': null,
      'care_tip': 'Bright indirect light.',
    }, now: now);

    expect(duePlant.isDueToday, isTrue);
    expect(duePlant.wateredToday, isFalse);

    final wateredPlant = Plant.fromJson({
      'id': 'uuid-2',
      'name': 'Tulsi',
      'emoji': '🌱',
      'room': 'Kitchen',
      'water_every_days': 2,
      'next_water_date': '2026-11-27',
      'last_watered_at': '2026-11-25T10:00:00Z',
    }, now: now);

    expect(wateredPlant.isDueToday, isFalse);
    expect(wateredPlant.daysUntilWater, 2);
    expect(wateredPlant.wateredToday, isTrue);
  });

  test('PlantStore logs watering_log entry when waterPlant is called', () async {
    final repo = InMemoryPlantRepository();
    final store = PlantStore(repository: repo);

    final msg = await store.waterPlant('money-plant');
    expect(msg, contains('Money Plant'));
    expect(repo.wateringLogs, hasLength(1));
    expect(repo.wateringLogs.first['plant_id'], 'money-plant');
    expect(repo.wateringLogs.first['plant_name'], 'Money Plant');

    await store.addPlant(
      name: 'Lavender',
      emoji: '🪷',
      room: 'Balcony',
      waterEveryDays: 4,
      dueToday: true,
    );
    expect(store.plants.first.name, 'Lavender');
  });

  testWidgets('displays 8 sample plants and waters a plant with happy message', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GreenleafApp());

    expect(find.text('greenleaf'), findsOneWidget);
    expect(find.text('Money Plant'), findsOneWidget);
    expect(find.text('5 plants need water'), findsOneWidget);

    await tester.tap(find.text('Watered').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Yay! Money Plant'), findsWidgets);
    expect(find.text('4 plants need water'), findsOneWidget);

    await tester.tap(find.text('My Plants'));
    await tester.pumpAndSettle();
    expect(find.text('8 plants'), findsOneWidget);

    final plantListFinder = find.descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    );
    for (final sample in buildSamplePlants()) {
      await tester.scrollUntilVisible(
        find.text(sample.name),
        180,
        scrollable: plantListFinder,
      );
      expect(find.text(sample.name), findsWidgets);
    }
  });

  testWidgets('opens Plant Details and adds a new plant', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GreenleafApp());

    expect(find.text('9:41'), findsNothing);

    await tester.tap(find.text('Money Plant'));
    await tester.pumpAndSettle();
    expect(find.text('Plant Details'), findsOneWidget);
    expect(find.text('Water every 5 days'), findsOneWidget);

    await tester.tap(find.text('Watered'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Yay! Money Plant'), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Plant'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Basil');
    await tester.ensureVisible(find.text('Save Plant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Plant'));
    await tester.pumpAndSettle();

    expect(find.text('5 plants need water'), findsOneWidget);
    expect(find.text('Basil'), findsOneWidget);
  });

  testWidgets('renders phone frame on laptop width and full screen on phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneFrameWrapper(
          child: Scaffold(body: Center(child: Text('Inside'))),
        ),
      ),
    );

    expect(find.text('9:41'), findsOneWidget);
    expect(find.text('Inside'), findsOneWidget);
  });
}
