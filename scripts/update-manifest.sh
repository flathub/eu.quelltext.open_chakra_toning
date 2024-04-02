#!/bin/sh
# Open Chakra Toning
# Copyright (C) 2024  Nicco Kunzmann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

#
# Update the manifest from the latest release
#

set -e
cd "`dirname \"$0\"`"

#
# Get the source repo
#
if ! [ -d open_chakra_toning ]; then
    git clone --depth=1 https://github.com/niccokunzmann/open_chakra_toning.git
else
    (
        cd open_chakra_toning
        git pull
    )
fi
cd open_chakra_toning

#
# Get the latest version
#
git fetch --tags
latest="`git tag | sort -Vr | head -n 1`"
echo "Latest release: $latest"

#
# Check if update is needed
#
out="../../eu.quelltext.open_chakra_toning.yml"
if cat "$out" | grep -qF "releases/download/$latest"; then
    echo "Latest release is already there."
    exit
else
    echo "Update from `cat \"$out\" | grep -oE 'releases/download/[^/]*' | grep -oE 'v.*'` to $latest"
fi

#
# Generate manifest
#
flatpak/generate-release-yml.sh $latest > "$out"
cd ../..
git --no-pager diff

#
# Go to another branch and submit the manifest
#
echo "Creating a release on the update branch for $latest"
pwd
git checkout -b "update"
git config user.name "Nicco Kunzmann (bot)"
git config user.email "niccokunzmann""@rambler.ru"
git add eu.quelltext.open_chakra_toning.yml
git commit -m"$latest

see https://github.com/niccokunzmann/open_chakra_toning/releases"
git push -uf origin update
