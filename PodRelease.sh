#!/bin/bash
#pod trunk register email@email.com '****'  --verbose

podspecName=`find *.podspec -maxdepth 0`

read -n 1 -p "Is pod lib lint?(1: yes，anyotherkey: no): " isNativeVertify

pod repo update master

if [ ${isNativeVertify} = 1 ]; then
echo -e "\n"

pod lib lint ${podspecName} --verbose --allow-warnings --use-libraries --no-clean
fi
echo -e "\n"

read -n 1 -p "create git tag?(1: yes，anyotherkey: no): " isTag
if [ ${isTag} = 1 ]; then
releaseTagVersion=$(grep -E "s.version.+=" ${podspecName} | awk '{print $3}')
releaseTagVersionCount=${#releaseTagVersion}
releaseTagVersion=${releaseTagVersion:1:${releaseTagVersionCount}-2}
echo -e "\n"
echo "create git tag：${releaseTagVersion}"

if [ $(git tag -l "${releaseTagVersion}") ]; then
echo "Tag:${releaseTagVersion} Already exists! Please modify the tag version."

exit

else

git tag "${releaseTagVersion}"
git push --tags

fi
fi
echo -e "\n"

read -n 1 -p "pod trunk?(1: yes，anyotherkey: no): " isRelease
if [ ${isRelease} = 1 ]; then
echo -e "\n"

pod trunk push ${podspecName}
carthage build --no-skip-current

fi
echo -e "\n"
