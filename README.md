# README #

Docker image for automatic daily backups postgresql server (based on https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

Forked from https://bitbucket.org/lighter/docker-pgbackup/ in order to support multiple database versions. Originally by Oleg Dementiev.

See https://hub.docker.com/r/sarkkine/pgbackup/

## Supported Postgresql versions ###
Build provides support for:
Postgres 9.4, 9.5, 9.6, 10, 11

To match postgres version of running database use tag format ```pg<vesion>-latest```. For example 
montel/docker-pgbackup:pg11-latest or montel/docker-pgbackup:pg9.4-latest

### Running ###

```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest
```

### Oneshot mode ###
```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest /pg_backup/pg_backup.sh
```

### compile new versions ###
```console
build-test.sh  # for test
build.sh  # tags latest and all pg versions supported
```

