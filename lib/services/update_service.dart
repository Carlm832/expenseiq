import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
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
  static const String _manifestUrl = 'https://expenseiq-official.netlify.app/version.json';

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

  Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
