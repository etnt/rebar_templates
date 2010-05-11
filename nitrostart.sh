#!/usr/bin/env sh
cd `dirname $0`

. ./dep.inc

echo "Starting Nitrogen..."
erl \\
    -sname ${NAME} \\
    -pa ./ebin ${NITROGEN_EBIN} ${SIMPLE_BRIDGE_EBIN} ${NPROCREG_EBIN} \\
        ${EOPENID_EBIN} \\
    -pa ./ebin ${NITROGEN_EBIN} ${SIMPLE_BRIDGE_EBIN} ${NPROCREG_EBIN} \\
    -eval "application:start(nprocreg)" \\
    -eval "application:start({{appid}})"

