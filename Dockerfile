# Imagen base
FROM alpine:latest

# Dependencias del sistema
RUN  apk -U --no-cache add \
                 ca-certificates \
                 curl \
                 geoip \
                 hiredis \
                 jansson \
                 libcap-ng \
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
                 yaml \
                 wget \
                 automake \
                 autoconf \
                 build-base \
                 cargo \
                 file-dev \
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
                 python3 \
                 py3-pip \
                 rust \
                 yaml-dev && \
    python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir suricata-update

# Instalar suricata
# --disable-gccmarch-native
# no optimiza el binario para el sistema. Adecuado para instalación portable o VM.
RUN mkdir -p /opt/suricata/ && \
    wget https://www.openinfosecfoundation.org/download/suricata-4.1.4.tar.gz && \
    tar xvfz suricata-4.1.4.tar.gz --strip-components=1 -C /opt/suricata/ && \
    rm suricata-4.1.4.tar.gz && \
    cd /opt/suricata && \
    ./configure \
	 --disable-gccmarch-native
	--enable-nfqueue \
       # --disable-rust \
	--enable-hiredis \
	--enable-geoip \
	--enable-gccprotect \
	--enable-pie \
	--enable-luajit \
    && make && \
    make check && \
    make install && \
    make install-full

# Configuración
WORKDIR /etc/suricata
COPY . suricata.yaml
COPY . /custom-rules

#Ref:
#https://github.com/dtag-dev-sec/tpotce/tree/master/docker/suricata
#https://docs.docker.com/get-started/
#https://docs.docker.com/get-started/part2
