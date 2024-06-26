# Fichero de despliegue de suricata más básico, con suricata precompilado desde el repositorio de alpine.
# Imagen base
FROM alpine:latest

ARG TZ
ARG VERSION

# Configurar el sistema
RUN apk add tzdata vim --no-cache && \
    cp /usr/share/zoneinfo/"$TZ" /etc/localtime && \
    echo "$TZ" >  /etc/timezone

# Dependencias del sistema
#https://pkgs.alpinelinux.org/package/edge/community/x86/suricata
RUN apk add suricata=$VERSION --no-cache

# Install Suricata-update utility https://github.com/OISF/suricata-update
#RUN apk add python py-pip && pip install suricata-update

# Configurar suricata
COPY config/ /etc/suricata/

# Actualizaciones diarias
#COPY suricata-update.cron /etc/periodic/daily/suricata
#RUN /usr/bin/chmod +x /etc/periodic/daily/suricata
# Programar cron
COPY logrotate.cron /etc/crontabs/logrotate-cron
RUN chmod +x /etc/crontabs/logrotate-cron

COPY suricata-update.cron /etc/crontabs/suricata-update-cron
RUN chmod +x /etc/crontabs/suricata-update-cron
COPY suricata-update.sh /suricata-update-script.sh

# Utilidades para rotar los logs
RUN apk add logrotate --no-cache

# Forwarding suricata application logs to stdout
# Enabled by default
#RUN ln -sf /dev/stdout /var/log/suricata/suricata.log
# Optional/Experimental (not recommended)
#RUN ln -sf /dev/stdout /var/log/suricata/fast.log

# Permitir a suricata crear sockets sin permisos de root:
#
# CAP_NET_RAW: Para poder capturar paquetes.
# CAP_NET_ADMIN: Para poder realizar labores de IPS.
#
# Implicaciones:
#
# CAP_NET_RAW: Any kind of packet can be forged, which includes faking senders, 
# sending malformed packets, etc., this also allows to bind to any address 
# (associated to the ability to fake a sender this allows to impersonate a device, 
# legitimately used for "transparent proxying" as per the manpage but from an attacker 
# point-of-view this term is a synonym for Man-in-The-Middle)
#
# CAP_NET_ADMIN: Basically no restriction in controlling the network interfaces, which
# includes not only the network card itself (modify network configuration, switch the
# card into promiscuous mode to capture traffic, etc.) but also firewalling
# (don't miss this one!) and routing tables (allows to route traffic through a 
# malicious host).
#RUN apt-get install -y libcap2-bin
#RUN setcap cap_net_raw+ep /usr/local/bin/suricata && setcap cap_net_admin+ep /usr/local/bin/suricata

# Activar el CTRL + C en el modo interactivo
STOPSIGNAL SIGINT

# Inicio del contenedor

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "--af-packet" ]

#Ref:
#https://github.com/dtag-dev-sec/tpotce/tree/master/docker/suricata
#https://docs.docker.com/get-started/
#https://docs.docker.com/get-started/part2
#https://github.com/julienyvenat/docker-suricata/blob/master/alpine/Dockerfile/Dockerfile
