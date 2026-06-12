import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_version.dart';

enum UpdatePhase { downloading, installing }

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

class UpdateDownloadResult {
  final bool downloaded;
  final bool installLaunched;
  final bool needsInstallPermission;

  const UpdateDownloadResult({
    required this.downloaded,
    this.installLaunched = false,
    this.needsInstallPermission = false,
  });
}

class UpdateService {
  static const String _manifestUrl = 'https://expenseiqapp.com/version.json';
  static const String _fallbackDownloadPage = 'https://expenseiqapp.com/#download';
  static const MethodChannel _installChannel =
      MethodChannel('com.expenseiq/expense_iq/installer');

  Future<UpdateManifest?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_manifestUrl));
      if (response.statusCode == 200) {
        final manifest = UpdateManifest.fromJson(jsonDecode(response.body));
        final packageInfo = await PackageInfo.fromPlatform();
        final currentBuildNumber =
            logicalBuildNumber(packageInfo.buildNumber);

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

  /// Downloads the APK in-app, then opens the Android package installer.
  Future<UpdateDownloadResult> downloadAndInstallApk(
    String url, {
    void Function(double progress)? onProgress,
    void Function(UpdatePhase phase)? onPhase,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return const UpdateDownloadResult(downloaded: false);
    }

    try {
      onPhase?.call(UpdatePhase.downloading);

      final canInstall = await _installChannel.invokeMethod<bool>(
            'canInstallPackages',
          ) ??
          true;
      if (!canInstall) {
        return const UpdateDownloadResult(
          downloaded: false,
          needsInstallPermission: true,
        );
      }

      final request = http.Request('GET', Uri.parse(url));
      final streamed = await http.Client().send(request);
      if (streamed.statusCode != 200) {
        return const UpdateDownloadResult(downloaded: false);
      }

      final totalBytes = streamed.contentLength ?? 0;
      var received = 0;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ExpenseIQ-update.apk');
      if (await file.exists()) {
        await file.delete();
      }

      final sink = file.openWrite();
      try {
        await for (final chunk in streamed.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (totalBytes > 0 && onProgress != null) {
            onProgress(received / totalBytes);
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      onProgress?.call(1.0);
      onPhase?.call(UpdatePhase.installing);

      final installLaunched = await _launchInstaller(file.path);
      return UpdateDownloadResult(
        downloaded: true,
        installLaunched: installLaunched,
      );
    } catch (e) {
      // ignore: avoid_print
      print('In-app update failed: $e');
      return const UpdateDownloadResult(downloaded: false);
    }
  }

  Future<bool> _launchInstaller(String filePath) async {
    try {
      final launched = await _installChannel.invokeMethod<bool>(
        'installApk',
        {'path': filePath},
      );
      if (launched == true) return true;
    } catch (e) {
      // ignore: avoid_print
      print('Native installer failed: $e');
    }

    final result = await OpenFilex.open(
      filePath,
      type: 'application/vnd.android.package-archive',
    );
    return result.type == ResultType.done;
  }

  Future<bool> openInstallPermissionSettings() async {
    try {
      return await _installChannel.invokeMethod<bool>(
            'openInstallPermissionSettings',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Browser fallback only when the in-app download itself fails.
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
