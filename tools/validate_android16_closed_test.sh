#!/usr/bin/env bash
set -euo pipefail

APKS="dist/BilgiRotasi-${VERSION_LABEL}-closed-test.apks"
java -jar "$RUNNER_TEMP/bundletool.jar" install-apks --apks="$APKS"
adb logcat -c
adb shell pm clear com.leventua.bilgirotasi
adb shell am force-stop com.leventua.bilgirotasi
adb shell am start -W -n com.leventua.bilgirotasi/.MainActivity

wait_for_text() {
  local expected="$1"
  for _ in $(seq 1 30); do
    adb shell uiautomator dump /sdcard/window.xml >/dev/null 2>&1 || true
    adb pull /sdcard/window.xml reports/window.xml >/dev/null 2>&1 || true
    if grep -Fq "$expected" reports/window.xml; then return 0; fi
    sleep 2
  done
  return 1
}

tap_text() {
  local expected="$1"
  adb shell uiautomator dump /sdcard/window.xml >/dev/null
  adb pull /sdcard/window.xml reports/window.xml >/dev/null
  local point
  point="$(python3 - "$expected" <<'PY'
import re, sys, xml.etree.ElementTree as ET
target = sys.argv[1]
root = ET.parse('reports/window.xml').getroot()
for node in root.iter('node'):
    if node.attrib.get('text') == target or node.attrib.get('content-desc') == target:
        values = [int(value) for value in re.findall(r'\d+', node.attrib['bounds'])]
        print((values[0] + values[2]) // 2, (values[1] + values[3]) // 2)
        raise SystemExit(0)
raise SystemExit(1)
PY
  )"
  adb shell input tap $point
}

wait_for_text 'Google ile giriş yap'
cp reports/window.xml reports/UI_GOOGLE_SIGN_IN.xml
grep -Fq 'Misafir olarak devam et' reports/UI_GOOGLE_SIGN_IN.xml
! grep -Fq 'Bilgi Rotası Nasıl Oynanır?' reports/UI_GOOGLE_SIGN_IN.xml

tap_text 'Misafir olarak devam et'
wait_for_text 'BİLGİ ROTASI'
cp reports/window.xml reports/UI_HOME.xml
grep -Fq 'Oyna' reports/UI_HOME.xml

for _ in $(seq 1 5); do
  adb shell uiautomator dump /sdcard/window.xml >/dev/null
  adb pull /sdcard/window.xml reports/window.xml >/dev/null
  grep -Fq 'Ayarlar' reports/window.xml && break
  adb shell input swipe 540 1600 540 450 500
done
tap_text 'Ayarlar'
wait_for_text 'Ayarlar'

for _ in $(seq 1 6); do
  adb shell uiautomator dump /sdcard/window.xml >/dev/null
  adb pull /sdcard/window.xml reports/window.xml >/dev/null
  grep -Fq 'Eğitimi Yeniden Göster' reports/window.xml && break
  adb shell input swipe 540 1650 540 400 500
done
tap_text 'Eğitimi Yeniden Göster'
wait_for_text 'Bilgi Rotası Nasıl Oynanır?'
cp reports/window.xml reports/UI_TUTORIAL_DIALOG.xml
grep -Fq 'Anladım' reports/UI_TUTORIAL_DIALOG.xml
tap_text 'Anladım'
sleep 2
adb shell uiautomator dump /sdcard/window.xml >/dev/null
adb pull /sdcard/window.xml reports/UI_TUTORIAL_CLOSED.xml >/dev/null
! grep -Fq 'Bilgi Rotası Nasıl Oynanır?' reports/UI_TUTORIAL_CLOSED.xml

adb logcat -d > reports/COLD_START_LOGCAT.txt
test -n "$(adb shell pidof com.leventua.bilgirotasi | tr -d '\r')"
! grep -Eqi 'FATAL EXCEPTION|AndroidRuntime.*FATAL|Missing application ID|MobileAdsInitProvider.*IllegalStateException' reports/COLD_START_LOGCAT.txt
adb shell dumpsys activity activities | grep -Fq com.leventua.bilgirotasi
