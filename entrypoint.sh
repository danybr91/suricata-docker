#!/bin/sh

# Update suricata rules
suricata-update

# Start cron
crond

# Add cronjob
crontab /etc/crontabs/suricata-update-cron

# Start suricata (and pass extra arguments from CMD)
# pidfile is required for logrotate
suricata -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid "$@"