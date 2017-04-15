#!/usr/bin/env bash
set -e
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir/../fe"
export GOPATH="$(pwd)"

ln -s vendor src
src_ln="$(pwd)/src"
function on_exit {
    rm "$src_ln" 
}
trap on_exit EXIT

go get -u github.com/onsi/ginkgo/ginkgo
go get -u github.com/onsi/gomega
PATH="$GOPATH/bin:$PATH"
go build
ginkgo

