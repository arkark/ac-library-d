#!/usr/bin/env bash

set -eu -o pipefail

dub build --quiet && \
    ./target/ac-library-d $@
