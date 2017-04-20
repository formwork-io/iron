#!/usr/bin/env bash
set -e
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$GOPATH" ]; then
    echo -n "Creating temporary GOPATH... "
    export GOPATH="$(pwd)/temp-gopath"
    function on_exit {
        ec=$?
        if [ $ec -eq 0 ]; then
            rm -fr "$GOPATH"
        fi
    }
    trap on_exit EXIT
    nested_path="$GOPATH/src/github.com/formwork-io"
    top="$nested_path/iron"
    mkdir -p "$nested_path"
    ln -s "$(pwd)" "$top"
    echo "okay"
    echo -n "Getting ginkgo and gomega... "
    go get github.com/onsi/ginkgo/ginkgo
    go get github.com/onsi/gomega
    echo "okay"
else
    top="$(realpath $dir/..)"
fi

cd "$top/fe"
ginkgo -r --randomizeAllSpecs \
          --randomizeSuites \
          --failOnPending \
          --cover \
          --trace \
          --progress
