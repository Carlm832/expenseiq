#!/bin/bash
set -e

OS_NAME=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS_NAME" == "Darwin" ]]; then
    echo "Detected macOS ($ARCH)..."
    if [ "$ARCH" = "arm64" ]; then
        FLUTTER_ZIP="flutter_macos_arm64_3.24.3-stable.zip"
    else
        FLUTTER_ZIP="flutter_macos_3.24.3-stable.zip"
    fi
    DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/$FLUTTER_ZIP"
    DEST_DIR="$HOME/src"
    BIN_DIR="$HOME/src/flutter/bin"
    PROFILE_FILE="$HOME/.zshrc"
    if [[ "$SHELL" == *"bash"* ]]; then
        PROFILE_FILE="$HOME/.bash_profile"
    fi
elif [[ "$OS_NAME" == MINGW* ]] || [[ "$OS_NAME" == CYGWIN* ]] || [[ "$OS_NAME" == MSYS* ]]; then
    echo "Detected Windows..."
    FLUTTER_ZIP="flutter_windows_3.24.3-stable.zip"
    DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/$FLUTTER_ZIP"
    DEST_DIR="/c/src"
    BIN_DIR="/c/src/flutter/bin"
    PROFILE_FILE="$HOME/.bash_profile"
else
    echo "Unsupported OS: $OS_NAME"
    exit 1
fi

echo "Downloading Flutter SDK... This might take a few minutes."
curl -o "$FLUTTER_ZIP" "$DOWNLOAD_URL"

echo "Extracting Flutter SDK to $DEST_DIR/flutter..."
mkdir -p "$DEST_DIR"
unzip -q -o "$FLUTTER_ZIP" -d "$DEST_DIR"

echo "Adding Flutter to PATH..."
touch "$PROFILE_FILE"
if ! grep -q "flutter/bin" "$PROFILE_FILE" 2>/dev/null; then
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$PROFILE_FILE"
    echo "Added flutter to PATH in $PROFILE_FILE."
    echo "You may need to run \`source $PROFILE_FILE\` or restart your terminal."
else
    echo "Flutter bin directory is already in your $PROFILE_FILE."
fi

# For Windows, also update the actual Windows User PATH registry via PowerShell so it's available in standard CMD/PowerShell windows
if [[ "$OS_NAME" == MINGW* ]] || [[ "$OS_NAME" == CYGWIN* ]] || [[ "$OS_NAME" == MSYS* ]]; then
    echo "Adding to Windows Environment Variables..."
    set +e
    powershell -NoProfile -ExecutionPolicy Bypass -Command "\$oldPath = [Environment]::GetEnvironmentVariable('Path', 'User'); if (\$oldPath -notlike '*C:\src\flutter\bin*') { [Environment]::SetEnvironmentVariable('Path', \$oldPath + ';C:\src\flutter\bin', 'User'); Write-Host 'Added to Windows User PATH.' }"
    set -e
fi

echo "Cleaning up downloaded zip..."
rm "$FLUTTER_ZIP"

echo "Flutter installed successfully!"
echo "Please restart your terminal and run 'flutter doctor' to verify."
