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
