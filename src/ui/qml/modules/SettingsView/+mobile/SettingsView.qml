/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import Governikus.Global
import Governikus.View
import Governikus.RemoteServiceView
import Governikus.SmartView
import Governikus.Type
import Governikus.Style

FlickableSectionPage {
	id: root

	enableTileStyle: false
	spacing: Style.dimens.pane_spacing
	//: LABEL ANDROID IOS
	title: qsTr("Settings")

	GOptionsContainer {
		//: LABEL ANDROID IOS
		title: qsTr("General")

		GRadioGroup {
			id: languageCollapsible

			contentBottomMargin: 0
			contentHorizontalMargin: 0
			contentSpacing: 0
			contentTopMargin: 0
			drawTopCorners: true
			//: LABEL ANDROID IOS
			title: qsTr("Change language")

			LanguageButtons {
				id: languageButtons

				onButtonClicked: languageCollapsible.onOptionSelected()
			}
		}
		SettingsViewSeparator {
		}
		GRadioGroup {
			id: appearanceCollapsible

			contentBottomMargin: 0
			contentHorizontalMargin: 0
			contentSpacing: 0
			contentTopMargin: 0
			tintIcon: true
			//: LABEL ANDROID IOS
			title: qsTr("Appearance")

			DarkModeButtons {
				id: modeButtons

				width: parent.width

				onButtonClicked: appearanceCollapsible.onOptionSelected()
			}
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Toggling will restart the %1").arg(Qt.application.name)
			//: LABEL ANDROID IOS
			text: qsTr("Use system font")

			Component.onCompleted: {
				checked = SettingsModel.useSystemFont;
			}
			onCheckedChanged: {
				if (checked !== SettingsModel.useSystemFont) {
					SettingsModel.useSystemFont = checked;
					UiPluginModel.doRefresh();
				}
			}
		}
		SettingsViewSeparator {
			visible: technologySwitch.visible
		}
		TechnologySwitch {
			id: technologySwitch

			contentBottomMargin: 0
			contentHorizontalMargin: 0
			contentSpacing: 0
			contentTopMargin: 0
			drawBottomCorners: true
			visible: hasSelection
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("Accessibility")

		GSwitch {
			Layout.fillWidth: true
			checked: !SettingsModel.useAnimations
			drawTopCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Use images instead of animations")

			onCheckedChanged: SettingsModel.useAnimations = !checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.visualPrivacy
			//: LABEL ANDROID IOS
			text: qsTr("Hide key animations when entering PIN")

			onCheckedChanged: SettingsModel.visualPrivacy = checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: !SettingsModel.autoRedirectAfterAuthentication
			//: LABEL ANDROID IOS
			description: qsTr("After identification, you will only be redirected back to the provider after confirmation. Otherwise, you will be redirected automatically after a few seconds.")
			drawBottomCorners: true
			//: LABEL ANDROID IOS
			text: qsTr("Manual redirection back to the provider")

			onCheckedChanged: SettingsModel.autoRedirectAfterAuthentication = !checked
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("Smartphone as card reader")

		GCollapsible {
			alwaysReserveSelectionTitleHeight: true
			contentBottomMargin: 0
			contentTopMargin: 0
			drawTopCorners: true
			selectionTitle: expanded ? "" : SettingsModel.deviceName
			//: LABEL ANDROID IOS
			title: qsTr("Device name")

			GTextField {
				function saveInput() {
					focus = false;
					SettingsModel.deviceName = text;
				}

				Layout.fillWidth: true
				Layout.margins: Style.dimens.pane_spacing
				maximumLength: 33
				text: SettingsModel.deviceName

				onAccepted: saveInput()
				onFocusChanged: if (!focus)
					saveInput()
			}
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.pinPadMode

			//: LABEL ANDROID IOS
			text: qsTr("Enter PIN on this device")

			onCheckedChanged: SettingsModel.pinPadMode = checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.showAccessRights
			enabled: SettingsModel.pinPadMode

			//: LABEL ANDROID IOS
			text: qsTr("Show requested rights on this device as well")

			onCheckedChanged: SettingsModel.showAccessRights = checked
		}
		SettingsViewSeparator {
		}
		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Add and remove devices")
			drawBottomCorners: true

			//: LABEL ANDROID IOS
			title: qsTr("Manage pairings")

			onClicked: root.push(remoteServiceSettings)

			Component {
				id: remoteServiceSettings

				RemoteServiceSettings {
					enableTileStyle: root.enableTileStyle

					Component.onCompleted: RemoteServiceModel.startDetection()
					Component.onDestruction: RemoteServiceModel.stopDetection(true)
				}
			}
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("Numeric keypad")

		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.shuffleScreenKeyboard
			//: LABEL ANDROID IOS
			description: qsTr("Makes it difficult for outsiders to detect PIN entry")
			drawTopCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Shuffle keys")

			onCheckedChanged: SettingsModel.shuffleScreenKeyboard = checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.visualPrivacy
			//: LABEL ANDROID IOS
			description: qsTr("Makes it difficult for outsiders to detect PIN entry")
			drawBottomCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Hide key animations")

			onCheckedChanged: SettingsModel.visualPrivacy = checked
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("Smart-eID")
		visible: ApplicationModel.smartSupported

		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Reset Smart-eID data on your device")
			//: LABEL ANDROID IOS
			title: qsTr("Reset Smart-eID")

			onClicked: root.push(smartDeleteView)

			Component {
				id: smartDeleteView

				SmartResetView {
				}
			}
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("On-site reading")
		visible: SettingsModel.advancedSettings

		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.enableCanAllowed
			drawTopCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Support CAN allowed mode for on-site reading")

			onCheckedChanged: SettingsModel.enableCanAllowed = checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.skipRightsOnCanAllowed
			drawBottomCorners: true
			enabled: SettingsModel.enableCanAllowed

			//: LABEL ANDROID IOS
			text: qsTr("Skip rights page")

			onCheckedChanged: SettingsModel.skipRightsOnCanAllowed = checked
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true
		//: LABEL ANDROID IOS
		title: qsTr("Developer options")
		visible: SettingsModel.advancedSettings

		GSwitch {
			id: testUriSwitch

			Layout.fillWidth: true
			checked: SettingsModel.useSelfauthenticationTestUri
			//: LABEL ANDROID IOS
			description: qsTr("Allow test sample card usage")
			drawTopCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Testmode for the self-authentication")

			onCheckedChanged: SettingsModel.useSelfauthenticationTestUri = checked
		}
		SettingsViewSeparator {
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.enableSimulator
			//: LABEL ANDROID IOS
			description: qsTr("Simulate a test sample card in authentications")
			drawBottomCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Internal card simulator")

			onCheckedChanged: SettingsModel.enableSimulator = checked
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true

		//: LABEL ANDROID IOS
		title: qsTr("Debug options")
		visible: UiPluginModel.debugBuild

		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.developerMode
			//: LABEL ANDROID IOS
			description: qsTr("Use a more tolerant mode")
			drawTopCorners: true

			//: LABEL ANDROID IOS
			text: qsTr("Developer mode")

			onCheckedChanged: SettingsModel.developerMode = checked
		}
		SettingsViewSeparator {
		}
		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Show Transport PIN reminder, store feedback and close reminder dialogs.")
			drawBottomCorners: true
			icon.source: "qrc:///images/material_refresh.svg"
			//: LABEL ANDROID IOS
			title: qsTr("Reset hideable dialogs")

			onClicked: SettingsModel.resetHideableDialogs()
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true

		//: LABEL ANDROID IOS
		title: qsTr("Extend Transport PIN")
		visible: UiPluginModel.debugBuild

		Flow {
			Layout.fillWidth: true
			padding: Style.dimens.pane_padding
			spacing: Style.dimens.pane_spacing

			GButton {
				Layout.minimumWidth: implicitHeight
				checkable: true
				checked: SettingsModel.appendTransportPin === ""
				style: Style.color.controlOptional
				//: LABEL ANDROID IOS
				text: qsTr("Disable")

				onClicked: SettingsModel.appendTransportPin = ""
			}
			Repeater {
				model: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

				GButton {
					required property string modelData

					Layout.minimumWidth: implicitHeight
					checkable: true
					checked: SettingsModel.appendTransportPin === modelData
					style: Style.color.controlOptional
					text: modelData

					onClicked: SettingsModel.appendTransportPin = modelData
				}
			}
		}
	}
	GOptionsContainer {
		Layout.fillWidth: true

		//: LABEL ANDROID IOS
		title: qsTr("Create dummy entries")
		visible: UiPluginModel.debugBuild

		ColumnLayout {
			spacing: Style.dimens.pane_spacing

			GButton {
				Layout.leftMargin: Style.dimens.pane_padding
				Layout.rightMargin: Style.dimens.pane_padding
				Layout.topMargin: Style.dimens.pane_padding

				//: LABEL ALL_PLATFORMS
				text: qsTr("New Logfile")

				onClicked: {
					LogFilesModel.saveDummyLogFile();
					ApplicationModel.showFeedback("Created new logfile.");
				}
			}
			GButton {
				Layout.bottomMargin: Style.dimens.pane_padding
				Layout.leftMargin: Style.dimens.pane_padding
				Layout.rightMargin: Style.dimens.pane_padding

				//: LABEL ALL_PLATFORMS
				text: qsTr("15 days old Logfile")

				onClicked: {
					let date = new Date();
					date.setDate(new Date().getDate() - 15);
					LogFilesModel.saveDummyLogFile(date);
					ApplicationModel.showFeedback("Created old logfile.");
				}
			}
		}
	}

	component SettingsViewSeparator: GSeparator {
		Layout.fillWidth: true
		Layout.leftMargin: Style.dimens.pane_spacing
		Layout.rightMargin: Layout.leftMargin
	}
}
