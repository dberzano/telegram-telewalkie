#!/bin/bash -e
[[ -e ~/.telewalkie_nostart ]] && { echo "~/.telewalkie_nostart found: not starting" >&2; exit 3; }

export PYTHONUSERBASE="$HOME/python-telewalkie"
export PATH="$PYTHONUSERBASE/bin:$PATH"

function mypip() {
  # Work around old pip still pointing to http instead of https
  printf "[easy_install]\nindex_url = https://pypi.python.org/simple/\n" > "$HOME"/.pydistutils.cfg
  for P in "$@"; do
    pip install --index-url https://pypi.python.org/simple --user $P
  done
}

screen -wipe &> /dev/null || true
if screen -ls | grep -q '\.telewalkie\s'; then
  echo "Telewalkie already running" >&2
  exit 0
fi

# Check prerequisites. Pin Twisted and klein versions known to work
for CMD in opusdec aplay; do
  type $CMD &> /dev/null || { echo "Cannot find $CMD" >&2; exit 1; }
done
telewalkie --help &> /dev/null || mypip "-e ."

[[ -e ~/.telewalkie ]] || { echo "Cannot find config in ~/.telewalkie" >&2; exit 1; }

# Command and logfile
CMD="telewalkie --token $(head -n1 ~/.telewalkie)"
CMD="$CMD --authorized-ids $(head -n2 ~/.telewalkie | tail -n1)"
CMD="$CMD --debug"
LOG="/tmp/telewalkie-$(date -u +%Y%m%d-%H%M%S).log"

screen -dmS telewalkie bash -c "$CMD 2>&1 | tee $LOG"
