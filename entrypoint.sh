#!/bin/sh
# Actualiza suricata
suricata-update

# Ejecuta suricata con los parámetros dados en docker run si tiene o usa unso por defecto
if [ $# -gt 0 ]; then
	suricata $@
else
	suricata -c /etc/suricata/suricata.yaml --af-packet
fi
