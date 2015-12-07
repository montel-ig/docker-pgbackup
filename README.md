# README #

Docker image for automatic daily backups postgresql server (based on https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux)


### Running ###

```docker run -d --restart=always --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret pgbackup```