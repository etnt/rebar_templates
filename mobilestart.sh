#!/usr/bin/env sh
cd `dirname $0`

. ./dep.inc

echo "Starting {{appid}}..."
erl \\
    -sname ${NAME} \\
    -pa ./ebin ${YAWS_EBIN} ${SIMPLE_BRIDGE_EBIN} \\
        ${EOPENID_EBIN} ${GETTEXT_EBIN} \\
    -eval "application:start({{appid}})"

