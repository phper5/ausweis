/**
 * Copyright (c) 2017-2025 Governikus GmbH & Co. KG, Germany
 */

pragma ComponentBehavior: Bound

import QtQuick

import Governikus.Type

GRadioGroup {
	id: root

	readonly property bool hasSelection: nfcSupported || simulatorEnabled || smartSupported
	readonly property bool nfcSupported: ApplicationModel.nfcState !== ApplicationModel.NfcState.UNAVAILABLE
	readonly property bool simulatorEnabled: SettingsModel.enableSimulator
	readonly property bool smartSupported: ApplicationModel.smartSupported

	tintIcon: true
	//: LABEL ANDROID IOS
	title: qsTr("Readout mode")
	width: parent.width

	TechnologyButton {
		img: "qrc:///images/mobile/icon_nfc.svg"
		//: LABEL ANDROID IOS
		name: qsTr("by NFC")
		value: ReaderManagerPluginType.NFC
		visible: root.nfcSupported
	}
	TechnologyButton {
		img: "qrc:///images/mobile/icon_smart.svg"
		//: LABEL ANDROID IOS
		name: qsTr("by Smart-eID")
		value: ReaderManagerPluginType.SMART
		visible: root.smartSupported
	}
	TechnologyButton {
		drawBottomCorners: !SettingsModel.enableSimulator
		img: "qrc:///images/mobile/icon_remote.svg"
		//: LABEL ANDROID IOS
		name: qsTr("by smartphone as card reader")
		value: ReaderManagerPluginType.REMOTE_IFD
	}
	TechnologyButton {
		drawBottomCorners: true
		img: "qrc:///images/mobile/icon_simulator.svg"
		//: LABEL ANDROID IOS
		name: qsTr("by internal card simulator")
		value: ReaderManagerPluginType.SIMULATOR
		visible: root.simulatorEnabled
	}

	component TechnologyButton: GRadioButton {
		required property int value

		checked: SettingsModel.preferredTechnology === value
		desc: ""
		tintIcon: true

		onClicked: {
			SettingsModel.preferredTechnology = value;
			root.onOptionSelected();
		}
	}
}
