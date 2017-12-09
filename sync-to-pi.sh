#!/bin/bash -e
# Sync to my Raspberry Pi
cd "$(dirname "$0")"
exec rsync -av --exclude '.git/' --delete --delete-excluded "$PWD"/ raspy:telewalkie/
