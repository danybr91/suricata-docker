# Suricata Docker Image

## Build

La version de alpine, es mucho más ligera pero usa suricata desde el repositorio de la comunidad:
	
    docker build . --network host -t $(cat TAG) --platform linux/amd64, linux/arm64 --build-arg="TZ=Europe/Madrid" --build-arg="VERSION=$(cat TAG | awk -F ':' {print $2}')"

Existe una versión alternativa con ubuntu que compila el fuente (Experimental):

    docker build . -t Dockerfile.build --network host -t $(cat TAG) --platform linux/amd64, linux/arm64 --build-arg="TZ=Europe/Madrid" --build-arg="VERSION=$(cat TAG | awk -F ':' '{print $2}')"

## Usage

Ejecutar suricata:

	docker run -d --name suricata \
	--network host \
	--cap-add NET_ADMIN \
	--cap-add SYS_NICE \
	--cap-add NET_RAW \
	-v ./config:/etc/suricata \
	-v ./logs:/var/log/suricata \
	-v 'suricata_rules:/var/lib/suricata' \
	-v 'suricata_unix:/run/suricata' \
	--restart unless-stopped \
	suricata:<VERSION> \
	-i <interface> -F /etc/suricata/capture-filter.bpf

## Actualizar firmas

El contenedor dispone de una tarea cron que le permite actualizar las firmas de forma regular. Puedes configurar la periocidad editando el archivo update.cron. Adicionalmente, puedes ejecutar una actualización manual en cualquier momento con:

	docker exec -it [nombre de contenedor] /bin/sh /suricata-update-script.sh

Nota: para la versión compilada, el binario suricata-update se encuentra en /usr/local/bin.
