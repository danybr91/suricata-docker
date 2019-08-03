# Suricata Docker Image

## Build

La opción por defecto usa alpine linux como base, que es mucho más ligera:
	
	docker build

También dispones de una versión basada en ubuntu:

	docker build -f Dockerfile.*

## Usage

    docker run -it --net=host jasonish/suricata -i <interface>

O a través de docker compose (en construcción)

## Volumes

### /var/log/suricata

Expone los logs de suricata.

## /etc/suricata

Expone la configuración de suricata.
