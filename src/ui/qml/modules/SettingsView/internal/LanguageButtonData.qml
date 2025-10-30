/**
 * Copyright (c) 2022-2025 Governikus GmbH & Co. KG, Germany
 */
import QtQuick

ListModel {
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set language to german")
		img: "qrc:///images/location_flag_de.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("German")
		value: "de"
	}
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set language to english")
		img: "qrc:///images/location_flag_en.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("English")
		value: "en"
	}
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set language to ukrainian")
		img: "qrc:///images/location_flag_uk.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("Ukrainian")
		value: "uk"
	}
	ListElement {
		//: LABEL ALL_PLATFORMS
		desc: qsTr("Set language to russian")
		img: "qrc:///images/location_flag_ru.svg"
		//: LABEL ALL_PLATFORMS
		name: qsTr("Russian")
		value: "ru"
	}
}
