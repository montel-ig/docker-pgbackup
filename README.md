# README #

Docker image for automatic daily backups postgresql server (based on https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

Forked from https://bitbucket.org/lighter/docker-pgbackup/ in order to support multiple database versions. Originally by Oleg Dementiev.

See https://hub.docker.com/r/sarkkine/pgbackup/

## Supported Postgresql versions ###
Build provides support for:
Postgres 9.4, 9.5, 9.6, 10, 11

To match postgres version of running database use tag format ```pg<vesion>-latest```. For example 
montel/docker-pgbackup:pg11-latest or montel/docker-pgbackup:pg9.4-latest


## Running ##
### Environment variables ###

|  Variable             | default | function
|-----------------------|---------|---------
| ENABLE_CLEAN_OPT      |  "yes"  | adds --clean and --if-exists to pg_dump commnad
| ENABLE_CUSTOM_BACKUPS |  "yes"  | generate .custom format backup
| ENABLE_TIMESTAMP_OPT  |  "no"   | add timestamp of $(date +%F_%H-%M-%S) to file 
| PGHOST                |localhost| Optional hostname to adhere to pg_hba policies.
| ENABLE_PLAIN_BACKUPS  | "yes"   | Will produce a gzipped plain-format backup
| ENABLE_REMOVE_BACKUPS  | "no"    | delete *.sql.gz files in backup folder witch are older than wanted days
| CLEAN_BACKUPS_OLDER_THAN_DAYS | 10 | Timelimit to delete files older than this. Only works if ENABLE_REMOVE_BACKUPS is set to "yes".
 
### Docker ###
```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest
```

### Oneshot mode ###
```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest /pg_backup/pg_backup.sh
```

### Kubernetes ###
Run as a CronJob once every hour, store backup with timestamp 
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: backup-postgres
spec:
  concurrencyPolicy: Allow
  failedJobsHistoryLimit: 10
  jobTemplate:
    metadata:
      creationTimestamp: null
    spec:
      template:
        spec:
          restartPolicy: Never
          affinity:
            podAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                  - key: workload.user.cattle.io/workloadselector
                    operator: In
                    values:
                    - deployment-postgres
                topologyKey: "kubernetes.io/hostname"
          containers:
          - image: montel/docker-pgbackup:pg11-2
            args:
            - /pg_backup/pg_backup.sh
            env:
            - name: ENABLE_CLEAN_OPT
              value: "yes"
            - name: ENABLE_CUSTOM_BACKUPS
              value: "no"
            - name: ENABLE_TIMESTAMP_OPT
              value: "yes"
            - name: PGHOST
              value: postgres
            - name: PGPASSWORD
              value: mysecretpass
            - name: PGUSER
              value: postgres
            imagePullPolicy: Always
            name: backup-postgres
            volumeMounts:
            - mountPath: /backups
              name: postgre-prod
              subPath: backups
          terminationGracePeriodSeconds: 30
          volumes:
            - name: postgre-prod
              persistentVolumeClaim:
                claimName: postgre-prod
  schedule: '0 * * * *'
  successfulJobsHistoryLimit: 10
```

### compile new versions ###
```console
build-test.sh  # for test
build.sh  # tags latest and all pg versions supported
```

