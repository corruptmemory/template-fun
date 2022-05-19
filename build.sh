#!/usr/bin/env bash

function check_available() {
  which $1 >/dev/null
  if [ $? -ne 0 ]; then
    echo "**** ERROR needed program missing: $1"
    exit 1
  fi
}

check_available 'which'
check_available 'realpath'
check_available 'dirname'
check_available 'go'

script_dir=$(dirname "$(realpath -e "$0")")
cwd="$(echo "$(pwd)")"
function cleanup() {
  cd "$cwd"
}
# Make sure that we get the user back to where they started
trap cleanup EXIT

# This is necessary because we reference things relative to the script directory
cd "$script_dir"

function usage() {
  echo "Usage: build.sh [-h|--help] [-c|--clean] [-C|--clean-all]"
  echo "                [-b|--build] [-r|--run]"
  echo
  echo '    Build template-fun.'
  echo
  echo "Arguments:"
  echo "  -h|--help               This help text"
  echo '  -c|--clean              Clean generated artifacts.'
  echo "  -C|--clean-all          Clean all the artifacts and the Go module cache."
  echo "  -b|--build              Build 'template-fun' using local tooling"
  echo "  -r|--run                Build and run 'template-fun' using local tooling"
}

clean=0
clean_all=0
build=0
run=0

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -h | --help)
    usage
    exit 0
    ;;
  -c | --clean)
    clean=true
    shift
    ;;
  -C | --clean-all)
    clean_all=true
    shift
    ;;
  -b | --build)
    build=true
    shift
    ;;
  -r | --run)
    run=true
    shift
    ;;
  *)
    echo "ERROR: unknown argument $1"
    echo
    usage
    exit 1
    ;;
  esac
done

if [ "$clean_all" = true ]; then
  echo "Deep cleaning..."
  clean=true
  go clean --modcache
fi

if [ "$clean" = true ]; then
  echo "Regular cleaning..."
	rm -f template-fun
	go clean .
fi

if [ "$build" = true ] || [ "$run" = true ]; then
  echo "Building..."
	CGO_ENABLED=0 go build -v -o "template-fun"
fi

if [ "$run" = true ]; then
  ./template-fun -f ./example.tmpl
fi
