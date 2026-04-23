import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env.production");
    } catch (e) {
      debugPrint("Gagal memuat .env.production: $e");
      rethrow;
    }
    
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
