/**
 * Copyright (c) 2023-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick
import Governikus.Type

ListModel {
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set the app appearance to system mode")
		img: "qrc:///images/appearance_system_mode.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("System")
		value: SettingsModel.ModeOption.AUTO
	}
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set the app appearance to dark mode")
		img: "qrc:///images/appearance_dark_mode.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("Dark")
		value: SettingsModel.ModeOption.ON
	}
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set the app appearance to light mode")
		img: "qrc:///images/appearance_light_mode.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("Light")
		value: SettingsModel.ModeOption.OFF
	}
}
