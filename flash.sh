#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

# lib_deps uses symlink://../arduino, so the repo must be reachable as ../arduino
[ -e ../arduino ] || ln -s "$(basename "$PWD")" ../arduino

PORT=/dev/cu.usbmodem1101

# By default, keep NVS (WiFi credentials + HomeKit pairing) and SPIFFS across a
# flash. Pass --erase to do a full chip erase first (wipes those).
ERASE=0
for arg in "$@"; do
  case "$arg" in
    --erase) ERASE=1 ;;
    *) echo "unknown option: $arg (only --erase is supported)" >&2; exit 1 ;;
  esac
done

pio run -e esp32-c3
if [ "$ERASE" -eq 1 ]; then
  pio run -e esp32-c3 -t erase --upload-port "$PORT"
fi
pio run -e esp32-c3 -t upload --upload-port "$PORT"
pio device monitor -e esp32-c3 -p "$PORT"
