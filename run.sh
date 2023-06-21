#!/bin/bash
set -Eeuo pipefail

trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

inputFile="${script_dir}/wav/test-audio.wav"
outputFile="${script_dir}/wav/result-audio.wav"
trace=0

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    exit
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

usage() {
	 msg "-h help"
	 msg "-v verbose"
     msg "-t trace"
	 msg "-i | --input <inputFile>"
     msg "-o | --output <outputFile>"
}

parse_params() {

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -t ) trace=1 ;;
    -i | --input) 
      inputFile="${2-}"
      shift
      ;;
      -o | --output) 
      outputFile="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done
  args=("$@")
  return 0
}

parse_params "$@"

TRACE_V=""
TRACE_G=""
if [ $trace -ne 0 ]; then
    TRACE_V="--trace"
    TRACE_G="-CFLAGS -DSIM_TRACE"
fi

verilator -Wall ${TRACE_V} --top distortion --cc vhdl/distortion.v \
	--timescale 1us/1ns \
	--exe distortion.cpp -CFLAGS -I${script_dir}/include/ ${TRACE_G}

make -j`nproc` -C obj_dir -f Vdistortion.mk Vdistortion
./obj_dir/Vdistortion -i ${inputFile} -o ${outputFile}