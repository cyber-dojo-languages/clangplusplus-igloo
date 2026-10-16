#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep --quiet '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep --quiet --fixed-strings "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

apt-get install --yes curl git

# Install the newest igloo release. GitHub redirects releases/latest to the
# newest release's tag, which is resolved here at build time so a rebuild
# picks up the next release by itself. Tags are named igloo.<version>.
readonly IGLOO_LATEST_URL=$(curl --silent --fail --output /dev/null --write-out '%{redirect_url}' \
  https://github.com/joakimkarlsson/igloo/releases/latest)
readonly IGLOO_TAG="${IGLOO_LATEST_URL##*/}"

# An empty tag means the redirect could not be read or has changed shape,
# not that igloo stopped releasing, so stop rather than install nothing.
if [ -z "${IGLOO_TAG}" ]; then
  echo 'Found no igloo release tag at github.com/joakimkarlsson/igloo' >&2
  exit 1
fi

cd /usr/src
git clone --branch "${IGLOO_TAG}" --recurse-submodules https://github.com/joakimkarlsson/igloo.git

mkdir -p /usr/include/igloo
cp -rfv /usr/src/igloo/igloo/ /usr/include

# Igloo holds its contexts, its output and snowhouse's last exception in
# std::auto_ptr, which libstdc++ marks deprecated. Every file including igloo
# would then print a page of warnings on each [test] press. Each auto_ptr is
# only ever assigned a fresh temporary, so std::unique_ptr is a drop-in.
grep --recursive --files-with-matches 'std::auto_ptr' /usr/include/igloo \
  | xargs --no-run-if-empty sed --in-place 's/std::auto_ptr/std::unique_ptr/g'

rm -rf /usr/src/igloo
apt-get remove --yes git

add_test_framework Igloo "${IGLOO_TAG#igloo.}"
cat /versions.json
