/// Flutter ABI-split APKs encode the Android versionCode as:
/// `(abiPrefix * 1000) + buildNumber` (arm64 prefix is 2).
int logicalBuildNumber(String rawBuildNumber) {
  final code = int.tryParse(rawBuildNumber) ?? 0;
  if (code >= 1000) {
    return code % 1000;
  }
  return code;
}
