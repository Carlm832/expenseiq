import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateManifest {
  final String version;
  final int buildNumber;
  final String releaseNotes;
  final String apkUrl;

  UpdateManifest({
    required this.version,
    required this.buildNumber,
    required this.releaseNotes,
    required this.apkUrl,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    return UpdateManifest(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? 0,
      releaseNotes: json['releaseNotes'] ?? '',
      apkUrl: json['apkUrl'] ?? '',
    );
  }
}

class UpdateService {
  static const String _manifestUrl = 'https://expenseiqapp.com/version.json';
  static const String _fallbackDownloadPage = 'https://expenseiqapp.com/#download';

  Future<UpdateManifest?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_manifestUrl));
      if (response.statusCode == 200) {
        final manifest = UpdateManifest.fromJson(jsonDecode(response.body));
        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

        if (manifest.buildNumber > currentBuildNumber) {
          return manifest;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Update check failed: $e');
    }
    return null;
  }

  /// Downloads the APK in-app, then opens the system installer.
  Future<bool> downloadAndInstallApk(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamed = await http.Client().send(request);
      if (streamed.statusCode != 200) return false;

      final totalBytes = streamed.contentLength ?? 0;
      final bytes = <int>[];
      var received = 0;

      await for (final chunk in streamed.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(received / totalBytes);
        }
      }

      onProgress?.call(1.0);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ExpenseIQ-update.apk');
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      return result.type == ResultType.done;
    } catch (e) {
      // ignore: avoid_print
      print('In-app update failed: $e');
      return false;
    }
  }

  /// Browser fallback when in-app download/install fails.
  Future<bool> launchUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url.isNotEmpty ? url : _fallbackDownloadPage);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ignore: avoid_print
      print('Update launch failed: $e');
      return false;
    }
  }
}
