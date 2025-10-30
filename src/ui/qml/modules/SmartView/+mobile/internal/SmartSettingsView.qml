/**
 * Copyright (c) 2021-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick
import QtQuick.Layouts

import Governikus.Global
import Governikus.Type
import Governikus.Style

ColumnLayout {
	id: root

	readonly property int smartState: SmartModel.state

	signal changePin
	signal deletePersonalization
	signal startSelfAuth
	signal updateSmart

	GOptionsContainer {
		Layout.fillWidth: true
		spacing: Style.dimens.pane_spacing

		//: LABEL ANDROID IOS
		title: qsTr("Smart-eID")

		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Show Smart-eID data")

			//: LABEL ANDROID IOS
			title: qsTr("Try Smart-eID")
			visible: root.smartState === SmartModel.State.READY

			onClicked: root.startSelfAuth()
		}
		GSeparator {
			Layout.fillWidth: true
			Layout.leftMargin: Style.dimens.pane_spacing
			Layout.rightMargin: Layout.leftMargin
		}
		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Change the chosen Smart-eID PIN")

			//: LABEL ANDROID IOS
			title: qsTr("Change Smart-eID PIN")
			visible: root.smartState === SmartModel.State.READY

			onClicked: root.changePin()
		}
		GSeparator {
			Layout.fillWidth: true
			Layout.leftMargin: Style.dimens.pane_spacing
			Layout.rightMargin: Layout.leftMargin
		}
		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Renew your Smart-eID with current data")

			//: LABEL ANDROID IOS
			title: qsTr("Renew Smart-eID")
			visible: root.smartState === SmartModel.State.READY

			onClicked: root.updateSmart()
		}
		GSeparator {
			Layout.fillWidth: true
			Layout.leftMargin: Style.dimens.pane_spacing
			Layout.rightMargin: Layout.leftMargin
		}
		GMenuItem {
			Layout.fillWidth: true
			//: LABEL ANDROID IOS
			description: qsTr("Delete Smart-eID data from your device")

			//: LABEL ANDROID IOS
			title: qsTr("Delete Smart-eID")
			visible: root.smartState === SmartModel.State.READY

			onClicked: root.deletePersonalization()
		}
	}
}
