import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_config.dart';

/// Servicio para subir imágenes a Supabase Storage compatible con Web y Móvil.
class SupabaseStorageService {
  SupabaseStorageService._();

  static final _storage = Supabase.instance.client.storage;
  static const _uuid = Uuid();

  /// Sube los bytes de una imagen al bucket configurado en [SupabaseConfig].
  ///
  /// Retorna la URL pública de la imagen si la subida fue exitosa.
  /// Si el upload falla, lanza un [StorageException] automáticamente.
  static Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final uniqueName = '${_uuid.v4()}.$extension';

    final contentType = mimeType ??
        (extension == 'png'
            ? 'image/png'
            : extension == 'webp'
                ? 'image/webp'
                : 'image/jpeg');

    await _storage.from(SupabaseConfig.bucketName).uploadBinary(
          uniqueName,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: contentType,
          ),
        );

    final publicUrl =
        _storage.from(SupabaseConfig.bucketName).getPublicUrl(uniqueName);

    debugPrint('Imagen subida exitosamente: $publicUrl');
    return publicUrl;
  }
}
