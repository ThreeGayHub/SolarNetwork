#!/bin/bash
#pod trunk register email@email.com '****'  --verbose

read -p "intput tag: " aTag

echo "tag is ${aTag}"

read -n 1 -p "Any key to continue"

git tag "${aTag}"
git push --tags
pod trunk push SolarNetwork.podspec

carthage build --no-skip-current
#carthage archive SolarNetwork
