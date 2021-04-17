#!/bin/sh

# Update suricata rules (first time)
if [ ! -f /var/run/suricata.pid ]; then
    suricata-update
fi

# Start cron
crond

# Add cronjob
crontab /etc/crontabs/suricata-update-cron

# Start suricata (and pass extra arguments from CMD)
# pidfile is required for logrotate
if [ -f /var/run/suricata.pid ]; then
    rm -f /var/run/suricata.pid
fi

# Esta versión tiene en cuenta los argumentos CMD
#suricata -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid "$@"
# Esta versión tiene en cuenta el entorno ENV porque así puede especificarse en el docker-compose los parámetros deseados. #TODO ¿riesgo de seguridad?
suricata -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid "$SURICATA_ARGS"