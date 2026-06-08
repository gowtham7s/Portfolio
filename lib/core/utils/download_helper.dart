// Conditional import: use web implementation on web, stub on other platforms
import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart';

/// Loads a Flutter asset and triggers a browser file download.
/// 
/// On web: Downloads the file using dart:html blob and anchor element.
/// On non-web platforms: Throws UnsupportedError.
Future<void> downloadAsset(String assetPath, String fileName) async {
  return downloadAssetImpl(assetPath, fileName);
}
