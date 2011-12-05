#!/bin/bash
cd `dirname $0`

if [ "$1" == "-i" ]; then
  exec erl -sname {{appid}} -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s {{appid}}
elif [ "$1" == "-e" ]; then
  exec erl -sname {{appid}} -pa $PWD/ebin $PWD/deps/*/ebin
else
  exec erl -sname {{appid}} -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s {{appid}} -detached
fi

