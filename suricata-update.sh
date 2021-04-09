#!/bin/sh
# TODO ¿suricata-update recarga las reglas en una instancia de suricata o hay que hacerlo de forma manual?
/usr/bin/suricata-update && \
/usr/bin/suricatasc -c ruleset-reload-nonblocking