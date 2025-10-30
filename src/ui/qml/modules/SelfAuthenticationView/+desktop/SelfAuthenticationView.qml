/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */

import QtQuick

import Governikus.TitleBar
import Governikus.Type

SelfAuthStartView {
	id: root

	disagreeButtonText: ""

	titleBarSettings: TitleBarSettings {
		navigationAction: NavigationAction.Action.Back

		onNavigationActionClicked: root.pop()
	}

	onStartSelfAuth: SelfAuthModel.startWorkflow()
}
