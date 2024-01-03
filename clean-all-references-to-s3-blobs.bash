#!/bin/bash
set -x
set -e # exit on non-zero status

rm -f .final_builds/license/index.yml
rm -rf .final_builds/packages
echo > config/blobs.yml
rm -rf releases

for i in $(find packages -name "index.yml"); do
cat > ${i} <<EOF
builds: { }
format-version: "2"
EOF
ls -al ${i}
cat ${i}
done