#!/bin/sh

SUPPORTED_INTERPRET_LANGUAGE=(ruby node python)
SUPPORTED_COMPILE_LANGUAGE=(go)
SUPPORTED_LANGUAGE=( "${SUPPORTED_INTERPRET_LANGUAGE[@]}" "${SUPPORTED_COMPILE_LANGUAGE[@]}" )

# Check arguments
if [ "$#" -lt 1 ]; then
  echo "Usage: sh $0 <Language> [Path to file]" >&2
  exit 1
fi

contains() {
  typeset _x;
  typeset -n _A="$1"
  for _x in "${_A[@]}" ; do
          [ "$_x" = "$2" ] && return 0
  done
  return 1
}

if ! contains SUPPORTED_LANGUAGE "$1"; then
  echo "$1 is not supported." >&2
  echo "Supported languages is: ${SUPPORTED_LANGUAGE[@]}" >&2
  exit 1
fi

command=$1
file=$2
if contains SUPPORTED_COMPILE_LANGUAGE "$1"; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: sh $0 <Language> <Path to file>" >&2
    exit 1
  fi
fi

if [ "$file" ]; then
  if ! [ -e "$file" ]; then
    echo "$file not found" >&2
    exit 1
  fi
fi

# Special process for each language
case $1 in
  ruby)
    if [ -z "$command" ]; then
      command="irb"
    fi
    ;;
  go)
    command="go run"
esac

docker-compose run $1 $command $(sed 's#\\#/#g' <<< "$2") ${@:3:99}
