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

appVersion="1.4.1"
internalVersion="2.7.8"
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
  rm -rf ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/
  #ipa
  rm -f ~/Desktop/Builds/IPA/Sender.$buildType.$appVersion.$internalVersion.ipa
  echo Cleaned up directory structure

  xcodebuild -workspace ../Sender.xcworkspace -scheme Sender -configuration Release clean		

  echo Starting xcodebuild for $scheme $configuration $buildSuffix $buildType

  # Touch the app plists so it gets reprocessed
  touch ../Sender/*.plist
  touch ../Sender/*.pch

  mkdir -p ~/Desktop/Builds/IPA	
  ipaLocation=~/Desktop/Builds/IPA/Sender.$buildType.$appVersion.$internalVersion.ipa  
  
  # Make App Store version
  if [ "$buildType" == "AppStore" ] ; then
    #archiving
    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration GCC_PREPROCESSOR_DEFINITIONS=$otherOptions CODE_SIGN_IDENTITY="iPhone Distribution: Chatwala Inc" CW_BUNDLE_IDENTIFIER="com.chatwala.chatwala" CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$internalVersion CW_DISPLAY_NAME=$displayName CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion || exit 1
	
	#packaging
    xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Distribution: Chatwala Inc" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1

  # Make Debug certificate version for testing
  elif [ "$buildType" == "dev" ] ; then
    devInternalVersion="$buildType-$internalVersion"

    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration GCC_PREPROCESSOR_DEFINITIONS=$otherOptions CODE_SIGN_IDENTITY="iPhone Developer: Chatwala Master (4NGCTASJ2H)" CW_BUNDLE_IDENTIFIER="com.chatwala."$buildType CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$devInternalVersion CW_DISPLAY_NAME=$displayName$buildType CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion || exit 1
	xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Developer: Chatwala Master (4NGCTASJ2H)" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1

  elif [ "$buildType" == "qa" ] ; then
  	qaInternalVersion="$buildType-$internalVersion"

    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration GCC_PREPROCESSOR_DEFINITIONS=$otherOptions CODE_SIGN_IDENTITY="iPhone Developer: Chatwala Master (4NGCTASJ2H)" CW_BUNDLE_IDENTIFIER="com.chatwala."$buildType CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$qaInternalVersion CW_DISPLAY_NAME=$displayName$buildType CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion || exit 1
	xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Developer: Chatwala Master (4NGCTASJ2H)" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1
  elif [ "$buildType" == "prod" ] ; then

    xcodebuild -workspace ../Sender.xcworkspace -scheme $scheme -configuration $configuration GCC_PREPROCESSOR_DEFINITIONS=$otherOptions CODE_SIGN_IDENTITY="iPhone Distribution: Chatwala Inc" CW_BUNDLE_IDENTIFIER="com.chatwala.chatwala" CW_APP_VERSION=$appVersion CW_BUILD_VERSION=$internalVersion CW_DISPLAY_NAME=$displayName CONFIGURATION_BUILD_DIR=~/Desktop/Builds/$buildType/$appVersion/$internalVersion || exit 1
	xcrun -sdk iphoneos PackageApplication -v ~/Desktop/Builds/$buildType/$appVersion/$internalVersion/Sender.app --sign "iPhone Distribution: Chatwala Inc" -o $ipaLocation --embed "/Users/airswoop1/Library/MobileDevice/Provisioning Profiles/"$provisioningProfileName || exit 1
  
  fi
  
  
  if [ "$buildType" != "AppStore" ] ; then

    # Upload to testFlight
    uploadTestflight $buildType $appVersion $internalVersion $ipaLocation || echo Failed upload to test flight

  fi

}

# build (Project-Scheme, BuildType, CodeSigningIdentity, Profile name, other build flags)
#build 'Sender' 'AppStore' 'Release' "$cwAppStoreIdentity" 'B7AD3FC8-E51A-4236-9465-BFA74A6E6C7F.mobileprovision' 'CW_URL_SCHEME=chatwala'

#development signed builds


#build 'Sender' 'prod' 'Release' "$cwDebugIdentity" '68D670EB-0A45-433B-9EF5-CA94D0B7197A.mobileprovision' 'CW_URL_SCHEME=chatwala'

#build 'Sender' 'dev' 'Release' "$cwDebugIdentity" '2516BD10-731C-4AE3-B9D5-651227406C4E.mobileprovision' 'USE_DEV_SERVER=1  CW_URL_SCHEME=chatwala-dev'
build 'Sender' 'qa' 'Release' "$cwDebugIdentity" '7A16570A-50AB-4FD7-8BA1-D259DF7654FE.mobileprovision' 'USE_QA_SERVER=1 CW_URL_SCHEME=chatwala-qa'