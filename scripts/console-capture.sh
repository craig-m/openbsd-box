#!/usr/bin/env sh
#
# console-capture.sh – attach to the VM serial console and capture output
#
# The serial console is routed to a file by the hypervisor.  This script
# watches that file for new data (like 'tail -f') and optionally timestamps
# each line.  It is most useful when fuzzing or stress-testing: if the kernel
# panics, the crash message appears on the serial console even when SSH is gone.
#
# Usage:
#   ./scripts/console-capture.sh                        # watch /tmp/openbsd-serial.log
#   ./scripts/console-capture.sh <path-to-serial-log>   # watch a specific file
#   SERIAL_LOG=builds/v7.8.../serial.log ./scripts/console-capture.sh
#
# The script exits automatically if the hypervisor closes the serial device
# (i.e. the VM has shut down or crashed).

SERIAL_LOG="${1:-${SERIAL_LOG:-/tmp/openbsd-serial.log}}"

if [ ! -e "${SERIAL_LOG}" ]; then
  echo "[console-capture] Waiting for serial log to appear: ${SERIAL_LOG}"
  # Poll until the file exists (hypervisor creates it when the VM starts)
  while [ ! -e "${SERIAL_LOG}" ]; do
    sleep 1
  done
fi

echo "[console-capture] Attaching to: ${SERIAL_LOG}"
echo "[console-capture] Press Ctrl-C to stop."
echo "------------------------------------------------------------------------"

# Use 'tail -F' so that we follow the file even if it is rotated or recreated.
# Each line is timestamped with the host time for correlation with other logs.
tail -F "${SERIAL_LOG}" 2>/dev/null | while IFS= read -r LINE; do
  printf '[%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "${LINE}"
done

echo "------------------------------------------------------------------------"
echo "[console-capture] Done."
