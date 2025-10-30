/**
 * Copyright (c) 2019-2025 Governikus GmbH & Co. KG, Germany
 */
import QtQuick

QtObject {
	readonly property var button: TextStyle {
		fontWeight: Style.font.normal
		lineHeight: Style.dimens.lineHeight_button
		textColor: Style.color.control.content.basic
	}
	readonly property var headline: TextStyle {
		fontWeight: Style.font.medium
		lineHeight: Style.dimens.lineHeight_headline
		textColor: Style.color.textHeadline.basic
		textSize: Style.dimens.textHeadline
	}
	readonly property var link: TextStyle {
		fontWeight: Style.font.normal
		textColor: Style.color.linkBasic.basic
	}
	readonly property var navigation: TextStyle {
		fontWeight: Style.is_layout_desktop ? Style.font.medium : Style.font.normal
		lineHeight: Style.dimens.lineHeight_navigation
		textColor: Style.color.linkNavigation.basic
		textSize: Style.dimens.text_navigation
	}
	readonly property var normal: TextStyle {
		fontWeight: Style.font.normal
	}
	readonly property var subline: TextStyle {
		fontWeight: Style.font.medium
		lineHeight: Style.dimens.lineHeight_subline
		textColor: Style.color.textSubline.basic
		textSize: Style.dimens.textSubline
	}
	readonly property var tile: TextStyle {
		fontWeight: Style.font.medium
		lineHeight: Style.dimens.lineHeight_tile
		textColor: Style.color.textTitle.basic
		textSize: Style.dimens.text_tile
	}
	readonly property var title: TextStyle {
		fontWeight: Style.font.bold
		lineHeight: Style.dimens.lineHeight_title
		textColor: Style.color.textTitle.basic
		textSize: Style.dimens.textTitle
	}
}
