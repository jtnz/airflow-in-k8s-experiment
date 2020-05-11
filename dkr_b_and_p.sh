#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd images

for IMAGE in *; do
    cd "${DIR}"/images/"${IMAGE}"
    docker build --tag registry.local:5000/"${IMAGE}" .
    docker push registry.local:5000/"${IMAGE}"
done
