import 'package:supabase_flutter/supabase_flutter.dart';

/// إعدادات Supabase
class SupabaseConfig {
  // TODO: استبدل هذه القيم بقيم مشروعك من لوحة تحكم Supabase
  // https://app.supabase.com/project/_/settings/api
  
  static const String supabaseUrl = 'https://jjooxmznzjuduhbqlihi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impqb294bXpuemp1ZHVoYnFsaWhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxODAzMjgsImV4cCI6MjA3OTc1NjMyOH0.mDri-w6YVXgcTOYryf7QEwT7o-b152KnteFRhdVq99o';

  /// تهيئة Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// الحصول على عميل Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  /// الحصول على عميل المصادقة
  static GoTrueClient get auth => client.auth;
}
