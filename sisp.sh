#!/usr/bin/env bash
# Usage: sisp --conf path/to/this.conf [--dry-run]

set -euo pipefail

CONF=""
DRY=
while [ $# -gt 0 ]; do
  case "$1" in
    --conf) CONF="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[ -n "$CONF" ] || { echo "Error: --conf <file> is required" >&2; exit 1; }
[ -r "$CONF" ]  || { echo "Error: cannot read config $CONF" >&2; exit 1; }

# 2. load config
#    Expecting at least PROJECT_DIR, IMAGE_NAME, REGISTRY.
#    Optional:
#      TASKS   : bash array of "step commands" to run in order
#      DOCKERFILE, IMAGE_TAG, PUSH_IMAGE
source "$CONF"

# sanity-checks
: "${PROJECT_DIR:?must be set in config}"
: "${IMAGE_NAME:?must be set in config}"
: "${REGISTRY:?must be set in config}"

# defaults
IMAGE_TAG="${IMAGE_TAG:-latest}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
PUSH_IMAGE="${PUSH_IMAGE:-true}"
# Optionals
DOCKER_BUILD_ARGS="${DOCKER_BUILD_ARGS:-}"

FULL_IMAGE="$REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

run() {
  echo "+ $*"
  [ -z "${DRY-}" ] && eval "$@"
}

run cd "\"$PROJECT_DIR\""

if declare -p TASKS &>/dev/null; then
  echo "Running ${#TASKS[@]} TASK(s)..."
  for task in "${TASKS[@]}"; do
    run "$task"
  done
elif [ -n "${BUILD_CMD-}" ]; then
  run "$BUILD_CMD"
else
  echo "No TASKS or BUILD_CMD defined; skipping build steps."
fi

run docker build $DOCKER_BUILD_ARGS -f "\"$DOCKERFILE\"" -t "\"$FULL_IMAGE\"" .

if [ "$PUSH_IMAGE" = "true" ]; then
  run docker push "\"$FULL_IMAGE\""
else
  echo "Skipping push (PUSH_IMAGE=false)"
fi

echo "SISP finished: $FULL_IMAGE"
