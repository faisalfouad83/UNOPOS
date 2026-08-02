import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/supabase/supabase_client_provider.dart';
import 'core/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseSupabaseBackend) {
    await initSupabase();
  }
  runApp(const ProviderScope(child: UnoposApp()));
}
