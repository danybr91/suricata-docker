# Suricata Docker Image

## Build

Recomiendo usar la version de alpine, que es mucho más ligera:
	
	docker build . -f Dockerfile.* -t suricata
## Usage

    docker run -it --net=host suricata -i <interface>

O a través de docker compose (en construcción)

## Volumes

### /var/log/suricata

Expone los logs de suricata.

### /etc/suricata

Expone la configuración de suricata.

## Run

El contenedor redirige los parámetros a suricata. Para ver los comandos: https://suricata.readthedocs.io/en/suricata-4.1.4/command-line-options.html
Para iniciar el contenedor escuchando en 'eth0' con el modo pcap:
	docker run --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_NICE -v /var/log/suricata:/var/log/suricata -d suricata:latest --pcap=eth0

Para iniciar el contenedor en segundo plano:
	docker run --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_NICE -v /var/log/suricata:/var/log/suricata -d suricata:latest --pcap=eth0

Por defecto el contenedor siempre utiliza el fichero de configuración situado en /etc/suricata/suricata.yaml y el modo af-packet con la interfaz especificada en el fichero de configuración.
Puedes sobreescribir la configuración indicando un volumen:
	docker run --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_NICE -v /var/log/suricata:/var/log/suricata -v /data/conf:/etc/suricata -d suricata:latest
