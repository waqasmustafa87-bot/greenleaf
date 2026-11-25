import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/plant_repository.dart';
import 'state/plant_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_PROJECT_URL'] ??
      dotenv.env['SUPABASE_URL'] ??
      '';
  final supabaseKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      dotenv.env['SUPABASE_ANON_KEY'] ??
      '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_PROJECT_URL or SUPABASE_PUBLISHABLE_KEY in .env',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  runApp(
    GreenleafApp(
      store: PlantStore(repository: SupabasePlantRepository()),
    ),
  );
}
