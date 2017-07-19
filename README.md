# AllegroGraph on Docker

This project helps you configure and run AllegroGraph via Docker.  The makefile will
build containers in which the data and database run.  The data is stored separately
in another container or can be stored in a local directory.

## Configuration

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

## Running completely in containers

Adjust the
```bash
make create-data-image
```

If you need to change your database configuration, you can shutdown your database and
change the configuration in the data container by:

```bash
make shell-data
```


## Running with data in a local directory
