import QtQuick
import QtQuick.Controls.Material
import QtAndroidTools

Page {
    id: page
    padding: 0

    QtAndroidAuthentication {
        id: authentication
        authenticators: QtAndroidAuthentication.BIOMETRIC_STRONG;
        title: "Authentication test";
        description: "Try authenticate";
        negativeButton: "Cancel";
        onError: (errString)=>
        {
            authenticationResult.text = "Error: " + errString;
        }
        onSucceeded:
        {
            authenticationResult.text = "Succeeded";
            authenticationCancelled.visible = false;
        }
        onSucceededAndEncrypted: (encryptedText, initializationVect)=>
        {
            password.text = encryptedText;
            initializationVector.text = initializationVect;
            authenticationResult.text = "Succeeded";
            authenticationCancelled.visible = false;
        }
        onSucceededAndDecrypted: (decryptedText)=>
        {
            password.text = decryptedText;
            initializationVector.text = "";
            authenticationResult.text = "Succeeded";
            authenticationCancelled.visible = false;
        }
        onFailed:
        {
            authenticationResult.text = "Failed";
            authenticationCancelled.visible = false;
        }
        onCancelled:
        {
            authenticationCancelled.visible = true;
        }
    }

    Column {
        width: parent.width
        height: parent.height * 0.8
        anchors.centerIn: parent
        spacing: 20

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "canAuthenticate"
            onClicked: {
                switch(authentication.canAuthenticate())
                {
                    case QtAndroidAuthentication.BIOMETRIC_STATUS_UNKNOWN:
                        authenticateStatus.text = "BIOMETRIC_STATUS_UNKNOWN";
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_SUCCESS:
                        authenticateStatus.text = "BIOMETRIC_SUCCESS";
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_ERROR_NO_HARDWARE:
                        authenticateStatus.text = "BIOMETRIC_ERROR_NO_HARDWARE";
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_ERROR_HW_UNAVAILABLE:
                        authenticateStatus.text = "BIOMETRIC_ERROR_HW_UNAVAILABLE";
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_ERROR_NONE_ENROLLED:
                        authenticateStatus.text = "BIOMETRIC_ERROR_NONE_ENROLLED";
                        biometricEnrollButton.visible = true;
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED:
                        authenticateStatus.text = "BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED";
                        break;
                    case QtAndroidAuthentication.BIOMETRIC_ERROR_UNSUPPORTED:
                        authenticateStatus.text = "BIOMETRIC_ERROR_UNSUPPORTED";
                        break;
                }
            }
        }
        Label {
            id: authenticateStatus
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
        }
        Button {
            id: biometricEnrollButton
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            text: "requestBiometricEnroll"
            onClicked: authentication.requestBiometricEnroll()
        }
        Button {
            id: biometricAuthenticateButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authenticate"
            onClicked: authentication.authenticate()
        }
        Label {
            id: authenticationResult
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
        }
        Label {
            id: authenticationCancelled
            visible: false
            text: "Cancelled!!"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
        }
        TextInput {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            text: "test"
        }
        TextInput {
            id: initializationVector
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
        }
        Button {
            id: biometricAuthenticateAndEncryptButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authenticateAndEncrypt"
            onClicked: authentication.authenticateAndEncrypt(password.text)
        }
        Button {
            id: biometricAuthenticateAndDecryptButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: "authenticateAndDecrypt"
            onClicked: authentication.authenticateAndDecrypt(password.text, initializationVector.text)
        }
    }
}
