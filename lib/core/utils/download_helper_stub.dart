import 'dart:typed_data';

/// Stub implementation for non-web platforms (VM, tests, etc.)
Future<void> downloadAssetImpl(String assetPath, String fileName) async {
  throw UnsupportedError(
    'Download is only supported on web platform. '
    'This app is designed for web deployment.',
  );
}
