# Entorno
ARG VERSION
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ="Europe/Madrid"

# Imagen base
FROM ubuntu:latest AS common

ARG DEBIAN_FRONTEND
ARG TZ

# Dependencias del sistema
RUN apt update && apt install -y \
	make libpcre3 libyaml-0-2 zlib1g python-yaml libjansson4 libpcap0.8 libnss3 python3-distutils

#FROM common AS suricata-ppa
# Al ejecutar todo en una única línea RUN, evitamos que se generen images con las dependencias transitorias
# Dependencias del sistema
#RUN apt update && \
#    apt install -y apt-utils software-properties-common && \
#    add-apt-repository ppa:oisf/suricata-stable && \
#    apt update; \
#    apt install -y suricata; \
#    apt remove -y --purge software-properties-common; \
#    apt autoremove -y; \
#    apt autoclean

# Imagen de compilación y construcción de suricata
FROM common AS suricata-build

ARG VERSION
ARG DEBIAN_FRONTEND
ARG TZ

# Dependencias de compilación. Recomendadas por https://suricata.readthedocs.io/en/latest/install.html#install-advanced y algunas adicionales:
# - libmaxminddb-dev: necesario si se usa GeoIP.•libhtp-dev necesario para ejecutar el binario compilado.
# - liblz4-dev: para comprimir ficheros pcap de log generados.
RUN apt update && apt install -y \
	build-essential gcc \
	libpcre3-dbg libpcre3-dev libpcap-dev libyaml-dev pkg-config zlib1g-dev libcap-ng-dev libmagic-dev libnss3-dev libjansson-dev libgeoip-dev liblua5.1-dev libhiredis-dev libevent-dev libmaxminddb-dev libhtp-dev cargo rustc

# Compilar suricata
COPY ${CODE_VERSION} /usr/local/src/suricata
WORKDIR /usr/local/src/suricata

RUN ./configure \
	--localstatedir=/var \
	--disable-gccmarch-native
	#--enable-nfqueue \
	#--disable-rust \
	#--enable-hiredis \
	#--enable-gccprotect \
	#--enable-pie \
	#--enable-lua \
	#--enable-geoip \
	#--enable-luajit \

RUN make && make install
WORKDIR /usr/local/
RUN rm -rf /usr/local/src/*

# Imagen de producción
FROM common AS suricata

ARG VERSION
ARG DEBIAN_FRONTEND
ARG TZ

# Instalación
# Copy the downloaded dependencies from the builder-prod stage.
COPY --from=suricata-build /usr/local/ /usr/local/
COPY --from=suricata-build /var/log/suricata /var/log/suricata

# Configurar suricata
COPY config/ /usr/local/etc/suricata/

# Por defecto se realizan actualizaciones diarias
COPY suricata-update.cron /etc/cron.daily/suricata
RUN /usr/bin/chmod +x /etc/periodic/daily/suricata

# Inicio del contenedor
STOPSIGNAL SIGINT
# ENTRYPOINT define un comando fijo del contenedor. CMD comandos (o parámetros) personalizables por el usuario
ENTRYPOINT [ "/usr/local/bin/suricata", "-c", "/etc/suricata/suricata.yaml" ]
CMD [ "--af-packet" ]

#shell available mode
#CMD suricata -c /etc/suricata/suricata.yaml --af-packet=enp0s3

#Ref:
#https://github.com/dtag-dev-sec/tpotce/tree/master/docker/suricata
#https://docs.docker.com/get-started/
#https://docs.docker.com/get-started/part2
#https://blog.armesto.net/i-didnt-know-you-could-do-that-with-a-dockerfile/

#https://github.com/jasonish/docker-suricata