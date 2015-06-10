#!/bin/sh

# git pre-commit hook that runs an Uncrustify stylecheck.
# Features:
#  - abort commit when commit does not comply with the style guidelines
#  - create a patch of the proposed style changes
#
# More info on Uncrustify: http://uncrustify.sourceforge.net/

# exit on error
set -e

# necessary check for initial commit
if git rev-parse --verify HEAD >/dev/null 2>&1 ; then
    against=HEAD
else
    # Initial commit: diff against an empty tree object
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi


patch=$(./run-uncrustify.sh --create-patch)
if [ $? != 0 ]; then
    exit 1
fi

# if no patch has been generated all is ok, clean up the file stub and exit
if [ ! -s "$patch" ] ; then
    echo "Files in this commit comply with the uncrustify rules."
    rm -f "$patch"
    exit 0
fi

# a patch has been created, notify the user and exit
echo "\nUncrustify check failed! You can see a diff file\n$patch"

echo "\nYou can apply these changes with:\ngit apply $patch\n"
echo "Aborting commit. Apply changes and commit again or skip checking with --no-verify (not recommended)."

if [ ! -t 1 ] ; then
    exit 1
fi

exec < /dev/tty

while true; do
    echo "Do you wish to open patch file? y/n"
    read -p "" yn
    case $yn in
        [Yy]* ) open "$patch"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    echo "Apply patch file? y/n"
    read -p "" yn
    case $yn in
        [Yy]* ) git apply "$patch"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

exit 1
