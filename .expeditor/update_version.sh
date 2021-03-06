#!/bin/sh
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

VERSION=$(cat VERSION)

sed -i -r "s/^(\\s*)VERSION = \".+\"/\\1VERSION = \"$VERSION\"/" lib/license_scout/version.rb
sed -i -r "s/^(\\s*)pkg_version=\".+\"/\\1pkg_version=\"$VERSION\"/" habitat/plan.sh

# Once Expeditor finshes executing this script, it will commit the changes and push
# the commit as a new tag corresponding to the value in the VERSION file.
