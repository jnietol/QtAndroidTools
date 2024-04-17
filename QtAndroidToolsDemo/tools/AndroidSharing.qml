import QtCore
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtAndroidTools

Page {
    id: page
    padding: 20

    Component.onCompleted: {
        if(QtAndroidTools.activityAction === QtAndroidTools.ACTION_SEND)
        {
            if(QtAndroidTools.activityMimeType === "text/plain")
            {
                receivedSharedText.text = QtAndroidSharing.getReceivedSharedText();
                receivedSharedText.open();
            }
            else if(QtAndroidTools.activityMimeType.startsWith("image") === true)
            {
                QtAndroidTools.insertImage("SharedImage", QtAndroidSharing.getReceivedSharedBinaryData());
                sharedImage.source = "image://QtAndroidTools/SharedImage";
                receivedSharedImage.open();
            }
        }
        else if(QtAndroidTools.activityAction === QtAndroidTools.ACTION_PICK)
        {
            imageToShareDialog.open();
        }
    }

    Connections {
        target: QtAndroidSharing
        function onRequestedSharedFileReadyToSave(mimeType, name, size)
        {
            requestedSharedFile.text = ("Name: " + name + "\nSize: " + size + "\nMimeType: " + mimeType);
            requestedSharedFile.fileName = name;
            requestedSharedFile.open();
        }
        function onRequestedSharedFileNotAvailable()
        {
        }
    }

    Column {
        anchors.fill: parent
        spacing: 20

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Share text"
            onClicked: QtAndroidSharing.shareText("This is my shared text!")
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Share binary data"
            onClicked: QtAndroidSharing.shareBinaryData("image/jpeg", "sharedfiles/logo_falsinsoft.jpg")
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Request shared file"
            onClicked: QtAndroidSharing.requestSharedFile("image/*")
        }
    }

    MessageDialog {
        id: receivedSharedText
        title: "Received shared text"
        onAccepted: Qt.quit()
    }

    Dialog {
        id: receivedSharedImage
        title: "Received shared image"
        modal: true
        standardButtons: Dialog.Ok
        contentWidth: sharedImage.width
        contentHeight: sharedImage.height
        anchors.centerIn: parent

        property bool quitOnClose: true

        Image {
            id: sharedImage
            width: page.width * 0.5
            height: width
        }

        onAccepted: if(quitOnClose) Qt.quit()
    }

    MessageDialog {
        id: requestedSharedFile
        title: "It's ok to get this file?"
        buttons: MessageDialog.Yes | MessageDialog.No
        onButtonClicked: function (button, role) {
            if(button === MessageDialog.Yes)
            {
                if(QtAndroidSharing.saveRequestedSharedFile("sharedfiles/" + fileName))
                {
                    sharedImage.source = (StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/sharedfiles/" + fileName);
                    receivedSharedImage.quitOnClose = false;
                    receivedSharedImage.open();
                }
                else
                {
                    errorMessage.text = "Unable to save received file";
                    errorMessage.open();
                }
            }
            else
            {
                QtAndroidSharing.closeRequestedSharedFile();
            }
        }
        property string fileName
    }

    Dialog {
        id: imageToShareDialog
        title: "Sorry, I have only this image to share,\ndo you want it?"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        contentWidth: imageToShare.width
        contentHeight: imageToShare.height
        anchors.centerIn: parent

        Image {
            id: imageToShare
            width: page.width * 0.5
            height: width
            source: StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/sharedfiles/logo_falsinsoft.jpg"
        }

        onRejected: {
            QtAndroidSharing.shareFile(false);
            Qt.quit();
        }
        onAccepted: {
            QtAndroidSharing.shareFile(true, "image/jpeg", "sharedfiles/logo_falsinsoft.jpg");
            Qt.quit();
        }
    }

    MessageDialog {
        id: errorMessage
        title: "Error"
        buttons: MessageDialog.Ok
    }
}
