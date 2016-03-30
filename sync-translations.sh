#!/bin/sh

TOOL=tx

if ! hash $TOOL 2>/dev/null; then
    echo "Transifex command line tool not installed, see http://docs.transifex.com/client/"
    exit 1
fi

$TOOL pull -a
