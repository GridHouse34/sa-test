#!/usr/bin/env bash

# Kontrollime, kas teenuse nimi sisestati.
if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "VIGA: Sisesta teenuse nimi!"
    exit 2
fi

SERVICE="$1"

# Kontrollime teenuse tegelikku olekut.
if systemctl is-active --quiet "${SERVICE}.service"; then
    echo "Teenus $SERVICE töötab."
    exit 0
else
    echo "Teenus $SERVICE ei tööta või ei eksisteeri."
    exit 1
fi
