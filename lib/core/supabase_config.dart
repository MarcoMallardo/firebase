/// Configuración de Supabase.
///
/// Reemplazá los valores con los datos de tu proyecto de Supabase.
/// Los encontrás en: Dashboard → Settings → API.
class SupabaseConfig {
  SupabaseConfig._();

  /// URL de tu proyecto Supabase.
  /// Ejemplo: 'https://xyzcompany.supabase.co'
  static const String url = 'https://kvtqlhzhidjgyghvymxh.supabase.co';

  /// Clave pública (publishable key) de tu proyecto Supabase.
  /// Ejemplo: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...'
  static const String publishableKey = 'sb_publishable_s52d6dVhFUgDX4M1ksCGdw_walVdFFv';

  /// Nombre del bucket de Storage donde se guardarán las imágenes.
  /// Debés crearlo en: Dashboard → Storage → New Bucket.
  static const String bucketName = 'movie-posters';
}
