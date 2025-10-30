/**
 * Copyright (c) 2017-2025 Governikus GmbH & Co. KG, Germany
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Governikus.EnterPasswordView
import Governikus.Global
import Governikus.MultiInfoView
import Governikus.ProgressView
import Governikus.TitleBar
import Governikus.Type
import Governikus.View
import Governikus.Style

FlickableSectionPage {
	id: root

	property bool allowUsage: false

	signal pairedDeviceFound

	spacing: Style.dimens.pane_spacing

	//: LABEL ANDROID IOS
	title: qsTr("Manage pairings")

	navigationAction: NavigationAction {
		action: NavigationAction.Action.Back

		onClicked: root.pop()
	}

	QtObject {
		id: d

		property bool oldLockedAndHiddenStatus

		function close() {
			root.setLockedAndHidden(oldLockedAndHiddenStatus);
			root.pop();
		}
	}
	GOptionsContainer {
		containerPadding: Style.dimens.pane_padding
		containerSpacing: Style.dimens.text_spacing
		//: LABEL ANDROID IOS
		title: qsTr("Paired devices")
		visible: availablePairedDeviceList.count > 0

		Repeater {
			id: availablePairedDeviceList

			model: RemoteServiceModel.availablePairedDevices

			delegate: DevicesListDelegate {
				Layout.fillWidth: true
				description: root.allowUsage ?
				//: LABEL ANDROID IOS
				qsTr("Tap to use device") :
				//: LABEL ANDROID IOS
				qsTr("Available")
				width: availablePairedDeviceList.width

				onActivate: if (root.allowUsage)
					root.pairedDeviceFound()
			}
		}
	}
	GOptionsContainer {
		containerPadding: Style.dimens.pane_padding
		containerSpacing: Style.dimens.text_spacing
		//: LABEL ANDROID IOS
		title: qsTr("Last connected")
		visible: unavailablePairedDeviceList.count > 0

		Repeater {
			id: unavailablePairedDeviceList

			model: RemoteServiceModel.unavailablePairedDevices

			delegate: DevicesListDelegate {
				Layout.fillWidth: true
				//: LABEL ANDROID IOS
				description: qsTr("Tap to remove device")
				width: unavailablePairedDeviceList.width

				onActivate: (pIsSupported, pDeviceId) => {
					deleteDevicePopup.deviceId = pDeviceId;
					deleteDevicePopup.deviceName = remoteDeviceName;
					deleteDevicePopup.open();
				}
			}
		}
	}
	ConfirmationPopup {
		id: deleteDevicePopup

		property var deviceId
		property string deviceName

		//: INFO ANDROID IOS
		okButtonText: qsTr("Remove")
		//: INFO ANDROID IOS
		text: qsTr("Do you want to remove the pairing of the device \"%1\"?").arg(deviceName)

		//: INFO ANDROID IOS
		title: qsTr("Remove pairing")

		onConfirmed: RemoteServiceModel.forgetDevice(deviceId)
	}
	GOptionsContainer {
		containerPadding: Style.dimens.pane_padding
		containerSpacing: Style.dimens.text_spacing
		//: LABEL ANDROID IOS
		title: qsTr("Add pairing")

		Repeater {
			id: searchDeviceList

			model: RemoteServiceModel.availableDevicesInPairingMode
			visible: ApplicationModel.wifiEnabled && count > 0

			delegate: DevicesListDelegate {
				Layout.fillWidth: true
				//: LABEL ANDROID IOS
				description: qsTr("Tap to pair")
				width: searchDeviceList.width

				onActivate: (pIsSupported, pDeviceId) => {
					if (pIsSupported && RemoteServiceModel.rememberServer(pDeviceId)) {
						d.oldLockedAndHiddenStatus = root.getLockedAndHidden();
						root.setLockedAndHidden();
						root.push(enterPinView);
					}
				}
			}
		}
		GText {
			//: INFO ANDROID IOS Wifi is not enabled and no new devices can be paired.
			text: qsTr("Please connect your WiFi to use another smartphone as card reader (SaC).")
			visible: !ApplicationModel.wifiEnabled
		}
		GButton {
			Layout.alignment: Qt.AlignHCenter

			//: LABEL ANDROID IOS
			text: qsTr("Enable WiFi")
			visible: !ApplicationModel.wifiEnabled

			onClicked: ApplicationModel.enableWifi()
		}
		LocalNetworkInfo {
			visible: RemoteServiceModel.requiresLocalNetworkPermission && !RemoteServiceModel.remoteReaderVisible
		}
		PairingProcessInfo {
			visible: !searchDeviceList.visible && ApplicationModel.wifiEnabled

			onInfoLinkClicked: root.push(noSacFoundInfo)
		}
		Component {
			id: noSacFoundInfo

			MultiInfoView {
				progress: root.progress

				infoContent: MultiInfoData {
					contentType: MultiInfoData.Type.NO_SAC_FOUND
				}
				navigationAction: NavigationAction {
					action: NavigationAction.Action.Back

					onClicked: root.pop()
				}
			}
		}
	}
	Component {
		id: enterPinView

		EnterPasswordView {
			passwordType: NumberModel.PasswordType.REMOTE_PIN
			progress: root.progress
			//: LABEL ANDROID IOS
			title: qsTr("Pairing code")

			navigationAction: NavigationAction {
				action: NavigationAction.Action.Cancel

				onClicked: d.close()
			}

			onPasswordEntered: replace(pairingProgressView)
		}
	}
	Component {
		id: pairingProgressView

		ProgressView {
			//: LABEL ANDROID IOS
			headline: qsTr("Pairing the device ...")
			progress: root.progress
			title: root.title

			Connections {
				function onFirePairingFailed(pDeviceName, pErrorMessage) {
					root.replace(pairingFailedComponent, {
						deviceName: pDeviceName,
						errorMessage: pErrorMessage
					});
				}
				function onFirePairingSuccess(pDeviceName) {
					root.replace(pairingSuccessComponent, {
						deviceName: pDeviceName
					});
				}

				target: RemoteServiceModel
			}
		}
	}
	Component {
		id: pairingFailedComponent

		PairingFailedView {
			progress: root.progress
			title: root.title

			navigationAction: NavigationAction {
				action: NavigationAction.Action.Back

				onClicked: d.close()
			}

			onContinueClicked: d.close()
		}
	}
	Component {
		id: pairingSuccessComponent

		PairingSuccessView {
			id: pairingSuccessView

			function close() {
				d.close();
				root.pairedDeviceFound();
			}

			progress: root.progress
			title: root.title

			navigationAction: NavigationAction {
				action: NavigationAction.Action.Back

				onClicked: pairingSuccessView.close()
			}

			onContinueClicked: close()
		}
	}
}
