FROM quay.io/centos/centos:stream9

LABEL maintainer="emverdes@gmail.com"

RUN dnf install -y java-11-openjdk tomcat && \
    dnf install -y iproute && \
    dnf clean all

ADD sample.war /var/lib/tomcat/webapps/

EXPOSE 8080
CMD ["/usr/libexec/tomcat/server", "start"]
