#!/bin/bash

#how to use:
#0.multiple configuration:
#  http://www.jianshu.com/p/83b6e781eb51
#  https://github.com/appfoundry/ios-multi-env-configuration,
#  Otherwise you can only pack Debug || Release configuration

#1.install xcode-select:xcode-select --install

#2.remove & change gem source(if your gem source is not this)
#  (目前国内的gem source好像安装不了fastlane2.0以上,可安装完后再改回来，需要fq):
#  remove: gem source -r XXX
#  add: gem source -a https://rubygems.org/

#3.install the latest version fastlane: sudo gem install fastlane

#4.push the .sh in the path of project

#5.config the key:configuration, method, pgyerUKey, pgyerApiKey
#  You just have to configure these.
#  你只需要配置这4个必须的参数，其他的全都帮你搞定了，这或许是GitHub上配置最少，最高复用性的iOS打包脚本了。

#6.permissions: chmod +x ./YHiOSPackage.sh

#7.execute: ./YHiOPackage.sh

#----------0.config

configurations=(
"Debug"
"SIT"
"UAT"
"Release"
)

#xcodebuild method: app-store, package, ad-hoc, enterprise, development, developer-id
methods=(
"development"
"development"
"development"
"development"
)

#pgyer's uKey
pgyerUKeys=(
"92e46944754274b4d49c35721af60316"
"92e46944754274b4d49c35721af60316"
"92e46944754274b4d49c35721af60316"
"92e46944754274b4d49c35721af60316"
)

#pgyer's _api_key
pgyerApiKeys=(
"b5e5d8c02b8270810a1ca94f6e4eaa51"
"b5e5d8c02b8270810a1ca94f6e4eaa51"
"b5e5d8c02b8270810a1ca94f6e4eaa51"
"b5e5d8c02b8270810a1ca94f6e4eaa51"
)

#read input:4种环境，分别对应开发，内部测试，用户测试和生产，足够用了，中间两种需要自己去建，最上面有链接
read -n 1 -p "[archive Debug(0) SIT(1) OR UAT(2) OR Release(3)? input the number 0 | 1 | 2 | 3] : " mode

length=${#configurations[@]}
if [${mode} -gt length]; then
echo "No this configuration!"
exit 1
fi

configuration=${configurations[${mode}]}
method=${methods[${mode}]}
pgyerUKey=${pgyerUKeys[${mode}]}
pgyerApiKey=${pgyerApiKeys[${mode}]}

#----------1.default config
#find projectName
projectName=`find *.xcodeproj -maxdepth 0`
projectName=${projectName%.*}

#timer
SECONDS=0
now=$(date +"%Y%m%d%H%M%S")

projectPath="$(pwd)/${projectName}.xcworkspace"

scheme="${projectName}-${configuration}"
if [ ${configuration} = "Debug" -o ${configuration} = "Release" ]; then
scheme="${projectName}"
fi
outputPath="/Users/${USER}/Desktop/${projectName}-${configuration}-ipa"
ipaName="${projectName}-${configuration}-${now}.ipa"

#get CFBundleShortVersionString
if [ ${configuration} = "Release" ]; then
projectContentPath="./$projectName"
plistPath=`find $projectContentPath -name "Info.plist"`
appVersion=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $plistPath`
outputPath="/Users/${USER}/Desktop/${projectName}-${configuration}-ipa/${appVersion}"
ipaName="${projectName}.ipa"
fi

ipaPath="${outputPath}/${ipaName}"
archivePath="${outputPath}/${projectName}-${now}.xcarchive"

echo -e "\n"
echo "[archiving ${configuration}...]"

#----------2.pod update
#pod update --verbose --no-repo-update

#----------3.acchive&export
if [ -d ${projectPath} ]; then
echo "[archiving xcworkspace...]"
fastlane gym --workspace ${projectPath} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archivePath} --export_method ${method} --output_directory ${outputPath} --output_name ${ipaName}
else
echo "[archiving xcodeproj...]"
projectPath="$(pwd)/${projectName}.xcodeproj"
fastlane gym --project ${projectPath} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archivePath} --export_method ${method} --output_directory ${outputPath} --output_name ${ipaName}
fi

#----------4.upload to pgyer
if [ -f ${ipaPath} ]; then
echo -e "\n"
echo "[Generate ${ipaPath} successfully!]"

rm -rf ${archivePath}

echo -e "\n"

#if [ ${configuration} = "Release" ] ;  then
#echo "[upload to SVN]"
#svn add ${outputPath}
#svn commit -m "commit" ${outputPath}
#fi

echo "[upload to pgyer]"
curl -F "file=@${ipaPath}" -F "uKey=${pgyerUKey}" -F "_api_key=${pgyerApiKey}" http://www.pgyer.com/apiv1/app/upload --verbose

echo -e "\n"
echo "[Every boss, The ${projectName}-${configuration} has been uploaded successfully!]"

else
echo -e "\n"
echo "[Generate ${ipaPath} fail!]"
exit 1
fi


#----------5.end
echo -e "\n"
echo "[Finished, total time: ${SECONDS}s]"
