import 'package:dinari/src/core/config/DI/di_service.dart';
import 'package:dinari/src/core/config/firebase/firebase_options.dart';
import 'package:dinari/src/database/local/shared_preferences_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSetting {
  AppSetting._();
  static AppSetting instance = AppSetting._();
  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await Supabase.initialize(
        url:
            'https://jtdnrzlljqritpbwwyjp.supabase.co', // Replace with your Supabase Project URL
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0ZG5yemxsanFyaXRwYnd3eWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxNTk2NzksImV4cCI6MjA1NzczNTY3OX0.B9EkYzChGyZIjOw-eZqkApPRnlEehaUPgbc737sOF3E', // Replace with your Supabase anon key
      );

      await SharedPreferencesService.instance.init();

      DiService.instance.init();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (_) {
      rethrow;
    }
  }
}
