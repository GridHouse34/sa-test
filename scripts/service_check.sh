#!/usr/bin/env bash

# Kontrollime, kas teenuse nimi sisestati.
if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "VIGA: Sisesta teenuse nimi!"
    exit 2
fi

SERVICE="$1"

#Kontrollime, kas teenus on süsteemis olemas
if ! systemctl list-unit-files --type=service --no-legend |
    awk '{print $1}' |
    grep -Fxq "${SERVICE}.service"; then

    echo "VIGA: Teenust $SERVICE ei eksisteeri."
    exit 1
fi

# Kontrollime teenuse tegelikku olekut.
if systemctl is-active --quiet "${SERVICE}.service"; then
    echo "Teenus $SERVICE töötab."
    exit 0
else
    echo "Teenus $SERVICE ei tööta."
    exit 1
fi
