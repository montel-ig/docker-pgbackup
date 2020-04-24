# README #

Docker image for automatic daily backups postgresql server (based on https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux).

Forked from https://bitbucket.org/lighter/docker-pgbackup/ in order to support multiple database versions. Originally by Oleg Dementiev.

See https://hub.docker.com/r/sarkkine/pgbackup/

This tool also supports rotated backups through the
`pg_backup_rotated.sh`. The same as above except it will delete expired
backups based on the configuration. Backups will be stored with
suffixes -monthly, -weekly or -daily.

## Supported Postgresql versions
### Build provides support for: Postgres 9.4, 9.5, 9.6, 10, 11

To match postgres version of running database use tag format ```pg<vesion>-latest```. For example 
montel/docker-pgbackup:pg11-latest or montel/docker-pgbackup:pg9.4-latest


## Running ##
### Environment variables ###

|  Variable                     | default | function
|-------------------------------|---------|---------
| ENABLE_CLEAN_OPT              |  "yes"  | adds --clean and --if-exists to pg_dump commnad
| ENABLE_CUSTOM_BACKUPS         |  "yes"  | generate .custom format backup
| ENABLE_TIMESTAMP_OPT          |  "no"   | add timestamp of $(date +%F_%H-%M-%S) to file 
| PGHOST                        |localhost| Optional hostname to adhere to pg_hba policies.
| ENABLE_PLAIN_BACKUPS          | "yes"   | Will produce a gzipped plain-format backup
| ENABLE_REMOVE_BACKUPS         | "no"    | delete *.sql.gz files in backup folder witch are older than wanted days
| CLEAN_BACKUPS_OLDER_THAN_DAYS | 10      | Timelimit to delete files older than this. Only works if ENABLE_REMOVE_BACKUPS is set to "yes".

### Environment variables for rotated backups (only for pg_backup_rotated.sh) ###
|  Variable                     | default | function
|-------------------------------|---------|---------
| DAY_OF_WEEK_TO_KEEP           | 5       | Default is Friday. Which day to take the weekly backup from (1-7 = Monday-Sunday).
| DAYS_TO_KEEP                  | 7	  | Number of days to keep daily backups
| WEEKS_TO_KEEP			| 5	  | How many weeks to keep weekly backups

### Docker ###
```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest
```

### Oneshot mode ###
```console
$ docker run -d --restart=always --volume /path/to/backups:/backups --name pgbackup -e PGHOST=192.168.1.1 -e PGUSER=postgres -e PGPASSWORD=somesecret montel/docker-pgbackup:pg11-latest /pg_backup/pg_backup.sh
```

### Kubernetes ###
#### Example 1.

Run `pg_backup` as a CronJob once every hour, store backup with timestamp 
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

#### Example 2.

Run `pg_backup_rotated` as a CronJob every day at 3 AM, store backup with timestamp,
do the weekly backup every monday, montly backup 5 weeks of every monday. DB credentials from secret.

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: pg-backup-rotate
spec:
  concurrencyPolicy: Allow
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        metadata:
        spec:
          containers:
          - args:
            - /pg_backup/pg_backup_rotated.sh
            env:
            - name: ENABLE_CLEAN_OPT
              value: "yes"
            - name: ENABLE_CUSTOM_BACKUPS
              value: "no"
            - name: ENABLE_TIMESTAMP_OPT
              value: "yes"
            - name: DAY_OF_WEEK_TO_KEEP
              value: "1"
            - name: DAYS_TO_KEEP
              value: "7"
            - name: WEEKS_TO_KEEP
              value: "5"
            - name: PGHOST
              value: postgres
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-user-pass
                  key: password
            - name: PGUSER
              valueFrom:
                secretKeyRef:
                  name: db-user-pass
                  key: username
            image: montel/docker-pgbackup:pg11-latest
            imagePullPolicy: Always
            name: pg-backup-rotate
            resources: {}
            securityContext:
              allowPrivilegeEscalation: false
              capabilities: {}
              privileged: false
              procMount: Default
              readOnlyRootFilesystem: false
              runAsNonRoot: false
            stdin: true
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
            tty: true
            volumeMounts:
            - mountPath: /backups
              name: pg-backup-rotated-vol
              subPath: backups
          dnsPolicy: ClusterFirst
          restartPolicy: Never
          schedulerName: default-scheduler
          securityContext: {}
          terminationGracePeriodSeconds: 30
          volumes:
          - name: pg-backup-rotated-vol
            persistentVolumeClaim:
              claimName: media
  schedule: 0 3 * * *
  successfulJobsHistoryLimit: 10
  suspend: false
```

### compile new versions ###
```console
build-test.sh  # for test
build.sh  # tags latest and all pg versions supported
```

