import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/services.dart';

/// Loads a Flutter asset and triggers a browser file download.
Future<void> downloadAsset(String assetPath, String fileName) async {
  final ByteData data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
