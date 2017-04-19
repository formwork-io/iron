#!/usr/bin/env bash
set -e
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir/../fe"
export GOPATH="$(pwd)"

ln -s vendor src
src_ln="$(pwd)/src"
fake_src="$(pwd)/src/github.com/formwork-io"
mkdir -p "$fake_src"
ln -s $(realpath ../) "$fake_src/iron"
function on_exit {
    rm "$src_ln" 
    rm -fr "$fake_src"
}
trap on_exit EXIT

go get github.com/onsi/ginkgo/ginkgo
go get github.com/onsi/gomega
PATH="$GOPATH/bin:$PATH"
ginkgo -r --randomizeAllSpecs \
          --randomizeSuites \
          --failOnPending \
          --cover \
          --trace \
          --progress
