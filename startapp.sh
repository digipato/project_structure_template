#!/bin/sh
set -u

echo "Usage: debug|local up|restart|down|logs"

DIR0="$(dirname "$(readlink -f "$0")")"


# il numero dopo -f è il livello di directory del path assoluto
# considerare in aggiunta anche la root "/"
PROJECT_NAME=$(echo "$DIR0" | cut -d'/' -f6)
echo "$DIR0"
echo "$PROJECT_NAME"

NAME="$(basename "$DIR0")"
echo "$NAME"

if [ ! $# -eq 2 ]; then
  echo "Devi passare 2 parametri."
  exit 1
fi

echo "$1 $2"

IMAGE_CONTEXT="./_deploy/build_image"
IMAGE_PROPERTIES_FILE="${IMAGE_CONTEXT}/images_version.properties"

if [ "$1" = "debug" ]; then
  # shellcheck disable=SC2155
  # shellcheck disable=SC2046
  export RECIPES_IMAGE_NAME=$(sed -n 's/^RECIPES_DEBUG_IMAGE_NAME=//p' ${IMAGE_PROPERTIES_FILE})
elif [ "$1" = "local" ]; then
  # shellcheck disable=SC2155
  # shellcheck disable=SC2046
  export RECIPES_IMAGE_NAME=$(sed -n 's/^RECIPES_LOCAL_IMAGE_NAME=//p' ${IMAGE_PROPERTIES_FILE})
elif [ "$1" = "test" ]; then
  # shellcheck disable=SC2155
  # shellcheck disable=SC2046
  export RECIPES_IMAGE_NAME=$(sed -n 's/^RECIPES_TEST_IMAGE_NAME=//p' ${IMAGE_PROPERTIES_FILE})
elif [ "$1" = "prod" ]; then
  # shellcheck disable=SC2155
  # shellcheck disable=SC2046
  export RECIPES_IMAGE_NAME=$(sed -n 's/^RECIPES_PROD_IMAGE_NAME=//p' ${IMAGE_PROPERTIES_FILE})
fi

if [ "$2" = "up" ]; then
  if ! docker image inspect $RECIPES_IMAGE_NAME >/dev/null 2>&1; then
    echo "Immagine $RECIPES_IMAGE_NAME non trovata. Procedo con la build."
    # Esegui il comando di build
    cp ./_deploy/build_image/requirements.txt ${IMAGE_CONTEXT}/"$1"
    sudo docker build -t $RECIPES_IMAGE_NAME ${IMAGE_CONTEXT}/"$1"
  else
    echo "Immagine $RECIPES_IMAGE_NAME già esistente."
  fi
fi

cd _deploy/compose/"$1" || exit
echo "RECIPES_IMAGE_NAME=$RECIPES_IMAGE_NAME" > .env
echo "COMPOSE_PROJECT_NAME=${PROJECT_NAME}-$1" >> .env

if [ "$2" = "up" ]; then
  sudo docker compose up -d
elif [ "$2" = "restart" ]; then
  sudo docker compose restart
elif [ "$2" = "down" ]; then
  sudo docker compose down --remove-orphans --volumes
elif [ "$2" = "logs" ]; then
  sudo docker compose logs -f --tail 1000
elif [ "$2" = "stop" ]; then
  sudo docker compose stop
fi

cd ../..