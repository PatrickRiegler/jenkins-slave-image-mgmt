#!/bin/bash
# copy a docker image from ${1} to ${2}

set -e

usage() { echo "Usage: $0 [-f (from image name)], [-t (to image name)]}" 1>&2; exit 1; }

parseOptions()
{

    while getopts "f:t:" opt; do
      case $opt in
        f)
          FROM_IMAGE="$OPTARG"
          ;;
        t)
          TO_IMAGE="$OPTARG"
          ;;
      esac
    done
    shift $((OPTIND-1))
}

parseOptions $@

if [[ -z ${FROM_IMAGE} ]]; then
  echo "The from image is missing"
  usage
fi

if [[ -z ${TO_IMAGE} ]]; then
  echo "The to image is missing"
  usage
fi

skopeo copy --src-tls-verify=false docker://${FROM_IMAGE} docker://${TO_IMAGE}
