#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color]']'

if ! hash bundle exec pilot 2>/dev/null; then
    echo "Please run 'bundle install' to install pilot tool."
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        add)
            ACTION="add"
            ;;
        remove)
            ACTION="remove"
            ;;
        -f)
            shift
            FILE="$1"
            ;;
        *)
            echo "Error: Invalid argument."
            exit 1
    esac
    shift
done

if [ -z $ACTION ]; then
    echo "Script to add/remove external beta testers from TestFlight."
    echo ""
    echo "Usage:"
    echo "./testers.sh add"
    echo "./testers.sh remove"
    echo "./testers.sh add -f file/with/testers/each/on/new/line"
    echo "./testers.sh remove -f file/with/testers/each/on/new/line"
    exit 0
fi

if [ ! -z "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        echo "File does not exist"
        exit 1
    fi

    TESTERS=`cat "$FILE"`
fi
if [ -z "$TESTERS" ]; then
    echo "Pipe list of testers (each on a new line), or paste and ctrl-d when done"
    TESTERS=$(cat)
fi

TESTERS=`echo $TESTERS | tr "\n" " "`

echo ""
echo -e "${RED}Following testers would be $ACTION'ed:${NC}"
echo "$TESTERS"
echo ""

while true; do
    echo "$ACTION testers? (y/n)"
    read -p "" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer yes or no.";;
    esac
done


command="bundle exec pilot $ACTION -u d@dvor.me -a me.dvor.Antidote $TESTERS"
echo -e "${YELLOW}$command${NC}"
eval $command
