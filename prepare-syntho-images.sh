#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 --mode <save/load> --tag <tag> --path <path> \n Example: ./prepare-syntho-images.sh --mode save --tag latest --path /home/syntho/images"
  exit 1
fi

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --mode)
      mode="$2"
      shift 2
      ;;
    --tag)
      tag="$2"
      shift 2
      ;;
    --path)
      path="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Check if required arguments are provided
if [ -z "$mode" ] || [ -z "$tag" ] || [ -z "$path" ]; then
  usage
fi

if [ "${path: -1}" != "/" ]; then
  path="${path}/"
fi

if [ "$mode" = "save" ]; then
    docker pull "syntho.azurecr.io/postgres:${tag}"
    docker save "syntho.azurecr.io/postgres:${tag}" > "${path}postgres.tar"

    docker pull redis:6.2-alpine
    docker save redis:6.2-alpine > "${path}redis.tar"

    docker pull "syntho.azurecr.io/syntho-core-api:${tag}"
    docker save "syntho.azurecr.io/syntho-core-api:${tag}" > "${path}syntho-core-api.tar"

    docker pull "syntho.azurecr.io/syntho-core-backend:${tag}"
    docker save "syntho.azurecr.io/syntho-core-backend:${tag}" > "${path}syntho-core-backend.tar"

    docker pull "syntho.azurecr.io/syntho-core-frontend:${tag}"
    docker save "syntho.azurecr.io/syntho-core-frontend:${tag}" > "${path}syntho-core-frontend.tar"

    docker pull "syntho.azurecr.io/syntho-ray:${tag}-cpu"
    docker save "syntho.azurecr.io/syntho-ray:${tag}-cpu" > "${path}syntho-ray.tar"

    docker pull "syntho.azurecr.io/syntho-ray-operator:${tag}"
    docker save "syntho.azurecr.io/syntho-ray-operator:${tag}" > "${path}syntho-ray-operator.tar"

    tar -cvf "${path}syntho-images.tar" -C ${path} postgres.tar syntho-core-api.tar syntho-core-backend.tar syntho-core-frontend.tar syntho-ray.tar syntho-ray-operator.tar
    rm "${path}postgres.tar" "${path}redis.tar" "${path}syntho-core-api.tar" "${path}syntho-core-backend.tar" "${path}syntho-core-frontend.tar" "${path}syntho-ray.tar" "${path}syntho-ray-operator.tar"

elif [ "$mode" = "load" ]; then

    tar -xvf "${path}syntho-images.tar" -C ${path}

    docker load < "${path}redis.tar"
    docker load < "${path}postgres.tar"
    docker load < "${path}syntho-core-api.tar"
    docker load < "${path}syntho-core-backend.tar"
    docker load < "${path}syntho-core-frontend.tar"
    docker load < "${path}syntho-ray.tar"
    docker load < "${path}syntho-ray-operator.tar"

    rm "${path}postgres.tar" "${path}redis.tar" "${path}syntho-core-api.tar" "${path}syntho-core-backend.tar" "${path}syntho-core-frontend.tar" "${path}syntho-ray.tar" "${path}syntho-ray-operator.tar"
fi