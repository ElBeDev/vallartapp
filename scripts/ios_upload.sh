#!/usr/bin/env bash
# Archiva VallartApp, la firma para la App Store y la sube a App Store Connect (TestFlight).
#   scripts/ios_upload.sh              # archiva, firma y sube
#   scripts/ios_upload.sh --sin-subir  # todo menos la subida (deja el .ipa en build/appstore/ipa)
# Requisitos: cuenta de Apple Developer en Xcode (equipo R53X7496V2) y la app creada en App Store Connect
# con el bundle com.bener.VallartApp. Mismo flujo que Omeyocan (tools/testflight.sh).
set -euo pipefail
cd "$(dirname "$0")/.."

TEAM="R53X7496V2"
SALIDA="build/appstore"
# Número de build siempre creciente: minutos desde 1970, así dos subidas nunca chocan.
BUILD=$(( $(date +%s) / 60 ))
DESTINO="upload"
[[ "${1:-}" == "--sin-subir" ]] && DESTINO="export"

rm -rf "$SALIDA" && mkdir -p "$SALIDA"

echo "== Archivando (build $BUILD)"
xcodebuild -project VallartApp.xcodeproj -scheme VallartApp -configuration Release \
  -destination "generic/platform=iOS" -archivePath "$SALIDA/VallartApp.xcarchive" \
  -derivedDataPath "$SALIDA/DerivedData" -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM" CODE_SIGN_STYLE=Automatic CURRENT_PROJECT_VERSION="$BUILD" archive -quiet

cat >"$SALIDA/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>$DESTINO</string>
  <key>teamID</key><string>$TEAM</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
  <key>testFlightInternalTestingOnly</key><false/>
</dict>
</plist>
EOF

echo "== Firmando para la App Store y $( [[ $DESTINO == upload ]] && echo 'subiendo' || echo 'guardando el .ipa')"
xcodebuild -exportArchive -archivePath "$SALIDA/VallartApp.xcarchive" -exportPath "$SALIDA/ipa" \
  -exportOptionsPlist "$SALIDA/ExportOptions.plist" -allowProvisioningUpdates 2>&1 | tee "$SALIDA/subida.log" || true

if grep -q "App record with bundle identifier" "$SALIDA/subida.log"; then
  echo "La app aún no existe en App Store Connect: créala (My Apps → + → New App) y vuelve a correr esto." >&2
  exit 2
fi
grep -q "EXPORT SUCCEEDED\|Upload succeeded\|Uploaded" "$SALIDA/subida.log" || { echo "Falló la firma o la subida (ver $SALIDA/subida.log)." >&2; exit 1; }

VERSION=$(/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$SALIDA/VallartApp.xcarchive/Info.plist")
if [[ $DESTINO == export ]]; then
  echo "Listo: VallartApp $VERSION ($BUILD), sin subir: el .ipa está en $SALIDA/ipa."
else
  echo "Listo: VallartApp $VERSION ($BUILD). Aparece en App Store Connect → TestFlight cuando Apple la procese (5–30 min)."
fi
