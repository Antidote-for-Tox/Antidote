#!/bin/sh

# set uncrustify path or executable
# UNCRUSTIFY="/usr/bin/uncrustify"
UNCRUSTIFY="uncrustify"

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        --check)
            CHECK=true
            ;;
        --apply)
            APPLY=true
            ;;
        --create-patch)
            CREATEPATCH=true
            ;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done


if [ "$CHECK" = true ] ; then
    OPTIONS="--check"
elif [ "$APPLY" = true ] ; then
    OPTIONS="--no-backup"
elif [ "$CREATEPATCH" = true ] ; then
    OPTIONS=""
else
    >&2 echo "Please specify either --check, --apply or --create-patch"
    exit 1
fi


if ! command -v "$UNCRUSTIFY" > /dev/null ; then
    >&2 echo "Error: uncrustify executable not found.\n"
    >&2 echo "Set the correct path in $UNCRUSTIFY.\n"
    exit 1
fi

FILES="$(find Antidote/ -name '*.h' -or -name '*.m')"

if [ "$CHECK" = true ] || [ "$APPLY" = true ]; then
    $UNCRUSTIFY -c uncrustify.cfg  -l OC $OPTIONS $FILES
    exit $?
fi

# Create patch

prefix="run-uncrustify"
suffix="$(date +%C%y-%m-%d_%Hh%Mm%Ss)"
patch="/tmp/$prefix-$suffix.patch"

for file in $FILES; do
    # escape special characters in the source filename:
    # - '\': backslash needs to be escaped
    # - '*': used as matching string => '*' would mean expansion
    #        (curiously, '?' must not be escaped)
    # - '[': used as matching string => '[' would mean start of set
    # - '|': used as sed split char instead of '/', so it needs to be escaped
    #        in the filename
    # printf %s particularly important if the filename contains the % character
    file_escaped_source=$(printf "%s" "$file" | sed -e 's/[\*[|]/\\&/g')

    # escape special characters in the target filename:
    # phase 1 (characters escaped in the output diff):
    #     - '\': backslash needs to be escaped in the output diff
    #     - '"': quote needs to be escaped in the output diff if present inside
    #            of the filename, as it used to bracket the entire filename part
    # phase 2 (characters escaped in the match replacement):
    #     - '\': backslash needs to be escaped again for sed itself
    #            (i.e. double escaping after phase 1)
    #     - '&': would expand to matched string
    #     - '|': used as sed split char instead of '/'
    # printf %s particularly important if the filename contains the % character
    file_escaped_target=$(printf "%s" "$file" | sed -e 's/[\"]/\\&/g' -e 's/[\&|]/\\&/g')

    $UNCRUSTIFY -q -c uncrustify.cfg -l OC $OPTIONS -f "$file" | \
        diff -u -- "$file" - | \
        sed -e "1s|--- $file_escaped_source|--- \"a/$file_escaped_target\"|" -e "2s|+++ -|+++ \"b/$file_escaped_target\"|" >> "$patch"
done

echo "$patch"
