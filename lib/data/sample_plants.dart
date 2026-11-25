import '../models/plant.dart';

/// Initial 8 sample plants and preset options for greenleaf.
List<Plant> buildSamplePlants() {
  return const [
    Plant(
      id: 'money-plant',
      name: 'Money Plant',
      emoji: '🌿',
      room: 'Living Room',
      waterEveryDays: 5,
      daysUntilWater: 0,
      careTip: 'Thrives in bright indirect light. Let the top inch of soil dry between waterings.',
    ),
    Plant(
      id: 'aloe-vera',
      name: 'Aloe Vera',
      emoji: '🪴',
      room: 'Balcony',
      waterEveryDays: 10,
      daysUntilWater: 0,
      careTip: 'Loves sunny spots. Water deeply but infrequently so the roots stay healthy.',
    ),
    Plant(
      id: 'snake-plant',
      name: 'Snake Plant',
      emoji: '🎋',
      room: 'Bedroom',
      waterEveryDays: 14,
      daysUntilWater: 8,
      careTip: 'Very hardy and low maintenance. Avoid overwatering, especially in cooler months.',
    ),
    Plant(
      id: 'tulsi',
      name: 'Tulsi',
      emoji: '🌱',
      room: 'Kitchen',
      waterEveryDays: 2,
      daysUntilWater: 0,
      careTip: 'Needs morning sunlight and consistently moist (not soggy) soil.',
    ),
    Plant(
      id: 'rose',
      name: 'Rose',
      emoji: '🌹',
      room: 'Balcony',
      waterEveryDays: 3,
      daysUntilWater: 0,
      careTip: 'Water at the base in the morning and give at least 5 hours of direct sun.',
    ),
    Plant(
      id: 'mint',
      name: 'Mint',
      emoji: '🍃',
      room: 'Kitchen',
      waterEveryDays: 2,
      daysUntilWater: 1,
      careTip: 'Pinch top leaves regularly to keep it bushy and fragrant.',
    ),
    Plant(
      id: 'peace-lily',
      name: 'Peace Lily',
      emoji: '🪷',
      room: 'Study',
      waterEveryDays: 4,
      daysUntilWater: 0,
      careTip: 'Droops slightly when thirsty and perks right back up after a drink.',
    ),
    Plant(
      id: 'cactus',
      name: 'Cactus',
      emoji: '🌵',
      room: 'Study',
      waterEveryDays: 21,
      daysUntilWater: 12,
      careTip: 'Place on a bright windowsill and use fast-draining cactus mix.',
    ),
  ];
}

const List<String> plantEmojiChoices = [
  '🌿',
  '🪴',
  '🌱',
  '🌵',
  '🌹',
  '🍃',
  '🪷',
  '🎋',
  '🌻',
  '🌷',
  '🌺',
  '🌳',
];

const List<String> roomChoices = [
  'Living Room',
  'Balcony',
  'Bedroom',
  'Kitchen',
  'Study',
  'Patio',
];

const List<String> happyWateringMessages = [
  'is hydrated and glowing!',
  'says thank you for the fresh drink!',
  'is soaking up the good vibes!',
  'looks super happy and refreshed!',
];
