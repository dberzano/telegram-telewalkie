#!/bin/bash -e
export PYTHONUSERBASE="$HOME/python-telewalkie"
export PATH="$PYTHONUSERBASE/bin:$PATH"

function mypip() {
  # Work around old pip still pointing to http instead of https
  printf "[easy_install]\nindex_url = https://pypi.python.org/simple/\n" > "$HOME"/.pydistutils.cfg
  for P in "$@"; do
    pip install --index-url https://pypi.python.org/simple --user $P
  done
}

if screen -ls | grep -q '\.telewalkie\s'; then
  printf "Already running\n"
  exit 0
fi

# Check prerequisites. Pin Twisted and klein versions known to work
for CMD in opusdec aplay; do
  type $CMD &> /dev/null || { printf "Cannot find $CMD"; exit 1; }
done
telewalkie --help &> /dev/null || mypip "-e ."

[[ -e ~/.telewalkie ]] || { printf "Cannot find config in ~/.telewalkie\n"; exit 1; }

screen -dmS telewalkie \
            telewalkie --token $(head -n1 ~/.telewalkie) \
                       --authorized-ids $(head -n2 ~/.telewalkie | tail -n1) \
                       --debug
