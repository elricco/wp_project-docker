# Worpress with Traefik and Adminer in Docker

## What's this?

It is a setup for Wordpress that persists the Wordpress instance and the database in your project folder so your changes don't get lost and can be comitted. It also lets you use a custom subdomain via Traefik since wordpress hardcodes all links and file usages to absolute urls.

It comes with a handy script to generate SSL certificates on your machine four your subdomain. The `traefik.toml` is setup to forward all incoming connctions to SSL (Port 443) so you will need a certificate.

## Setup the certificates
The scripts provided were made by my colleague and friend Till. You can find the standalone repo [here](https://github.com/grzegorczyk/SSL-Certificates)

First you need to become your very own SSL Certificate Authority. How to do this can be found here - over at [Delicious Brains](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/). After **Adding the Root Certificate to macOS Keychain** you can stop - the rest will / can be done with the little script provided in the `docker/certs` folder - `mkssl.sh`.

**Drop-In Firefox**
While adding the Root certificate to your keychain provides you with the usage in Chrome and Safari - for Firefox you'll have to add the certificate to the trusted certificates in Firefox itself. This can be done by opening `Settings` (CMD + ,) and navigating to `Privacy & Security` - on the bottom of the page you can display the used certificates - do that. You can now import your own certificate and trust it - this way you can use your own SSL certificates also in Firefox for local development.
**Drop-In Firefox**

Eventually you'll have to modify the mkssl.sh - my CA is located at the home directory of my user - hence `~/elriccoCA.pem` and `~/elriccoCA.key` - if your location and / or name differs you will have to adjust this.

#### mkssl.sh

Eventually you'll have to give the script the right to read/write/execute - this can be done with

```
    $ sudo chmod 777 mkssl.sh
```

The provided `sslserverconftxt.txt` lets you skip all the questions usally asked by the ssl certificate generator - you can adjust this to your likings / project, but not really necessary.

You can create your own certificates now by changing to the `docker/certs` directory and executing

```
    $ ./mkssl.sh myprojectname.docker.localhost
```

## Traefik
Traefik is a reverse proxy which lets you create custom domains and link to it by exposing a frontend and delegating the connections to the backend. You can see what Traefik is doing by typing

```
    http://docker.localhost:8080
```
in your browsers address line.

### SSL certificates in Traefik

The SSL certificates located in `docker/certs` are mounted as volume `certs` in docker, so they are referenced just with `certs`. If you have a local folder on your machine to store certificates for development you can mount this folder by editing the line `./docker/certs/:/certs/` by referencing your folder eg. `~/SSL-Certificates/certs/:/certs/`.

Since I haven't found a way to set these up via labels in the `docker-compose.yml` you'll have to *hardcode* these into the `traefik.toml` found in `docker/traefik`.

Go to the line where it says

```
      [[entryPoints.https.tls.certificates]]
        certFile = "/certs/twa-test.docker.localhost.crt"
        keyFile = "/certs/twa-test.docker.localhost.key"
```

and change the filnames of the certificates accordingly, eg. `myprojectname.docker.localhost.crt` and `myprojectname.docker.localhost.key`

If you need several certificates you can just drop in another entry of certificates here, so that it looks like this:

```
      [[entryPoints.https.tls.certificates]]
        certFile = "/certs/twa-test.docker.localhost.crt"
        keyFile = "/certs/twa-test.docker.localhost.key"
      [[entryPoints.https.tls.certificates]]
        certFile = "/certs/myprojectname.docker.localhost.crt"
        keyFile = "/certs/myprojectname.docker.localhost.key"
```

## Environment and Custom Variables

Environment Variables can be set via the .env file. The configuration `docker-compose` will finally render out of it can be controlled by using

```
    $ docker-compose config
```

`COMPOSE_PROJECT_NAME` is here to customize your build with your project name - it makes sure all containers are named by your project, sets the subdomain for your wordpress instance and creates the default (external) network.

`TRAEFIK_DOMAIN` lets you override the standard domain of `docker.localhost`.
`docker.localhost` defaultly runs in Chrome (Mac) - but not for eg. in Firefox - for this you have to edit your `hosts` file with `127.0.0.1 myprojectname.docker.localhost`. If you want to set the `TRAEFIK_DOMAIN` to something entirely different, say `whatever.lcl`, you'll have to edit the hosts file in any case, even for Chrome.

`WHOAMI_DOMAIN` sets the subdomain for the whoami container which just outputs the basic information of what image it is and that it is reachable. Since the `traefik.toml` is setup for forwarding to https you'll have to generate a SSL certificate for this too if you want to use it.

`MYSQL_ROOT_PASSWORD` sets the root password for the mysql database.

`MYSQL_DATABASE` sets up an empty database for your project. This can be anything containing letters, numbers and underscores. I like to go with the project name and ad `_wp` to it.

`MYSQL_USER` is for a dedicated user - so we don't use the `root` user here.

`MYSQL_PASSWORD` sets the password for the dedicated user.