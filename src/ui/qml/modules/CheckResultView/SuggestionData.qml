/**
 * Copyright (c) 2021-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick

import Governikus.Animations

QtObject {
	property int animationSymbol: Symbol.Type.INFO
	property int animationType: AnimationLoader.Type.STATUS
	property url continueButtonIcon
	//: LABEL ALL_PLATFORMS
	property string continueButtonText: qsTr("Continue")
	property string header
	property string hintButtonLink
	property string hintButtonText
	property string hintText
	//: LABEL ALL_PLATFORMS
	property string hintTitle: qsTr("Hint")
	property string linkToOpen
	property string text
	property int textFormat: Text.AutoText
	property string title

	signal continueClicked
	signal hintClicked
}
