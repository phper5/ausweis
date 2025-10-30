/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick.Layouts

import Governikus.Global

GPane {
	id: root

	signal showDiagnosis
	signal showLogs

	GMenuItem {
		Layout.fillWidth: true
		//: LABEL DESKTOP
		buttonText: qsTr("Show system data")
		iconSource: "qrc:/images/info.svg"

		//: LABEL DESKTOP
		title: qsTr("System data")

		onClicked: root.showDiagnosis()
	}
	GSeparator {
		Layout.fillWidth: true
	}
	GMenuItem {
		Layout.fillWidth: true
		//: LABEL DESKTOP
		buttonText: qsTr("Show logs")
		iconSource: "qrc:/images/desktop/list_icon.svg"

		//: LABEL DESKTOP
		title: qsTr("Logs")

		onClicked: root.showLogs()
	}
}
