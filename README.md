# Suricata Docker Image

## Build

La version de alpine, es mucho más ligera pero usa suricata desde el repositorio de la comunidad:
	
	docker build . -t $(cat TAG)

Existe una versión alternativa con ubuntu que compila el fuente (Experimental):

	docker build . -f Dockerfile -t $(cat TAG) --target "suricata" --build-arg version=$(cat VERSION)

## Usage

Ejecutar suricata en primer plano:

	docker run -it --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW -e SURICATA_ARGS="-i <interface> --af-packet" suricata

Lanzar el contenedor sin ventana interactiva y en segundo plano:

	docker run -d --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW -e SURICATA_ARGS="-i <interface> --af-packet" suricata

Lanzar el contenedor creandos dos volúmenes para la configuración y las reglas y un bind mount para logs (por ejemplo):

	docker run -d --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW -v suricata_config:/etc/suricata -v suricata_rules:/var/lib/suricata/rules -v /var/log/docker/suricata:/var/log/suricata  -e SURICATA_ARGS="-i <interface> --af-packet" suricata


La variable de entorno SURICATA_ARGS especifica los parámetros de suricata, simulando el comando CMD. Si no especificas nada, por defecto se utilizará la configuración.

## Actualizar firmas

El contenedor dispone de una tarea cron que le permite actualizar las firmas de forma regular. Puedes configurar la periocidad editando el archivo update.cron. Adicionalmente, puedes ejecutar una actualización manual en cualquier momento con:

	docker exec -it [nombre de contenedor] /bin/sh /suricata-update-script.sh

Nota: para la versión compilada, el binario suricata-update se encuentra en /usr/local/bin.