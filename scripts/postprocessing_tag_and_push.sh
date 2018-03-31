#!/bin/sh

set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT postprocessing_tag_and_push.sh: $1"
}

logger "Tagging"
docker tag $DOCKER_REPOSITORY:candidate $DOCKER_REPOSITORY:$OPENVPN_VERSION-$VERSION
docker tag $DOCKER_REPOSITORY:candidate $DOCKER_REPOSITORY:$OPENVPN_VERSION-latest
if [ "$TAG_LATEST" = true ]; then
  docker tag $DOCKER_REPOSITORY:candidate $DOCKER_REPOSITORY:latest
fi

logger "tags created:"
docker images $DOCKER_REPOSITORY

if [ "$PUSH_TAGS" = true ]; then
  logger "pushing tags"

  docker login -u $DOCKER_USER -p $DOCKER_PASS
  docker push $DOCKER_REPOSITORY:$OPENVPN_VERSION-$VERSION
  docker push $DOCKER_REPOSITORY:$OPENVPN_VERSION-latest
  if [ "$TAG_LATEST" = true ]; then
    docker push $DOCKER_REPOSITORY:latest
  fi
fi
