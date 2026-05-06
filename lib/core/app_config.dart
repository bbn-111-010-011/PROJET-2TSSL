/// Configuration centralisée de Supabase.
///
/// Cette configuration évite de retaper les informations Supabase à chaque
/// lancement. Elle utilise l'URL et la publishable key fournies.
/// Important : ne jamais mettre une clé `service_role` dans une application Flutter.
class AppConfig {
  static const String supabaseUrlCode = 'https://uysnraxhnduvuysxrmvg.supabase.co';
  static const String supabaseAnonKeyCode = 'sb_publishable_-_xz3bTEgg7GkrybHStPMw_K2aBtFUx';

  static const String _urlFromCommand = String.fromEnvironment('SUPABASE_URL');
  static const String _keyFromCommand = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get supabaseUrl => _urlFromCommand.isNotEmpty ? _urlFromCommand : supabaseUrlCode;
  static String get supabaseAnonKey => _keyFromCommand.isNotEmpty ? _keyFromCommand : supabaseAnonKeyCode;

  static bool get isSupabaseConfigured {
    return supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('.supabase.co') &&
        supabaseAnonKey.length > 30;
  }
}
