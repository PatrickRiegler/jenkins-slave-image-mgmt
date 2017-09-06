#!/bin/bash
set -e


ARTIFACTORY_API_URL=https://artifactory.six-group.net/artifactory/api/docker/docker-local/v2/promote

usage() { echo "Usage: $0 [-k (artifactory api key)], -i (image name)], [-t (image tag)], [-r (image tag)}" 1>&2; exit 1; }

parseOptions()
{

    while getopts "k:i:t:r:" opt; do
      case $opt in
        k)
          ARTIFACTORY_API_KEY="$OPTARG"
          ;;
        i)
          DOCKER_IMAGE_NAME="$OPTARG"
          ;;
        t)
          DOCKER_IMAGE_TAG="$OPTARG"
          ;;
        r)
          ARTIFACTORY_TARGET_REPO="$OPTARG"
          ;;
      esac
    done
    shift $((OPTIND-1))
}

parseOptions $@

if [[ -z ${ARTIFACTORY_API_KEY} ]]; then
  echo "The variable 'ARTIFACTORY_API_KEY' must be set"
  usage
fi

if [[ -z ${DOCKER_IMAGE_NAME} ]]; then
  echo "The variable 'DOCKER_IMAGE_NAME' must be set"
  usage
fi

if [[ -z ${DOCKER_IMAGE_TAG} ]]; then
  echo "The variable 'DOCKER_IMAGE_TAG' must be set"
  usage
fi

if [[ -z ${ARTIFACTORY_TARGET_REPO} ]]; then
  echo "The variable 'ARTIFACTORY_TARGET_REPO' must be set"
  usage
fi

echo "pushing ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} to ${ARTIFACTORY_TARGET_REPO}."
http_code=$(curl -s -o out.json -w '%{http_code}' -k \
-X POST ${ARTIFACTORY_API_URL} \
-H "Content-Type: application/json"  \
-H "X-JFrog-Art-Api: ${ARTIFACTORY_API_KEY}" \
-d "{\"targetRepo\":\"${ARTIFACTORY_TARGET_REPO}\",\"dockerRepository\":\"${DOCKER_IMAGE_NAME}\",\"tag\":\"${DOCKER_IMAGE_TAG}\",\"copy\":\"false\"}")

echo "Response:  ${http_code}"
cat out.json
rm -f  out.json

if [[ ${http_code} -ne 200 ]]; then
    echo "Did receive an error from artifactory"
    exit 1
fi

