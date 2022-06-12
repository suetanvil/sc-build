#!/bin/bash

set -e

root=$(cd -P $(dirname "${BASH_SOURCE[0]}")/..; pwd)

cd "$root"

for d in gitlab-artifacts install_tmp selfinst_tmp workdir; do
    [ -d "$d" ] && rm -rf "$d" && echo "Removed $d"
done

