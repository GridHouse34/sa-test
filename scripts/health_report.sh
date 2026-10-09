
#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/health_report.log"

mkdir -p "$LOG_DIR" || exit 1

echo "=== Süsteemikontroll: $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"

FAILED=0

for SCRIPT in system_info.sh disk_check.sh; do
    echo "--- $SCRIPT ---" | tee -a "$LOG_FILE"

    bash "$BASE_DIR/scripts/$SCRIPT" 2>&1 | tee -a "$LOG_FILE"
    STATUS=${PIPESTATUS[0]}

    if [ "$STATUS" -ne 0 ]; then
        FAILED=1
    fi
done

echo "--- SSH teenuse kontroll ---" | tee -a "$LOG_FILE"

bash "$BASE_DIR/scripts/service_check.sh" ssh 2>&1 | tee -a "$LOG_FILE"
STATUS=${PIPESTATUS[0]}

if [ "$STATUS" -ne 0 ]; then
    FAILED=1
fi

if [ "$FAILED" -eq 0 ]; then
    echo "Kõik kontrollid õnnestusid." | tee -a "$LOG_FILE"
else
    echo "HOIATUS: Vähemalt üks kontroll ebaõnnestus." | tee -a "$LOG_FILE"
fi

echo "Logifail: $LOG_FILE"

exit "$FAILED"
