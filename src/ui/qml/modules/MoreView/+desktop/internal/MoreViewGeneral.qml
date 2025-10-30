/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick
import QtQuick.Layouts

import Governikus.Global
import Governikus.Type

GPane {
	id: root

	signal startOnboarding

	GMenuItem {
		Layout.fillWidth: true
		//: LABEL DESKTOP
		buttonText: qsTr("Start setup")
		iconSource: "qrc:/images/npa.svg"
		tintIcon: false
		//: LABEL DESKTOP
		title: qsTr("Setup")

		onClicked: root.startOnboarding()
	}
	GSeparator {
		Layout.fillWidth: true
	}
	GMenuItem {
		Layout.fillWidth: true
		buttonIconSource: "qrc:///images/open_website.svg"
		//: LABEL DESKTOP
		buttonText: qsTr("Open website")
		buttonTooltip: "https://www.ausweisapp.bund.de/%1/aa2/faq".arg(SettingsModel.language)
		iconSource: "qrc:/images/faq_icon.svg"
		linkToOpen: buttonTooltip

		//: LABEL DESKTOP
		title: qsTr("FAQ - Frequently asked questions")
	}
	GSeparator {
		Layout.fillWidth: true
	}
	GMenuItem {
		Layout.fillWidth: true
		buttonIconSource: "qrc:///images/open_website.svg"
		//: LABEL DESKTOP
		buttonText: qsTr("Open website")
		buttonTooltip: "https://www.ausweisapp.bund.de/%1/aa2/support".arg(SettingsModel.language)
		iconSource: "qrc:/images/desktop/help_icon.svg"
		linkToOpen: buttonTooltip

		//: LABEL DESKTOP
		title: qsTr("Contact")
	}
	GSeparator {
		Layout.fillWidth: true
	}
	GMenuItem {
		Layout.fillWidth: true
		buttonIconSource: "qrc:///images/open_website.svg"
		//: LABEL DESKTOP
		buttonText: qsTr("Open website")
		buttonTooltip: "https://www.ausweisapp.bund.de/%1/aa2/providerlist".arg(SettingsModel.language)
		iconSource: "qrc:/images/identify.svg"
		linkToOpen: buttonTooltip

		//: LABEL DESKTOP
		title: qsTr("List of Providers")
	}
}
