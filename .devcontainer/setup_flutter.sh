#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa

if [ ! -x /workspaces/flutter/bin/flutter ]; then
  git clone \
    --branch stable \
    --depth 1 \
    https://github.com/flutter/flutter.git \
    /workspaces/flutter
fi

export PATH="/workspaces/flutter/bin:$PATH"

flutter config --no-enable-web
flutter config --no-enable-linux-desktop
flutter config --enable-android

flutter --version
dart --version

cd /workspaces/BilgiRotasi
flutter pub get
