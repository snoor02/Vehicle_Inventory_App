import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;

  // Call once early in app startup
  static Future<void> init({required String url, required String anonKey}) async {
    if (_initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Uploads image bytes to the given bucket and path.
  /// Returns the public URL (assuming bucket public or has a public policy).
  static Future<String> uploadImage({
    required Uint8List bytes,
    required String bucket,
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    final storage = client.storage;
    try {
  // Debug logs for INSERT (upload)
  // These will appear in `flutter run` terminal output.
  // Format: [Supabase] Uploading/Uploaded/Public URL
  //
  print('[Supabase] Uploading to $bucket/$path (contentType=$contentType)');
      await storage
          .from(bucket)
          .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType, upsert: true));
  print('[Supabase] Upload successful: $bucket/$path');

      // Build public URL; ensure bucket has public read or use signed URLs for access.
      final publicUrl = storage.from(bucket).getPublicUrl(path);
  print('[Supabase] Public URL: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      // Common cause: Storage RLS denies insert (403). Requires a policy allowing writes.
  print('[Supabase] Upload failed: ${e.message}');
  throw StorageException('Upload failed (likely RLS 403). Configure a storage policy to allow inserts. Details: ${e.message}');
    }
  }
}
