# Suricata Docker Image

## Build

La version de alpine, es mucho más ligera pero usa suricata desde el repositorio de la comunidad:
	
	docker build . -t $(cat TAG)

También hay una versión con ubuntu que usa el PPA con la versión más reciente:

	docker build . -f Dockerfile.ubuntu -t $(cat TAG)

Finalmente hay una versión con ubuntu que compila el fuente:

	docker build . -f Dockerfile -t $(cat TAG) --target "suricata" --build-arg version=$(cat VERSION)

## Usage

Ejecutar suricata en primer plano:

    docker run -it --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW suricata -i <interface>

Lanzar el contenedor sin ventana interactiva y en segundo plano:

	docker run -d --net=host --cap-add=NET_ADMIN --cap-add=NET_RAW suricata -i <interface>

## Actualizar firmas

El contenedor dispone de una tarea cron que le permite actualizar las firmas de forma regular. Puedes configurar la periocidad editando el archivo update.cron. Adicionalmente, puedes ejecutar una actualización manual en cualquier momento con:

	docker exec -it [nombre de contenedor] /usr/bin/suricata-update

Nota: para la versión compilada, el binario suricata-update se encuentra en /usr/local/bin.