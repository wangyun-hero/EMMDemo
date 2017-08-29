#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "EMMKit/EMMKit/Client/Resources/docs/buildserver.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/EMM.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_jpg.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_other.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_pdf.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_png.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_ppt.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_word.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_xis.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/maserver.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/productshow.pptx"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/studio.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_head@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_head@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_password@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_password@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_invisible@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_invisible@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_visible@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_visible@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_username@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_username@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/message/line.png"
  install_resource "EMMKit/EMMKit/Client/Resources/message/Message.plist"
  install_resource "EMMKit/EMMKit/Client/Resources/message/rightArrow@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_avatar_placeholder@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_about@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_about@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_autoLogin@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_autoLogin@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_feedback@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_feedback@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_fingerprint@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_fingerprint@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_headIcon@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_headIcon@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_modifyPW@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_modifyPW@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_QRcode@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_QRcode@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_personal_info.plist"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_settings.json"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/feedback_placeholder.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/navigationItem_back@2x.png"
  install_resource "EMMKit/EMMKit/Client/Login/EMMLoginViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageDetailTableViewCell.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageDetailViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageMainTableViewCell.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageMainViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMFeedbackViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPasswordViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPersonInfoAvatarCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPersonInfoCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMSettingCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMSettingInfoCell.xib"
  install_resource "EMMKit/EMMKit/Core/Device/emm_round_back@2x.png"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_demo_results.bundle"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_uda_demo.bundle"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_uda_production.bundle"
  install_resource "EMMKit/EMMKit/Resources/shake.mp3"
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "SAMKeychain/Support/SAMKeychain.bundle"
  install_resource "SUMCDVPlugins/SUMCDVPlugins/cordova-plugin-dialogs/CDVNotification.bundle"
  install_resource "SUMCDVPlugins/SUMCDVPlugins/cordova-plugin-media-capture/CDVCapture.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "EMMKit/EMMKit/Client/Resources/docs/buildserver.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/EMM.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_jpg.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_other.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_pdf.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_png.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_ppt.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_word.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/emm_xis.png"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/maserver.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/productshow.pptx"
  install_resource "EMMKit/EMMKit/Client/Resources/docs/studio.pdf"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_head@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_head@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_password@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_password@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_invisible@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_invisible@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_visible@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_pwd_visible@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_username@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/login/login_username@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/message/line.png"
  install_resource "EMMKit/EMMKit/Client/Resources/message/Message.plist"
  install_resource "EMMKit/EMMKit/Client/Resources/message/rightArrow@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_avatar_placeholder@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_about@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_about@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_autoLogin@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_autoLogin@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_feedback@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_feedback@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_fingerprint@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_fingerprint@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_headIcon@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_headIcon@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_modifyPW@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_modifyPW@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_QRcode@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_more_QRcode@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_personal_info.plist"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/emm_settings.json"
  install_resource "EMMKit/EMMKit/Client/Resources/setting/feedback_placeholder.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_appcenter_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_contacts_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_document_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_message_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings_@2x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/emm_settings_@3x.png"
  install_resource "EMMKit/EMMKit/Client/Resources/tabs/navigationItem_back@2x.png"
  install_resource "EMMKit/EMMKit/Client/Login/EMMLoginViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageDetailTableViewCell.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageDetailViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageMainTableViewCell.xib"
  install_resource "EMMKit/EMMKit/Client/Message/MessageMainViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMFeedbackViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPasswordViewController.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPersonInfoAvatarCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMPersonInfoCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMSettingCell.xib"
  install_resource "EMMKit/EMMKit/Client/Setting/EMMSettingInfoCell.xib"
  install_resource "EMMKit/EMMKit/Core/Device/emm_round_back@2x.png"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_demo_results.bundle"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_uda_demo.bundle"
  install_resource "EMMKit/EMMKit/Core/UDA/emm_uda_production.bundle"
  install_resource "EMMKit/EMMKit/Resources/shake.mp3"
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "SAMKeychain/Support/SAMKeychain.bundle"
  install_resource "SUMCDVPlugins/SUMCDVPlugins/cordova-plugin-dialogs/CDVNotification.bundle"
  install_resource "SUMCDVPlugins/SUMCDVPlugins/cordova-plugin-media-capture/CDVCapture.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
