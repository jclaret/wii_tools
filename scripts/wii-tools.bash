#!/bin/bash
set -e
set -o pipefail

# Define the URL for the file to download
WIT_URL="https://wit.wiimm.de/download/wit-v3.05a-r8638-x86_64.tar.gz"

# Define the directory where the file is downloaded and extracted
DIR="/tmp/wii"

# Define the downloaded file
FILE="$DIR/wit-v3.05a-r8638-x86_64.tar.gz"

# Function to handle errors
error() {
  echo "Error: $1"
  exit 1
}

# Function to print text in color
print_color() {
  printf '\033[0;34m%s\033[0m\n' "$1"
}

# Clean the workspace if necessary
if [ -f "$FILE" ]; then
    rm "$FILE"
fi

if [ -d "$DIR" ]; then
    rm -rf "$DIR"
fi

# Create the directory
mkdir -p "$DIR"

echo "Preparing to install WIT and WBFS Manager..."

# Use wget to download the file quietly
echo "Downloading WIT..."
if ! wget -q "$WIT_URL" -O "$FILE"; then
  error "Failed to download WIT"
fi

# Use tar to extract the file to the specific directory
echo "Extracting WIT..."
if ! tar -xzf "$FILE" -C "$DIR"; then
  error "Failed to extract WIT"
fi

# Find the extracted directory with the wit binary
WIT_DIR=$(find "$DIR" -type f -name "wit")

# Provide the command to add wit binary to PATH
if [ -f "$WIT_DIR" ]; then
  WIT_BIN_DIR=$(dirname "$WIT_DIR")
  print_color "To add WIT to your PATH and run wit command, run this command:"
  print_color " $ export PATH=\$PATH:$WIT_BIN_DIR"
  print_color " $ wit --help"
else
  error "Failed to find 'wit' binary"
fi

# Check if wbfs-manager is installed. If not, download it and install from the RPM package.
if rpm -q wbfs-manager >/dev/null 2>&1; then
  echo "WBFS Manager is already installed."
  print_color "You can now run WBFS Manager by executing 'wbfs_gtk'."
else
  echo "Note: Installing WBFS Manager requires root permissions."
  echo "Downloading WBFS Manager..."
  if ! sudo dnf download wbfs-manager -y --destdir="$DIR"; then
    error "Failed to download WBFS Manager"
  fi
  echo "Installing WBFS Manager..."
  if ! sudo dnf install "$DIR"/wbfs-manager*.rpm -y >/dev/null 2>&1; then
      error "Failed to install WBFS Manager"
  fi
  echo "WBFS Manager successfully installed!"
  print_color "You can now run WBFS Manager by executing 'wbfs_gtk'."
fi

echo "Installation process completed successfully!"
