## Pixelfed Docker Image

Docker Image that simply install [Pixelfed](https://pixelfed.org) from
source and install its dependencies.

Meant to be used as a simple base image which can then be basis for
more complex deployments (docker-compose), it **DOES NOT** come with a
built-in web server. You *must* couple it with a separate service that
can connect to the php-fpm process.