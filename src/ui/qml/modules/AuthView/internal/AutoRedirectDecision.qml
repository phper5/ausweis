/**
 * Copyright (c) 2025 Governikus GmbH & Co. KG, Germany
 */

import Governikus.Global
import Governikus.Type

DecisionView {
	id: root

	//: INFO ALL_PLATFORMS
	agreeButtonText: qsTr("Enable manual redirection")

	//: INFO ALL_PLATFORMS
	descriptionTextsModel: [qsTr("Currently, the app automatically redirects you back to the service provider after authentication. This may not allow your screen reader to provide all information. To ensure you receive all information, enable manual redirection to the service provider."),
		//: INFO ALL_PLATFORMS
		qsTr("You can change your preference at any time in the settings.")]
	disagreeButtonHighlighted: false

	//: LABEL ALL_PLATFORMS
	disagreeButtonText: qsTr("Skip and keep automatic redirection")
	//: INFO ALL_PLATFORMS
	headlineText: qsTr("Optimize your settings for screen reading")

	customContentSourceComponent: GCheckBox {
		checked: !SettingsModel.remindUserOfAutoRedirect
		horizontalPadding: 0
		maximumLineCount: 2
		//: LABEL ALL_PLATFORMS
		text: qsTr("Do not display this message in future.")

		onCheckedChanged: SettingsModel.remindUserOfAutoRedirect = !checked
	}

	onAgreeClicked: {
		SettingsModel.autoRedirectAfterAuthentication = false;
		root.leaveView();
	}
	onDisagreeClicked: root.leaveView()
}
