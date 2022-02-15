import FishUI 1.0 as FishUI
import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Item {
    id: control

    property bool checked: false
    property bool isLoading: false
    property bool hovered: _mouseArea.containsMouse
    property bool pressed: _mouseArea.pressed
    property alias font: _label.font
    property string text: ""
    property alias icon: _image.source
    property var contentWidth: _contentLayout.implicitWidth + FishUI.Units.largeSpacing * 2
    property var backgroundColor: FishUI.Theme.secondBackgroundColor
    property var hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.3) : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.05)
    property var pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.1) : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.1)
    property var highlightColor: FishUI.Theme.highlightColor
    property var highlightHoveredColor: Qt.lighter(control.highlightColor, 1.1)
    property var highlightPressedColor: Qt.darker(control.highlightColor, 1.1)
    property alias background: hoveredRect

    signal clicked()
    signal closeClicked()

    MouseArea {
        id: _mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }

    Rectangle {
        id: hoveredRect

        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        color: control.hovered ? control.pressed ? pressedColor : hoveredColor : backgroundColor
        opacity: 0.5
        border.width: 0
        radius: FishUI.Theme.smallRadius
    }

    Rectangle {
        id: checkedRect

        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        anchors.fill: parent
        color: control.hovered ? control.pressed ? highlightPressedColor : highlightHoveredColor : highlightColor
        opacity: _mouseArea.pressed ? 0.9 : 1
        border.width: 0
        visible: checked
        radius: FishUI.Theme.smallRadius
    }

    RowLayout {
        id: _contentLayout

        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing
        anchors.rightMargin: FishUI.Units.smallSpacing
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        spacing: FishUI.Units.smallSpacing

        FishUI.BusyIndicator {
            width: 24
            height: 22
            visible: isLoading
        }

        Image {
            id: _image

            visible: icon != ''
            objectName: "image"
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(16, 16)
            Layout.preferredHeight: 16
            Layout.preferredWidth: 24
            smooth: false
            antialiasing: true
        }

        Label {
            id: _label

            text: control.text
            leftPadding: 0
            rightPadding: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: control.checked ? FishUI.Theme.highlightedTextColor : FishUI.Theme.textColor
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }

        FishUI.TabCloseButton {
            id: _closeButton

            enabled: control.checked
            Layout.preferredHeight: 24
            Layout.preferredWidth: 24
            size: 24
            source: !enabled ? "" : "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "close.svg"
            onClicked: control.closeClicked()
        }

    }

}
