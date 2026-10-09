
#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"

DATE=$(date '+%Y%m%d_%H%M%S')
ARCHIVE="$BACKUP_DIR/backup_$DATE.tar.gz"

# Kontrollime lähtekausta.
if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "VIGA: Varundatav kaust puudub: $BACKUP_SOURCE"
    exit 1
fi

mkdir -p "$BACKUP_DIR" || exit 1

echo "Varukoopia loomine..."

# Loome päris gzip-tihendusega tar-arhiivi.
if ! tar -czf "$ARCHIVE" \
    -C "$(dirname "$BACKUP_SOURCE")" \
    "$(basename "$BACKUP_SOURCE")"; then
    echo "VIGA: Varukoopia loomine ebaõnnestus!"
    rm -f "$ARCHIVE"
    exit 1
fi

# Kontrollime arhiivi terviklikkust.
if ! gzip -t "$ARCHIVE" || ! tar -tzf "$ARCHIVE" > /dev/null; then
    echo "VIGA: Varukoopia kontroll ebaõnnestus!"
    rm -f "$ARCHIVE"
    exit 1
fi

echo "Varukoopia valmis: $ARCHIVE"
echo "Failide arv: $(find "$BACKUP_SOURCE" -type f | wc -l)"
exit 0
