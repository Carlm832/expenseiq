$ErrorActionPreference = "Stop"
Write-Host "Downloading Flutter SDK... This might take a few minutes as the file is large (~1.2GB)."
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip" -OutFile "flutter.zip"

Write-Host "Extracting Flutter SDK to C:\src\flutter..."
New-Item -ItemType Directory -Force -Path "C:\src"
Expand-Archive -Path "flutter.zip" -DestinationPath "C:\src" -Force

Write-Host "Adding Flutter to PATH..."
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($oldPath -notlike '*C:\src\flutter\bin*') {
    $newPath = $oldPath + ";C:\src\flutter\bin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

Write-Host "Cleaning up downloaded zip..."
Remove-Item "flutter.zip" -Force

Write-Host "Flutter installed successfully!"
