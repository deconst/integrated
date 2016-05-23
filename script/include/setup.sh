#!/bin/bash

export COMPOSE_NAME="${COMPOSE_PROJECT_NAME:-$(basename ${ROOT})}"
COMPOSE_NAME=${COMPOSE_NAME//[^a-z0-9]}

export COMPOSE_NETWORK_NAME="${COMPOSE_NAME}_default"
export PROD_CONTENT_NAME="${COMPOSE_NAME}_content_1"
export STAGING_CONTENT_NAME="${COMPOSE_NAME}_staging_content_1"

export DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME:-dev}"

if ! docker version >/dev/null 2>&1 ; then
  echo "Unable to connect to a Docker daemon." >&2
  exit 1
fi

export DECONST_HOST=localhost
if docker-machine ip ${DOCKER_MACHINE_NAME} >/dev/null 2>&1 ; then
  DECONST_HOST=$(docker-machine ip ${DOCKER_MACHINE_NAME})
fi

export PROD_CONTENT_URL=http://${PROD_CONTENT_NAME}:8080/
export STAGING_CONTENT_URL=http://${STAGING_CONTENT_NAME}:8080/

apikey() {
  local KEYNAME="${1:-}"
  local STAGING="${2:-}"

  [ -z "${ADMIN_APIKEY}" ] && {
    echo "\$ADMIN_APIKEY must be populated." >&2
    exit 1
  }

  [ -n "${APIKEY:-}" ] && return 0

  local ENDPOINT="http://${DECONST_HOST}:9000"
  [ -n "${STAGING}" ] && ENDPOINT="http://${DECONST_HOST}:9001"

  export APIKEY=$(curl -s \
    -X POST \
    -H "Authorization: deconst ${ADMIN_APIKEY}" \
    ${ENDPOINT}/keys?named=${KEYNAME} |
    python -c 'import sys, json; print json.load(sys.stdin)["apikey"]')

  if [ -z "${APIKEY:-}" ]; then
    echo "Unable to issue an API key." >&2
    exit 1
  fi
}
