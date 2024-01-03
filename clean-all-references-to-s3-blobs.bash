#!/bin/bash
set -x
set -e # exit on non-zero status

rm .final_builds/license/index.yml
rm -rf .final_builds/packages
echo > config/blobs.yml
rm -rf releases