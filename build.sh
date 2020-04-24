#!/usr/bin/env bash
set -xe
POSTGRE_VERSIONS=(9.4 9.5 9.6 10 11)
REPONAME=montel/docker-pgbackup
VERSION=5


for pg in ${POSTGRE_VERSIONS[@]}; do
    #TAG="pg${pg/\./_}"
    TAG="pg${pg}-${VERSION}"
    LATEST="pg${pg}-latest"
    docker build --build-arg PG_VERSION=${pg} -t ${REPONAME}:${TAG} -t ${REPONAME}:${LATEST}  .
    docker push ${REPONAME}:${TAG}
    docker push ${REPONAME}:${LATEST}
done




