# AllegroGraph on Docker

This project helps you configure and run AllegroGraph via Docker.  The makefile will
build containers in which the data and database run.  The data is stored separately
in another container or can be stored in a local directory.

## Running completely in containers

To create the data image from your configuration:

```bash
make create-data-image
```

To create a database instance from your data image:

```bash
make create-data
make create
```

Then start your database:

```bash
make start
```

If you need to change your database configuration, you can shutdown your database and
change the configuration in the data container by:

```bash
make shell-data
```

## Running with data in a local directory

To create a database instance using a local directory:

```bash
make create-data-local HOME=/path/to/parent
make create
```

The `HOME` variable is the parent directory in which a `data` directory will be created. The
configuration will be located in `$HOME/data/etc/agraph.cfg`.

Then start your database:

```bash
make start
```

## Starting and Stopping

For your convenience, to start:

```bash
make start
```

and to stop:

```bash
make stop
```

## Customization

The file `agraph.in` is the template for the AllegroGraph configuration.  The
variables `$ADMIN_USER`, `$ADMIN_PASSWORD`, `$PORT`, and `$SSL_PORT` will be substituted during the build
process.

The following variables may be change during the make process:

 * `ADMIN_PASSWORD` the admin database user password (defaults to `admin`)
 * `ADMIN_USER` the admin database username (defaults to `admin`)
 * `DATA_IMAGE` the name of the database data image to use (defaults to /)
 * `DATA_NAME` the name of the database data container name (defaults to `$(NAME)_name`)
 * `HOME` the root of the data
 * `IMAGE` the AllegroGraph image to use (defaults to `franzinc/agraph:latest`)
 * `MEMSIZE` the database memory limit (defaults to 1g)
 * `NAME` the name of the database container (defaults to `agraph_test`)
 * `PORT` the port to expose and listen on (defaults to 10035)
 * `SHMSIZE` the size of /dev/shm (must be at least 1g)
 * `SSL_PORT` the ssl port to expose and listen on (defaults to 10036)

## Running on CoreOS

Setup your data directory (assuming user `core`):

```bash
git clone https://github.com/alexmilowski/allegrograph-docker.git
toolbox make -f /media/root/home/core/allegrograph-docker/Makefile create-data-local HOME=/media/root
docker create -m 1g -p 10035:10035 --shm-size 1g --name agraph -v /data:/data franzinc/agraph:latest
```

You'll want to adjust the database memory, ports, and name and other parameters to the `docker create` command as necessary.

Then edit ~/data/etc/agraph.cfg as you need and start your database:

```bash
docker start agraph
```

If you don't have `make` in your toolbox, try this for ubuntu/toolbox:

In your `~/.tooboxrc`

```
TOOLBOX_DOCKER_IMAGE=ubuntu-debootstrap
TOOLBOX_DOCKER_TAG=14.04
```

Then install `make` by:

```bash
toolbox apt-get update
toolbox apt-get install build-essential
```
