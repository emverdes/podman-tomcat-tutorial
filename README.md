# Podman + Tomcat Tutorial

Tutorial básico para construir y ejecutar una aplicación web Java sobre Tomcat utilizando Podman.

El repositorio contiene una pequeña aplicación WAR preparada para utilizarse como ejemplo en prácticas de contenedores.

## Contenido

```text
.
├── Containerfile
├── sample.war
└── README.md
```

La aplicación muestra información básica del entorno donde está ejecutándose:

* Hostname del contenedor.
* Versión de Java.
* Versión de Tomcat.
* Hora del servidor.

También incluye un endpoint sencillo de health check.

## Requisitos

* Linux
* Podman
* Git
* Acceso a Internet

Verificar la instalación:

```bash
podman version
```

## Clonar el repositorio

```bash
git clone https://github.com/emverdes/podman-tomcat-tutorial.git
cd podman-tomcat-tutorial
```

## Containerfile

La imagen se construye a partir de CentOS Stream e instala Java y Tomcat.

```Dockerfile
FROM quay.io/centos/centos:stream9

LABEL maintainer="emverdes@gmail.com"

RUN dnf install -y java-11-openjdk tomcat iproute && \
    dnf clean all

ADD sample.war /var/lib/tomcat/webapps/

EXPOSE 8080

CMD ["/usr/libexec/tomcat/server", "start"]
```

## Construir la imagen

```bash
podman build -t tomcat-demo:1.0 .
```

Verificar:

```bash
podman images
```

## Ejecutar la aplicación

```bash
podman run -d \
  --name tomcat1 \
  -p 8008:8080 \
  tomcat-demo:1.0
```

Comprobar el contenedor:

```bash
podman ps
```

Consultar los logs:

```bash
podman logs tomcat1
```

Acceder a la aplicación:

```text
http://localhost:8008/sample/
```

Health check:

```bash
curl http://localhost:8008/sample/health.jsp
```

Resultado esperado:

```text
OK
```

## Ejecutar una segunda instancia

La misma imagen puede utilizarse para crear varios contenedores:

```bash
podman run -d \
  --name tomcat2 \
  -p 8009:8080 \
  tomcat-demo:1.0
```

Probar ambas instancias:

```bash
curl http://localhost:8008/sample/
curl http://localhost:8009/sample/
```

Cada contenedor tendrá un hostname diferente.

### Simple apache reverse proxy

Add to a VirtualHost in your apache web server configuration.
Replace localhost with the hostname of the host running your containers.
Remember to open up the ports in your firewall if needed.

```
ProxyPass "/sample"  "http://localhost:8008/sample"
ProxyPassReverse "/sample"  "http://localhost:8008/sample"
```

### Apache proxy loadbalancer for 2 containers

```
<Proxy "balancer://mycluster">
    BalancerMember "http://localhost:8008/sample"
    BalancerMember "http://localhost:8009/sample"
</Proxy>
ProxyPass        "/" "balancer://mycluster/"
ProxyPassReverse "/" "balancer://mycluster/"
```

### For reverse proxy when SELinux is enabled

* #setsebool -P httpd_can_network_connect on
* #setsebool -P httpd_can_network_relay on

## Administración básica

Listar contenedores:

```bash
podman ps
podman ps -a
```

Detener y arrancar un contenedor:

```bash
podman stop tomcat1
podman start tomcat1
```

Ejecutar un comando dentro del contenedor:

```bash
podman exec tomcat1 hostname
```

Abrir un shell:

```bash
podman exec -it tomcat1 /bin/bash
```

Eliminar un contenedor:

```bash
podman rm -f tomcat1
```

## Publicar la imagen en Docker Hub

Para publicar la imagen se necesita una cuenta en Docker Hub y un repositorio público, por ejemplo:

```text
tomcat-demo
```

Autenticarse desde Podman:

```bash
podman login docker.io
```

Ingresar el usuario y la contraseña o token correspondiente.

### Etiquetar la imagen

Las imágenes publicadas en Docker Hub utilizan el formato:

```text
docker.io/USUARIO/REPOSITORIO:TAG
```

Etiquetar la imagen local:

```bash
podman tag \
  tomcat-demo:1.0 \
  docker.io/USUARIO_DOCKER/tomcat-demo:1.0
```

Verificar:

```bash
podman images
```

### Publicar la imagen

```bash
podman push docker.io/USUARIO_DOCKER/tomcat-demo:1.0
```

Comprobar desde Docker Hub que el repositorio contiene el tag:

```text
1.0
```

## Probar la imagen publicada

Eliminar primero los contenedores que estén utilizando la imagen:

```bash
podman rm -f tomcat1 tomcat2
```

Eliminar las referencias locales:

```bash
podman rmi tomcat-demo:1.0
podman rmi docker.io/USUARIO_DOCKER/tomcat-demo:1.0
```

Verificar:

```bash
podman images
```

Ejecutar nuevamente utilizando directamente la imagen publicada:

```bash
podman run -d \
  --name tomcat-public \
  -p 8008:8080 \
  docker.io/USUARIO_DOCKER/tomcat-demo:1.0
```

Si la imagen no existe localmente, Podman la descargará del registry antes de crear el contenedor.

Verificar:

```bash
curl http://localhost:8008/sample/
```

## Apache como reverse proxy

Un servidor Apache externo puede publicar la aplicación ejecutada dentro del contenedor.

Ejemplo:

```apache
ProxyPass        "/sample/" "http://localhost:8008/sample/"
ProxyPassReverse "/sample/" "http://localhost:8008/sample/"
```

En sistemas con SELinux puede ser necesario permitir que Apache realice conexiones hacia el backend:

```bash
sudo setsebool -P httpd_can_network_connect on
```

## Arquitectura

```text
Cliente
   |
   | HTTP
   v
Host Linux
   |
   | TCP/8008
   v
+-----------------------+
| Container             |
|                       |
| Tomcat :8080          |
|    |                  |
|    +-- sample.war     |
+-----------------------+
```

## Objetivos educativos

Este ejemplo permite practicar:

* Imágenes y contenedores.
* Containerfiles.
* Construcción de imágenes.
* Mapeo de puertos.
* Logs.
* Ejecución de comandos dentro de contenedores.
* Múltiples instancias de una misma imagen.
* Tags.
* Container registries.
* Push y pull de imágenes.
* Integración entre contenedores y servicios tradicionales.

