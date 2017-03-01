# README #

Docker image for automatic daily backups postgresql server (based on https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

Forked from https://bitbucket.org/lighter/docker-pgbackup/ in order to support multiple database versions. Originally by Oleg Dementiev.

### Running ###

```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret unknownlighter/pgbackup
```