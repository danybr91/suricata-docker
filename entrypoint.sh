#!/bin/sh

# Update suricata rules (first time)
if [ ! -f /var/run/suricata.pid ]; then
    suricata-update
fi

# Start cron
crond

# Add cronjob
crontab /etc/crontabs/suricata-update-cron


# pidfile is required for logrotate
if [ -f /var/run/suricata.pid ]; then
    rm -f /var/run/suricata.pid
fi

# Start suricata (and pass extra arguments from CMD)
suricata -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid "$@"