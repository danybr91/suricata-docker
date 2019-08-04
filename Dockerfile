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
COPY update.cron /etc/crontabs/suricata
COPY config/ /etc/suricata/

# Limpiar
RUN rm -r /opt/suricata && \
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
