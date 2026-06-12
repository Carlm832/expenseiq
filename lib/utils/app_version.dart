/// Flutter ABI-split APKs encode the Android versionCode as:
/// `(abiPrefix * 1000) + buildNumber` (arm64 prefix is 2).
int logicalBuildNumber(String rawBuildNumber) {
  final code = int.tryParse(rawBuildNumber) ?? 0;
  if (code >= 1000) {
    return code % 1000;
  }
  return code;
}

int logicalBuildNumberFromInt(int code) =>
    logicalBuildNumber(code.toString());

/// Encoded arm64 versionCode for [logicalBuild] (used in version.json during
/// transition so older builds still detect updates).
int arm64VersionCode(int logicalBuild) => 2000 + logicalBuild;
