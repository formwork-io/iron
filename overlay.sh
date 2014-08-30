#!/usr/bin/env bash
#
# Overlays the go shell on the current directory.
#

MAKE_SCRIPTS_DIR=1
UPGRADE_SCRIPTS_GO=1
ENV_SH_FOUND=0
GO_SH_FOUND=0
GOSH_SH_FOUND=0

if [ -d scripts ]; then
    MAKE_SCRIPTS_DIR=0
    if [ ! -r scripts/go.sh ]; then
        UPGRADE_SCRIPTS_GO=0
    fi
fi

if [ -r env.sh ]; then
    ENV_SH_FOUND=1
fi

if [ -r go.sh ]; then
    GO_SH_FOUND=1
fi

if [ -r .gosh.sh ]; then
    GOSH_SH_FOUND=1
fi

if [ $MAKE_SCRIPTS_DIR -eq 1 ]; then
    echo "The 'scripts' directory will be created for the main go.sh script."
elif [ $UPGRADE_SCRIPTS_GO -eq 1 ]; then
    echo "The 'scripts/go.sh' will be upgraded to the latest version."
else
    echo "The main 'go.sh' script will be placed in your 'scripts' directory."
fi

if [ $ENV_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing 'env.sh' was found, it will not be modified."
    echo "WARNING: You will need to manually apply any upstream changes!"
else
    echo "The 'env.sh' file will be placed in the current directory."
fi

if [ $GO_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing 'go.sh' was found, it will not be modified."
    echo "WARNING: You will need to manually apply any upstream changes!"
else
    echo "The 'go.sh' wrapper will be placed in the current directory."
fi

if [ $GOSH_SH_FOUND -eq 1 ]; then
    echo "WARNING: An existing '.gosh.sh' was found, it will be OVERRIDDEN!"
else
    echo "The '.gosh.sh' functions will be placed in the current directory."
fi

echo "--"
echo "Ready to go, [ENTER] to continue [CTRL-C] to cancel."
read

if [ $MAKE_SCRIPTS_DIR -eq 1 ]; then
    mkdir scripts || exit 1
fi

# The main go.sh script is *always* created or updated.
echo -en "Getting main go.sh script... "
WGET_OPTS="-q -O scripts/go.sh"
WGET_URL="https://raw.githubusercontent.com/formwork-io/gosh/master/scripts/go.sh"
wget $WGET_OPTS $WGET_URL || exit 1
echo "done"

# Never update env.sh, only create it
if [ $ENV_SH_FOUND -eq 0 ]; then
    echo -en "Getting env.sh... "
    WGET_OPTS="-q -O env.sh"
    WGET_URL="https://raw.githubusercontent.com/formwork-io/gosh/master/env.sh"
    wget $WGET_OPTS $WGET_URL || exit 1
    echo "done"
fi

# Never update the go.sh wrapper, only create it
if [ $GO_SH_FOUND -eq 0 ]; then
    echo -en "Getting go.sh wrapper... "
    WGET_OPTS="-q -O env.sh"
    WGET_OPTS="-q -O go.sh"
    WGET_URL="https://raw.githubusercontent.com/formwork-io/gosh/master/go.sh"
    wget $WGET_OPTS $WGET_URL || exit 1
    echo "done"
fi

# The .gosh.sh script is *always* created or updated.
echo -en "Getting .gosh.sh functions... "
WGET_OPTS="-q -O .gosh.sh"
WGET_URL="https://raw.githubusercontent.com/formwork-io/gosh/master/.gosh.sh"
wget $WGET_OPTS $WGET_URL || exit 1
echo "done"

echo -en "Setting executable bits... "
chmod +x go.sh || exit 1
chmod +x scripts/go.sh || exit 1
echo "done"

echo "Overlay complete."

