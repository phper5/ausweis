/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick
import QtQuick.Layouts

import Governikus.Global
import Governikus.Style
import Governikus.Type

ColumnLayout {
	spacing: Style.dimens.pane_spacing

	GPane {
		Layout.fillWidth: true
		contentPadding: 0
		contentSpacing: 0
		//: LABEL DESKTOP
		title: qsTr("Numeric keypad")

		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.shuffleScreenKeyboard
			//: LABEL DESKTOP
			description: qsTr("Makes it difficult for outsiders to detect PIN entry")

			//: LABEL DESKTOP
			text: qsTr("Shuffle keys")

			onCheckedChanged: SettingsModel.shuffleScreenKeyboard = checked
		}
		GSwitch {
			Layout.fillWidth: true
			checked: SettingsModel.visualPrivacy
			//: LABEL DESKTOP
			description: qsTr("Makes it difficult for outsiders to detect PIN entry")
			drawBottomCorners: true

			//: LABEL DESKTOP
			text: qsTr("Hide key animations")

			onCheckedChanged: SettingsModel.visualPrivacy = checked
		}
	}
}
