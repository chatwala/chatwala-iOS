#!/bin/bash

############################################################################################################
############################################################################################################
# Builds
############################################################################################################
############################################################################################################

buildNotes=$1

echo "Build Notes: "
echo $buildNotes

buildsFolder="../Builds"

appVersion="1.0.6"
internalVersion="2.5.14"
displayName="chatwala"
cwDebugIdentity="\"iPhone Developer: Rahul Kumar (59L7REF9QB)\""
cwAppStoreIdentity="\"iPhone Distribution: Chatwala Inc\""
testFlightApiToken="dea9bae9bb2a21f4d8e0886a8ccf6926_MTQwMDM3ODIwMTMtMTAtMjUgMTc6NDk6MTYuNTM0OTky"
testFlightTeamToken="39b66a1f73c7144a3ded703c30a9a01e_Mjk1OTAxMjAxMy0xMS0wNyAxNzo0MjowNy4wOTMyMjI"

uploadTestflight() {
  buildType=$1
  appVersion=$2
  internalVersion=$3
  ipa=$4

  dSYM=~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app.dSYM

  echo "zipping up dSYM"

  echo $buildType
  echo $appVersion
  echo $internalVersion
  echo $ipa

  # we don't want multiple DWARF binaries in this zip, so just grab one of them (dunno why this happens)
  #zip -r -T -y $dSYM.zip $dSYM/Sender.dSYM || 
  zip -r -T -y $dSYM.zip $dSYM

  echo "Uploading "$buildType build v$appVersion \($internalVersion\)" to TestFlight:"
  echo Team token $testFlightTeamToken

  /usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"$ipa" \
  -F dsym=@"$dSYM.zip" \
  -F api_token="$testFlightApiToken" \
  -F team_token="$testFlightTeamToken" \
  -F notes="$buildNotes" \
  -F notify="False" \
  -F distribution_lists='Developers'
}


# build (Project-Scheme, BuildType, CodeSigningIdentity, Profile name, other build flags)
build() {
  scheme=$1
  buildType=$2
  configuration=$3
  codeSignIdentity=$4
  provisioningProfileName=$5
  otherOptions=$6

  #archive
  rm -rf ~/DEsktop/Builds/$buildType/$appVersion/$internalVersion/
  #ipa
  rm -f ~/Desktop/Builds/IPA/Sender.$buildType.$appVersion.$internalVersion.ipa
  echo Cleaned up directory structure

  echo Starting xcodebuild for $scheme $configuration $buildSuffix $buildType

  # Touch the app plists so it gets reprocessed
  touch ../Sender/*.plist

  mkdir -p ~/Desktop/Builds/IPA	
  ipaLocation=~/Desktop/Builds/IPA/Sender.$buildType.$appVersion.$internalVersion.ipa  
  
  # Make App Store version
  if [ "$buildType" == "AppStore" ] ; then
	#archiving
    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration CODE_SIGN_IDENTITY="iPhone Distribution: Chatwala Inc" CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$internalVersion CW_DISPLAY_NAME=$displayName CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion $otherOptions || exit 1
	
	#packaging
    xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Distribution: Chatwala Inc" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1

  # Make Debug certificate version for testing
  else

    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration CODE_SIGN_IDENTITY="iPhone Developer: Kevin Miller (K4K3WC48B2)" CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$internalVersion CW_DISPLAY_NAME=$displayName"dev" CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion $otherOptions || exit 1
	xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Developer: Kevin Miller (K4K3WC48B2)" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1
  fi
  
  
  if [ "$buildType" != "AppStore" ] ; then

    # Upload to testFlight
    uploadTestflight $buildType $appVersion $internalVersion $ipaLocation || echo Failed upload to test flight

  fi

}

xcodebuild -workspace ../Sender.xcworkspace -scheme Sender -configuration Release clean

# build (Project-Scheme, BuildType, CodeSigningIdentity, Profile name, other build flags)
build 'Sender' 'AppStore' 'Release' "$cwAppStoreIdentity" 'B7AD3FC8-E51A-4236-9465-BFA74A6E6C7F.mobileprovision' ''
build 'Sender' 'Dev' 'Release' "$cwDebugIdentity" '89CDDA38-8825-40E3-BBF8-17EEFD0526AF.mobileprovision' 'USE_DEV_SERVER=1'
