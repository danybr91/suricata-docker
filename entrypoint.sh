#!/bin/sh

# Update suricata rules (first time)
if [ ! -f /var/run/suricata.pid ]; then
    suricata-update
fi

if [ -f /etc/suricata/logrotate.conf ]; then
   chown root /etc/suricata/logrotate.conf
   chmod 0640 /etc/suricata/logrotate.conf
fi

# Start cron
crond

# Add cronjob
crontab /etc/crontabs/suricata-update-cron
crontab /etc/crontabs/logrotate-cron


# pidfile is required for logrotate
if [ -f /var/run/suricata.pid ]; then
    rm -f /var/run/suricata.pid
fi

# Start suricata (and pass extra arguments from CMD)
suricata -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid "$@"
