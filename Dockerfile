# Imagen base
FROM alpine:latest

# Dependencias del sistema
RUN  apk -U --no-cache add \
		geoip \
		hiredis \
		jansson \
		libcap-ng \
		libgcc \
		libhtp \
		libmagic \
		libnet \
		libnetfilter_queue \
		libnfnetlink \
		libpcap \
		luajit \
		lz4-libs \
		musl \
		nspr \
		nss \
		pcre \
		py-yaml \
		python2 \
		#python3 \
		#py3-pip \
		yaml \
		zlib \
		# openresty \
		ca-certificates \
		wget \
		curl \
		tzdata \
		automake \
		autoconf \
		file-dev \
		build-base \
		cargo \
		geoip-dev \
		hiredis-dev \
		jansson-dev \
		libtool \
		libhtp-dev \
		libcap-ng-dev \
		luajit-dev \
		libpcap-dev \
		libnet-dev \
		libnetfilter_queue-dev \
		libnfnetlink-dev \
		lz4-dev \
		nss-dev \
		nspr-dev \
		pcre-dev \
		rust \
		yaml-dev
    #&& python3 -m pip install --no-cache-dir --upgrade pip \
    #&& python3 -m pip install --no-cache-dir suricata-update

# Configurar el sistema
RUN cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime && \
    echo "Europe/Brussels" >  /etc/timezone

# Instalar suricata
# --disable-gccmarch-native
# no optimiza el binario para el sistema. Adecuado para instalación portable o VM.
RUN mkdir -p /opt/suricata/ && \
    wget https://www.openinfosecfoundation.org/download/suricata-4.1.4.tar.gz && \
    tar xvfz suricata-4.1.4.tar.gz --strip-components=1 -C /opt/suricata/
    
WORKDIR /opt/suricata
RUN ./configure \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--disable-gccmarch-native \
	--enable-nfqueue \
	#--disable-rust \
	--enable-hiredis \
	--enable-gccprotect \
	--enable-pie \
	#--enable-lua \
	--enable-geoip \
	--enable-luajit \
    && make && \
    make check && \
    make install && \
    make install-full

# Configurar suricata
COPY config/ /etc/suricata/

# Por defecto se realizan actualizaciones diarias
COPY suricata-update.cron /etc/periodic/daily/suricata
RUN /usr/bin/chmod +x /etc/periodic/daily/suricata

# Limpiar
RUN cd ~ && rm -r /opt/suricata && \
    rm /suricata-4.1.4.tar.gz && \
    apk -U --no-cache del \
		tzdata \
		automake \
		autoconf \
		file-dev \
		build-base \
		geoip-dev \
		hiredis-dev \
		jansson-dev \
		libtool \
		libhtp-dev \
		libcap-ng-dev \
		luajit-dev \
		libpcap-dev \
		libnet-dev \
		libnetfilter_queue-dev \
		libnfnetlink-dev \
		lz4-dev \
		nss-dev \
		nspr-dev \
		pcre-dev \
		yaml-dev 

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
RUN apk -U --no-cache add libcap && /usr/sbin/setcap cap_net_raw+ep cap_net_admin+ep /usr/local/bin/suricata

# Inicio del contenedor
STOPSIGNAL SIGINT
ENTRYPOINT [ "/usr/local/bin/suricata", "-c", "/etc/suricata/suricata.yaml" ]
CMD [ "--af-packet" ]

#shell available mode
#CMD suricata -c /etc/suricata/suricata.yaml --af-packet=enp0s3

#Ref:
#https://github.com/dtag-dev-sec/tpotce/tree/master/docker/suricata
#https://docs.docker.com/get-started/
#https://docs.docker.com/get-started/part2
