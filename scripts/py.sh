#!/bin/bash
# Lance un script Python du projet avec l'environnement du dépôt.
# Usage : bash scripts/py.sh src/train.py --dataset cifar10 ...
cd "$(dirname "$0")/.."
source scripts/env.sh
exec "$UV_PROJECT_ENVIRONMENT/bin/python" "$@"
