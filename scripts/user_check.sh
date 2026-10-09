
#!/usr/bin/env bash

# Kontrollime, kas kasutajanimi anti kaasa.
if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "VIGA: Sisesta kasutajanimi!"
    exit 2
fi

USERNAME="$1"

# Kontrollime kasutaja olemasolu süsteemis.
if getent passwd "$USERNAME" > /dev/null; then
    echo "Kasutaja $USERNAME eksisteerib."
    exit 0
else
    echo "Kasutajat $USERNAME ei eksisteeri."
    exit 1
fi
