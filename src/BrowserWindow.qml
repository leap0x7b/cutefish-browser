/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     Reion Wong <reionwong@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import FishUI 1.0 as FishUI
import Qt.labs.settings 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtWebEngine 1.10

FishUI.Window {
    id: browserWindow

    property QtObject applicationRoot
    property Item currentWebView: tabs.currentIndex < tabs.count ? tabs.contentModel.get(tabs.currentIndex) : null
    property int previousVisibility: Window.Windowed

    function onDownloadRequested(download) {
        downloadView.visible = true;
        downloadView.append(download);
        download.accept();
    }

    width: 1300
    height: 900
    visible: true
    title: qsTr("Browser")

    header.height: 40

    onCurrentWebViewChanged: {
        findBar.reset();
    }

    Settings {
        id: appSettings

        property alias autoLoadImages: loadImages.checked
        property alias javaScriptEnabled: javaScriptEnabled.checked
        property alias errorPageEnabled: errorPageEnabled.checked
        property alias pluginsEnabled: pluginsEnabled.checked
        property alias fullScreenSupportEnabled: fullScreenSupportEnabled.checked
        property alias autoLoadIconsForPage: autoLoadIconsForPage.checked
        property alias touchIconsEnabled: touchIconsEnabled.checked
        property alias webRTCPublicInterfacesOnly: webRTCPublicInterfacesOnly.checked
        property alias devToolsEnabled: devToolsEnabled.checked
        property alias pdfViewerEnabled: pdfViewerEnabled.checked
    }

    Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloadView.visible = !downloadView.visible;
        }
    }

    Action {
        id: focus

        shortcut: "Ctrl+L"
        onTriggered: {
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }

    Action {
        shortcut: StandardKey.Refresh
        onTriggered: {
            if (currentWebView)
                currentWebView.reload();

        }
    }

    Action {
        shortcut: StandardKey.AddTab
        onTriggered: {
            tabs.createEmptyTab(tabs.count != 0 ? currentWebView.profile : defaultProfile);
            tabs.currentIndex = tabs.count - 1;
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }

    Action {
        shortcut: StandardKey.Close
        onTriggered: {
            currentWebView.triggerWebAction(WebEngineView.RequestClose);
        }
    }

    Action {
        shortcut: StandardKey.Quit
        onTriggered: browserWindow.close()
    }

    Action {
        shortcut: "Escape"
        onTriggered: {
            if (currentWebView.state == "FullScreen") {
                browserWindow.visibility = browserWindow.previousVisibility;
                fullScreenNotification.hide();
                currentWebView.triggerWebAction(WebEngineView.ExitFullScreen);
            }
            if (findBar.visible)
                findBar.visible = false;

        }
    }

    Action {
        shortcut: "Ctrl+0"
        onTriggered: currentWebView.zoomFactor = 1
    }

    Action {
        shortcut: StandardKey.ZoomOut
        onTriggered: currentWebView.zoomFactor -= 0.1
    }

    Action {
        shortcut: StandardKey.ZoomIn
        onTriggered: currentWebView.zoomFactor += 0.1
    }

    Action {
        shortcut: StandardKey.Copy
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Copy)
    }

    Action {
        shortcut: StandardKey.Cut
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Cut)
    }

    Action {
        shortcut: StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Paste)
    }

    Action {
        shortcut: "Shift+" + StandardKey.Paste
        onTriggered: currentWebView.triggerWebAction(WebEngineView.PasteAndMatchStyle)
    }

    Action {
        shortcut: StandardKey.SelectAll
        onTriggered: currentWebView.triggerWebAction(WebEngineView.SelectAll)
    }

    Action {
        shortcut: StandardKey.Undo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Undo)
    }

    Action {
        shortcut: StandardKey.Redo
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Redo)
    }

    Action {
        shortcut: StandardKey.Back
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Back)
    }

    Action {
        shortcut: StandardKey.Forward
        onTriggered: currentWebView.triggerWebAction(WebEngineView.Forward)
    }

    Action {
        shortcut: StandardKey.Find
        onTriggered: {
            if (!findBar.visible)
                findBar.visible = true;

        }
    }

    Action {
        shortcut: StandardKey.FindNext
        onTriggered: findBar.findNext()
    }

    Action {
        shortcut: StandardKey.FindPrevious
        onTriggered: findBar.findPrevious()
    }

    headerItem: Item {
        FishUI.TabBar {
            id: tabbar

            anchors.fill: parent
            anchors.margins: FishUI.Units.smallSpacing / 2
            anchors.rightMargin: FishUI.Units.largeSpacing * 4
            currentIndex: tabs.currentIndex
            model: tabs.count
            onNewTabClicked: tabs.createEmptyTab(defaultProfile)

            delegate: BrowserTab {
                id: tabBtn

                text: tabs.contentModel.get(index).title
                icon: tabs.contentModel.get(index).icon ? tabs.contentModel.get(index).icon : ''
                isLoading: currentWebView.loading
                implicitHeight: tabbar.height
                width: 216
                checked: tabs.currentIndex === index

                ToolTip.delay: 500
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: tabs.contentModel.get(index).title

                onClicked: {
                    tabs.currentIndex = index;
                    tabs.currentItem.forceActiveFocus();
                }
                onCloseClicked: {
                    tabs.removeView(index);
                }
            }

        }

    }

    //Item {
        RowLayout {
            id: navigationBar

            //anchors.fill: parent
            Layout.fillWidth: true
            anchors.margins: FishUI.Units.smallSpacing / 2

            FishUI.DesktopMenu {
                id: historyMenu

                Instantiator {
                    model: currentWebView && currentWebView.navigationHistory.items
                    onObjectAdded: function(index, object) {
                        historyMenu.insertItem(index, object);
                    }
                    onObjectRemoved: function(index, object) {
                        historyMenu.removeItem(object);
                    }

                    MenuItem {
                        text: model.title
                        onTriggered: currentWebView.goBackOrForward(model.offset)
                        checkable: !enabled
                        checked: !enabled
                        enabled: model.offset
                    }

                }
            }

            IconButton {
                id: backButton

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                source: "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "previous.svg"
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        historyMenu.open()
                    } else {
                        currentWebView.goBack()
                    }
                }
                enabled: currentWebView && currentWebView.canGoBack
            }

            IconButton {
                id: forwardButton

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                source: "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "next.svg"
                onClicked: currentWebView.goForward()
                enabled: currentWebView && currentWebView.canGoForward
            }

            IconButton {
                id: reloadButton

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                source: currentWebView && currentWebView.loading ? "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "close.svg" : "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "refresh.svg"
                onClicked: currentWebView && currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
            }

            TextField {
                id: addressBar

                selectByMouse: true
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                text: currentWebView && currentWebView.url
                onAccepted: currentWebView.url = utils.fromUserInput(text)
            }

                FishUI.DesktopMenu {
                    id: settingsMenu

                    MenuItem {
                        id: loadImages

                        text: "Autoload images"
                        checkable: true
                        checked: WebEngine.settings.autoLoadImages
                    }

                    MenuItem {
                        id: javaScriptEnabled

                        text: "JavaScript On"
                        checkable: true
                        checked: WebEngine.settings.javascriptEnabled
                    }

                    MenuItem {
                        id: errorPageEnabled

                        text: "ErrorPage On"
                        checkable: true
                        checked: WebEngine.settings.errorPageEnabled
                    }

                    MenuItem {
                        id: pluginsEnabled

                        text: "Plugins On"
                        checkable: true
                        checked: true
                    }

                    MenuItem {
                        id: fullScreenSupportEnabled

                        text: "FullScreen On"
                        checkable: true
                        checked: WebEngine.settings.fullScreenSupportEnabled
                    }

                    MenuItem {
                        id: offTheRecordEnabled

                        text: "Off The Record"
                        checkable: true
                        checked: currentWebView && currentWebView.profile === otrProfile
                        onToggled: function(checked) {
                            if (currentWebView)
                                currentWebView.profile = checked ? otrProfile : defaultProfile;

                        }
                    }

                    MenuItem {
                        id: httpDiskCacheEnabled

                        text: "HTTP Disk Cache"
                        checkable: currentWebView && !currentWebView.profile.offTheRecord
                        checked: currentWebView && (currentWebView.profile.httpCacheType === WebEngineProfile.DiskHttpCache)
                        onToggled: function(checked) {
                            if (currentWebView)
                                currentWebView.profile.httpCacheType = checked ? WebEngineProfile.DiskHttpCache : WebEngineProfile.MemoryHttpCache;

                        }
                    }

                    MenuItem {
                        id: autoLoadIconsForPage

                        text: "Icons On"
                        checkable: true
                        checked: WebEngine.settings.autoLoadIconsForPage
                    }

                    MenuItem {
                        id: touchIconsEnabled

                        text: "Touch Icons On"
                        checkable: true
                        checked: WebEngine.settings.touchIconsEnabled
                        enabled: autoLoadIconsForPage.checked
                    }

                    MenuItem {
                        id: webRTCPublicInterfacesOnly

                        text: "WebRTC Public Interfaces Only"
                        checkable: true
                        checked: WebEngine.settings.webRTCPublicInterfacesOnly
                    }

                    MenuItem {
                        id: devToolsEnabled

                        text: "Open DevTools"
                        checkable: true
                        checked: false
                    }

                    MenuItem {
                        id: pdfViewerEnabled

                        text: "PDF viewer enabled"
                        checkable: true
                        checked: WebEngine.settings.pdfViewerEnabled
                    }

                }

            IconButton {
                id: settingsMenuButton

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                source: "qrc:/images/" + (FishUI.Theme.darkMode || control.checked ? "dark/" : "light/") + "control.svg"
                onClicked: settingsMenu.open()
            }

        }

    //}

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        FishUI.TabView {
            id: tabs
            Layout.fillWidth: true
            Layout.fillHeight: true

            function createEmptyTab(profile) {
                var tab = addTab(tabComponent, {
                });
                // We must do this first to make sure that tab.active gets set so that tab.item gets instantiated immediately.
                tab.active = true;
                tab.title = Qt.binding(function() {
                    return tab.item.title ? tab.item.title : 'New Tab';
                });
                tab.item.profile = profile;
                return tab;
            }

            function indexOfView(view) {
                for (let i = 0; i < tabs.count; ++i) if (tabs.contentModel.get(i) == view) {
                    return i;
                }
                return -1;
            }

            function removeView(index) {
                if (tabs.count > 1)
                    tabs.closeTab(index);
                else
                    browserWindow.close();
            }

            anchors.top: parent.top
            anchors.bottom: devToolsView.top
            anchors.left: parent.left
            anchors.right: parent.right
            Component.onCompleted: createEmptyTab(defaultProfile)

            Component {
                id: tabComponent

                WebEngineView {
                    id: webEngineView

                    focus: true
                    onLinkHovered: function(hoveredUrl) {
                        if (hoveredUrl == "") {
                            hideStatusText.start();
                        } else {
                            statusText.text = hoveredUrl;
                            statusBubble.visible = true;
                            hideStatusText.stop();
                        }
                    }
                    settings.autoLoadImages: appSettings.autoLoadImages
                    settings.javascriptEnabled: appSettings.javaScriptEnabled
                    settings.errorPageEnabled: appSettings.errorPageEnabled
                    settings.pluginsEnabled: appSettings.pluginsEnabled
                    settings.fullScreenSupportEnabled: appSettings.fullScreenSupportEnabled
                    settings.autoLoadIconsForPage: appSettings.autoLoadIconsForPage
                    settings.touchIconsEnabled: appSettings.touchIconsEnabled
                    settings.webRTCPublicInterfacesOnly: appSettings.webRTCPublicInterfacesOnly
                    settings.pdfViewerEnabled: appSettings.pdfViewerEnabled
                    onCertificateError: function(error) {
                        error.defer();
                        sslDialog.enqueue(error);
                    }
                    onNewViewRequested: function(request) {
                        if (!request.userInitiated) {
                            print("Warning: Blocked a popup window.");
                        } else if (request.destination === WebEngineView.NewViewInTab) {
                            var tab = tabs.createEmptyTab(currentWebView.profile);
                            tabs.currentIndex = tabs.count - 1;
                            request.openIn(tab.item);
                        } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                            var backgroundTab = tabs.createEmptyTab(currentWebView.profile);
                            request.openIn(backgroundTab.item);
                        } else if (request.destination === WebEngineView.NewViewInDialog) {
                            var dialog = applicationRoot.createDialog(currentWebView.profile);
                            request.openIn(dialog.currentWebView);
                        } else {
                            var window = applicationRoot.createWindow(currentWebView.profile);
                            request.openIn(window.currentWebView);
                        }
                    }
                    onFullScreenRequested: function(request) {
                        if (request.toggleOn) {
                            webEngineView.state = "FullScreen";
                            browserWindow.previousVisibility = browserWindow.visibility;
                            browserWindow.showFullScreen();
                            fullScreenNotification.show();
                        } else {
                            webEngineView.state = "";
                            browserWindow.visibility = browserWindow.previousVisibility;
                            fullScreenNotification.hide();
                        }
                        request.accept();
                    }
                    onQuotaRequested: function(request) {
                        if (request.requestedSize <= 5 * 1024 * 1024)
                            request.accept();
                        else
                            request.reject();
                    }
                    onRegisterProtocolHandlerRequested: function(request) {
                        console.log("accepting registerProtocolHandler request for " + request.scheme + " from " + request.origin);
                        request.accept();
                    }
                    onRenderProcessTerminated: function(terminationStatus, exitCode) {
                        var status = "";
                        switch (terminationStatus) {
                        case WebEngineView.NormalTerminationStatus:
                            status = "(normal exit)";
                            break;
                        case WebEngineView.AbnormalTerminationStatus:
                            status = "(abnormal exit)";
                            break;
                        case WebEngineView.CrashedTerminationStatus:
                            status = "(crashed)";
                            break;
                        case WebEngineView.KilledTerminationStatus:
                            status = "(killed)";
                            break;
                        }
                        print("Render process exited with code " + exitCode + " " + status);
                        reloadTimer.running = true;
                    }
                    onWindowCloseRequested: tabs.removeView(tabs.indexOfView(webEngineView))
                    onSelectClientCertificate: function(selection) {
                        selection.certificates[0].select();
                    }
                    onFindTextFinished: function(result) {
                        if (!findBar.visible)
                            findBar.visible = true;

                        findBar.numberOfMatches = result.numberOfMatches;
                        findBar.activeMatch = result.activeMatch;
                    }
                    onLoadingChanged: function(loadRequest) {
                        if (loadRequest.status == WebEngineView.LoadStartedStatus)
                            findBar.reset();

                    }
                    states: [
                        State {
                            name: "FullScreen"

                            PropertyChanges {
                                target: tabs
                                frameVisible: false
                                tabsVisible: false
                            }

                            PropertyChanges {
                                target: navigationBar
                                visible: false
                            }

                        }
                    ]

                    Timer {
                        id: reloadTimer

                        interval: 0
                        running: false
                        repeat: false
                        onTriggered: currentWebView.reload()
                    }

                }

            }

        }

        WebEngineView {
            id: devToolsView

            visible: devToolsEnabled.checked
            height: visible ? 400 : 0
            inspectedView: visible && tabs.currentIndex < tabs.count ? tabs.contentModel.get(tabs.currentIndex) : null
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            onNewViewRequested: function(request) {
                var tab = tabs.createEmptyTab(currentWebView.profile);
                tabs.currentIndex = tabs.count - 1;
                request.openIn(tab.item);
            }
            onWindowCloseRequested: function(request) {
                // Delay hiding for keep the inspectedView set to receive the ACK message of close.
                hideTimer.running = true;
            }

            Timer {
                id: hideTimer

                interval: 0
                running: false
                repeat: false
                onTriggered: devToolsEnabled.checked = false
            }

        }

    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []

        function reject() {
            certErrors.shift().rejectCertificate();
            presentError();
        }

        function enqueue(error) {
            certErrors.push(error);
            presentError();
        }

        function presentError() {
            visible = certErrors.length > 0;
        }

        icon: StandardIcon.Warning
        standardButtons: StandardButton.No | StandardButton.Yes
        title: "Server's certificate not trusted"
        text: "Do you wish to continue?"
        detailedText: "If you wish so, you may continue with an unverified certificate. " + "Accepting an unverified certificate means " + "you may not be connected with the host you tried to connect to.\n" + "Do you wish to override the security check and continue?"
        onYes: {
            certErrors.shift().ignoreCertificateError();
            presentError();
        }
        onNo: reject()
        onRejected: reject()
    }

    FullScreenNotification {
        id: fullScreenNotification
    }

    DownloadView {
        id: downloadView

        visible: false
        anchors.fill: parent
    }

    FindBar {
        id: findBar

        visible: false
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        onFindNext: {
            if (text)
                currentWebView && currentWebView.findText(text);
            else if (!visible)
                visible = true;
        }
        onFindPrevious: {
            if (text)
                currentWebView && currentWebView.findText(text, WebEngineView.FindBackward);
            else if (!visible)
                visible = true;
        }
    }

    Rectangle {
        id: statusBubble

        property int padding: 8

        color: "oldlace"
        visible: false
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: statusText.paintedWidth + padding
        height: statusText.paintedHeight + padding

        Text {
            id: statusText

            anchors.centerIn: statusBubble
            elide: Qt.ElideMiddle

            Timer {
                id: hideStatusText

                interval: 750
                onTriggered: {
                    statusText.text = "";
                    statusBubble.visible = false;
                }
            }

        }

    }
}
