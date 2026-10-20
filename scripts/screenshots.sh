#!/usr/bin/env bash
# Capturas para la App Store (iPhone 6.9", 1320×2868) en es-MX y en-US.
#   scripts/screenshots.sh            # deja los PNG en build/screenshots/<idioma>/
# Usa el modo de capturas de Debug (-screenshotTab / -screenshotListing, ver MainTabView.swift).
set -euo pipefail
cd "$(dirname "$0")/.."

BUNDLE="com.bener.VallartApp"
SALIDA="build/screenshots"
DD="build/screenshots/DerivedData"
DETALLE="65f51cd4-15d6-436e-b3e9-b996a26d6bcd"   # Four Seasons Resort Punta Mita
UDID=$(xcrun simctl list devices available | grep -m1 "iPhone 17 Pro Max" | grep -oE "[0-9A-F-]{36}")

echo "== Compilando (Debug, simulador)"
xcodebuild -project VallartApp.xcodeproj -scheme VallartApp -configuration Debug \
  -destination "id=$UDID" -derivedDataPath "$DD" build -quiet
APP="$DD/Build/Products/Debug-iphonesimulator/VallartApp.app"

echo "== Preparando el simulador ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light
xcrun simctl status_bar "$UDID" override --time "9:41" --dataNetwork wifi --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
xcrun simctl location "$UDID" set 20.6100,-105.2330            # Zona Romántica
xcrun simctl install "$UDID" "$APP"
xcrun simctl privacy "$UDID" grant location "$BUNDLE"
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" hasSeenOnboarding -bool YES

captura() {  # <idioma> <locale> <archivo> <args…>
  local lang=$1 locale=$2 nombre=$3; shift 3
  xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$BUNDLE" -AppleLanguages "($lang)" -AppleLocale "$locale" "$@" >/dev/null
  sleep 9   # que carguen datos y fotos
  # El servicio del simulador no puede escribir en volúmenes externos: primero a un temporal
  local tmp; tmp="$(mktemp -d)/$nombre.png"
  xcrun simctl io "$UDID" screenshot "$tmp" >/dev/null 2>&1
  mv "$tmp" "$SALIDA/$lang/$nombre.png"
  echo "   $lang/$nombre.png"
}

for par in "es es_MX" "en en_US"; do
  set -- $par
  rm -rf "${SALIDA:?}/$1" && mkdir -p "$SALIDA/$1"
  echo "== Capturas $1"
  captura "$1" "$2" 1-explorar -screenshotTab 0
  captura "$1" "$2" 2-detalle  -screenshotTab 0 -screenshotListing "$DETALLE"
  captura "$1" "$2" 3-mapa     -screenshotTab 1
  captura "$1" "$2" 4-eventos  -screenshotTab 2
  captura "$1" "$2" 5-buscar   -screenshotTab 4
done

xcrun simctl status_bar "$UDID" clear
echo "Listo: $SALIDA/es y $SALIDA/en"
