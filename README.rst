================
Jenkins CI image
================

This Docker image is a Continuous Integration Container used in our private Jenkins CI instance. The
`Automated Build`_ is available on Docker Hub registry. To download the image, simply::

    $ docker pull evonove/ci

.. _Automated Build: https://hub.docker.com/r/evonove/ci/

Features
--------

* Built on top of Ubuntu 15.10
* uses `tini`_ to launch the ``docker-entrypoint.sh``
* Provides Python ``2.7.10``, ``3.4.4`` and ``3.5.1`` with ``pip`` ``8.1.1``
* Provides Python ``tox`` ``2.3.1``
* Provides NodeJS ``5.10.0`` with NPM ``3.8.5``
* Many libraries that may be useful to build your dependencies (i.e.: ``psycopg2`` or
  ``weasyprint``)

.. _tini: https://github.com/krallin/tini
