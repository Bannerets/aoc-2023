#!/usr/bin/env bash

_session=$1

if [ -z "$_session" ]; then
  echo "Expecting the session cookie as the first argument"
  exit 1
fi

for i in {1..25}
do
  curl https://adventofcode.com/2023/day/$i/input --cookie "session=$_session" \
    > data/day$i.txt
done
