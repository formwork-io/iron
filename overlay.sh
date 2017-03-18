#!/usr/bin/env bash
#
# Overlays the fe shell on the current directory.
#

MAKE_SCRIPTS_DIR=1
UPGRADE_SCRIPTS_GO=1
ENV_SH_FOUND=0
GO_SH_FOUND=0
IRON_SH_FOUND=0

if [ -d scripts ]; then
    MAKE_SCRIPTS_DIR=0
    if [ ! -r scripts/fe.sh ]; then
        UPGRADE_SCRIPTS_GO=0
    fi
fi

if [ -r env.sh ]; then
    ENV_SH_FOUND=1
fi

if [ -r fe.sh ]; then
    GO_SH_FOUND=1
fi

if [ -r .iron.sh ]; then
    IRON_SH_FOUND=1
fi

if [ $MAKE_SCRIPTS_DIR -eq 1 ]; then
    echo "The 'scripts' directory will be created for the main fe.sh script."
elif [ $UPGRADE_SCRIPTS_GO -eq 1 ]; then
    echo "The 'scripts/fe.sh' will be upgraded to the latest version."
else
    echo "The main 'fe.sh' script will be placed in your 'scripts' directory."
fi

if [ $ENV_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing 'env.sh' was found, it will not be modified."
    echo "WARNING: You will need to manually apply any upstream changes!"
else
    echo "The 'env.sh' file will be placed in the current directory."
fi

if [ $GO_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing 'fe.sh' was found, it will not be modified."
    echo "WARNING: You will need to manually apply any upstream changes!"
else
    echo "The 'fe.sh' wrapper will be placed in the current directory."
fi

if [ $IRON_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing '.iron.sh' was found, it will be OVERRIDDEN!"
else
    echo "The '.iron.sh' functions will be placed in the current directory."
fi

echo "--"
echo "Ready to go, [ENTER] to continue [CTRL-C] to cancel."
read

if [ $MAKE_SCRIPTS_DIR -eq 1 ]; then
    mkdir scripts || exit 1
fi

# The main fe.sh script is *always* created or updated.
echo -en "Getting main fe.sh script... "
WGET_OPTS="-q -O scripts/fe.sh"
WGET_URL="https://raw.githubusercontent.com/formwork-io/iron/master/scripts/fe.sh"
wget $WGET_OPTS $WGET_URL || exit 1
echo "done"

# Never update env.sh, only create it
if [ $ENV_SH_FOUND -eq 0 ]; then
    echo -en "Getting env.sh... "
    WGET_OPTS="-q -O env.sh"
    WGET_URL="https://raw.githubusercontent.com/formwork-io/iron/master/env.sh"
    wget $WGET_OPTS $WGET_URL || exit 1
    echo "done"
fi

# Never update the fe.sh wrapper, only create it
if [ $GO_SH_FOUND -eq 0 ]; then
    echo -en "Getting fe.sh wrapper... "
    WGET_OPTS="-q -O env.sh"
    WGET_OPTS="-q -O fe.sh"
    WGET_URL="https://raw.githubusercontent.com/formwork-io/iron/master/fe.sh"
    wget $WGET_OPTS $WGET_URL || exit 1
    echo "done"
fi

# The .iron.sh script is *always* created or updated.
echo -en "Getting .iron.sh functions... "
WGET_OPTS="-q -O .iron.sh"
WGET_URL="https://raw.githubusercontent.com/formwork-io/iron/master/.iron.sh"
wget $WGET_OPTS $WGET_URL || exit 1
echo "done"

echo -en "Setting executable bits... "
chmod +x fe.sh || exit 1
chmod +x scripts/fe.sh || exit 1
echo "done"

echo "Overlay complete."

