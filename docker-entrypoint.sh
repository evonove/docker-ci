#! /bin/bash

set -e

# this image requires a $WORKSPACE environment variables, strictly
# related to Jenkins $WORKSPACE

cd $WORKSPACE
exec "$@"
