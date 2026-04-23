import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static Future<void> init() async {
    // Load .env.production in release mode, otherwise load .env
    final fileName = kReleaseMode ? ".env.production" : ".env";
    
    try {
      await dotenv.load(fileName: fileName);
    } catch (e) {
      // Fallback to .env if specific file not found
      if (fileName != ".env") {
        await dotenv.load(fileName: ".env");
      } else {
        rethrow;
      }
    }
    
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
