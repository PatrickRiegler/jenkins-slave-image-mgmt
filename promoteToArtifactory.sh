#!/bin/bash
set -e


ARTIFACTORY_API_URL=https://artifactory.six-group.net/artifactory/api/docker/docker-local/v2/promote

usage() { echo "Usage: $0 [-k (artifactory api key)], -i (image name)], [-t (image tag)], [-r (image tag)] [-c (copy the image, default is move)]" 1>&2; exit 1; }

parseOptions()
{

    while getopts "k:i:t:r:c" opt; do
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
        c)
          COPY_MODE=true
          ;;

      esac
    done
    shift $((OPTIND-1))
}

COPY_MODE=false

parseOptions $@

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

AUTH=
if [[ -n ${ARTIFACTORY_API_KEY} ]]; then
  echo "Using the API Key from variable 'ARTIFACTORY_API_KEY' for authentication."
  AUTH="-H \"X-JFrog-Art-Api: ${ARTIFACTORY_API_KEY}\""
fi

if [[ -z ${AUTH} ]] && [[ -n ${ARTIFACTORY_BASIC_AUTH} ]]; then
  echo "Using the Basic Auth from variable 'ARTIFACTORY_BASIC_AUTH' for authentication."
  AUTH="-u ${ARTIFACTORY_BASIC_AUTH}"
fi

if [[ -z ${AUTH} ]]; then
  echo "No Authentication mode is used. If you need authentication, please set on of the two env variables: ARTIFACTORY_BASIC_AUTH / ARTIFACTORY_API_KEY"
fi

echo "promoting ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} to ${ARTIFACTORY_TARGET_REPO}. (copy=${COPY_MODE})"

statement="http_code=\$(curl -s -o out.json -w '%{http_code}' -k -X POST ${ARTIFACTORY_API_URL} -H \"Content-Type: application/json\" ${AUTH} -d '{\"targetRepo\":\"${ARTIFACTORY_TARGET_REPO}\",\"dockerRepository\":\"${DOCKER_IMAGE_NAME}\",\"tag\":\"${DOCKER_IMAGE_TAG}\",\"copy\":\"${COPY_MODE}\"}')"

eval ${statement}

echo "Response:  ${http_code}"
cat out.json
rm -f  out.json

if [[ ${http_code} -ne 200 ]]; then
    echo "Did receive an error from artifactory"
    exit 1
fi

