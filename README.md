# Suricata Docker Image

## Build

Recomiendo usar la version de alpine, que es mucho más ligera:
	
	docker build . -t $(cat TAG)

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

Pero procura proporcionar una carpeta con configuración existente o no se ejecutará. Si no tienes ninguna configuración disponible, puedes obtener la carpeta de configuración ejecutando un contenedor sin volumenes y copiando el contenido al host:

	docker cp [nombre de contenedor]:/etc/suricata /host/suricata-config

## Actualizar firmas

El contenedor dispone de una tarea cron que le permite actualizar las firmas de forma regular. Puedes configurar la periocidad editando el archivo update.cron. Adicionalmente, puedes ejecutar una actualización manual en cualquier momento con:

	docker exec -it nice_wilson /usr/local/bin/suricata-update


## TODO

- Permitir ejecutar suricata con un usuario limitado.
- Mejor gestión de la actualización de firmas.
- Mejor gestión de la configuración.
- Integración con servicios.

