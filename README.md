# Podman+Tomcat tutorial 
A basic tutorial on running a web app on Tomcat using Podman (based on a docker tutorial)

# Steps
* Install [podman](https://podman.io/getting-started/installation).
* Clone this repository  
```
$ git clone https://github.com/emverdes/docker-tomcat-tutorial.git

$ cd docker-tomcat-tutorial
```
* Verify Tomcat download URL from https://dlcdn.apache.org/tomcat/ to update the Containerfile
```
$ podman build -t tomcat-demo:1 .

$ podman run -p 8008:8080 --name demo1 tomcat-demo:1
```
* In your browser go to http://localhost:8008
* Run another instance for load balancing
``` 
$ podman run -p 8009:8080 --name demo1 tomcat-demo:1
```
# Simple apache reverse proxy
Add to a VirtualHost in your apache web server configuration.
Replace localhost with the hostname of the host running your containers.
Remember to open up the ports in your firewall if needed.

```
ProxyPass "/sample"  "http://localhost:8008/sample"
ProxyPassReverse "/sample"  "http://localhost:8008/sample"
```

# Apache proxy loadbalancer for 2 containers
```
<Proxy "balancer://mycluster">
    BalancerMember "http://localhost:8008/sample"
    BalancerMember "http://localhost:8009/sample"
</Proxy>
ProxyPass        "/" "balancer://mycluster/"
ProxyPassReverse "/" "balancer://mycluster/"
```

# For reverse proxy
* #setsebool -P httpd_can_network_connect on
* #setsebool -P httpd_can_network_relay on


# Links
[Sample Tomcat web app](https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/)
