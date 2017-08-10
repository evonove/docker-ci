# Jenkins CI image

This Docker image is a Continuous Integration Container used in our private Jenkins CI instance. The
[Automated Build][1] is available on Docker Hub registry. To download the image, simply::

    $ docker pull evonove/ci


## Features

* Built on top of the official Ubuntu 16.04 image
* uses [tini][2] to launch the `docker-entrypoint.sh`
* Provides Python `2.7.13`, `3.4.5`, `3.5.2` and `3.6.0` with `pip` `9.0.1`
* Provides Python `tox` `2.5.1`
* Provides NodeJS `6.9.2` with NPM `4.0.5`
* Provides Rust `1.19.0`
* Many libraries that may be useful to build your dependencies (i.e.: `psycopg2` or
  `weasyprint`)


[1]: https://hub.docker.com/r/evonove/ci/ "Automated Build"
[2]: https://github.com/krallin/tini "Tini"
