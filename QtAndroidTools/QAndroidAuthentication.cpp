/*
 *	MIT License
 *
 *	Copyright (c) 2018 Fabio Falsini <falsinsoft@gmail.com>
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *	SOFTWARE.
 */
#include <QCoreApplication>
#include "QAndroidAuthentication.h"

QAndroidAuthentication::QAndroidAuthentication(QQuickItem *parent) : QQuickItem(parent),
                                                                     m_javaAuthentication("com/falsinsoft/qtandroidtools/AndroidAuthentication",
                                                                                          reinterpret_cast<jlong>(this),
                                                                                          QNativeInterface::QAndroidApplication::context()),
                                                                     m_authenticators(0)
{
    if(m_javaAuthentication.isValid())
    {
        const JNINativeMethod jniMethod[] = {
            {"authenticationError", "(JLjava/lang/String;)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationError)},
            {"authenticationSucceeded", "(J)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationSucceeded)},
            {"authenticationAndEncryptionSucceeded", "(JLjava/lang/String;Ljava/lang/String;)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationAndEncryptionSucceeded)},
            {"authenticationAndDecryptionSucceeded", "(JLjava/lang/String;)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationAndDecryptionSucceeded)},
            {"authenticationFailed", "(J)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationFailed)},
            {"authenticationCancelled", "(J)V", reinterpret_cast<void*>(&QAndroidAuthentication::authenticationCancelled)}
        };
        QJniEnvironment jniEnv;
        jclass objectClass;

        objectClass = jniEnv->GetObjectClass(m_javaAuthentication.object<jobject>());
        jniEnv->RegisterNatives(objectClass, jniMethod, sizeof(jniMethod)/sizeof(JNINativeMethod));
        jniEnv->DeleteLocalRef(objectClass);
    }
}

int QAndroidAuthentication::getAuthenticators() const
{
    return m_authenticators;
}

void QAndroidAuthentication::setAuthenticators(int authenticators)
{
    if(m_javaAuthentication.isValid())
    {
        m_javaAuthentication.callMethod<void>("setAuthenticators",
                                              "(I)V",
                                              authenticators
                                              );
        m_authenticators = authenticators;
    }
}

QString QAndroidAuthentication::getTitle() const
{
    return m_title;
}

void QAndroidAuthentication::setTitle(const QString &title)
{
    if(m_javaAuthentication.isValid())
    {
        m_javaAuthentication.callMethod<void>("setTitle",
                                              "(Ljava/lang/String;)V",
                                              QJniObject::fromString(title).object<jstring>()
                                              );
        m_title = title;
    }
}

QString QAndroidAuthentication::getDescription() const
{
    return m_description;
}

void QAndroidAuthentication::setDescription(const QString &description)
{
    if(m_javaAuthentication.isValid())
    {
        m_javaAuthentication.callMethod<void>("setDescription",
                                              "(Ljava/lang/String;)V",
                                              QJniObject::fromString(description).object<jstring>()
                                              );
        m_description = description;
    }
}

QString QAndroidAuthentication::getNegativeButton() const
{
    return m_negativeButton;
}

void QAndroidAuthentication::setNegativeButton(const QString &negativeButton)
{
    if(m_javaAuthentication.isValid())
    {
        m_javaAuthentication.callMethod<void>("setNegativeButton",
                                              "(Ljava/lang/String;)V",
                                              QJniObject::fromString(negativeButton).object<jstring>()
                                              );
        m_negativeButton = negativeButton;
    }
}

int QAndroidAuthentication::canAuthenticate()
{
    if(m_javaAuthentication.isValid())
    {
        return m_javaAuthentication.callMethod<jint>("canAuthenticate");
    }

    return BIOMETRIC_STATUS_UNKNOWN;
}

bool QAndroidAuthentication::requestBiometricEnroll()
{
    if(m_javaAuthentication.isValid())
    {
        return m_javaAuthentication.callMethod<jboolean>("requestBiometricEnroll");
    }

    return false;
}

bool QAndroidAuthentication::authenticate()
{
    if(m_javaAuthentication.isValid())
    {
        return m_javaAuthentication.callMethod<jboolean>("authenticate");
    }

    return false;
}

bool QAndroidAuthentication::authenticateAndEncrypt(const QString &plainText)
{
    if(m_javaAuthentication.isValid())
    {
        return m_javaAuthentication.callMethod<jboolean>("authenticateAndEncrypt",
                                                         "(Ljava/lang/String;)Z",
                                                         QJniObject::fromString(plainText).object<jstring>()
                                                         );
    }

    return false;
}

bool QAndroidAuthentication::authenticateAndDecrypt(const QString &encryptedText, const QString &initializationVector)
{
    if(m_javaAuthentication.isValid())
    {
        return m_javaAuthentication.callMethod<jboolean>("authenticateAndDecrypt",
                                                         "(Ljava/lang/String;Ljava/lang/String;)Z",
                                                         QJniObject::fromString(encryptedText).object<jstring>(),
                                                         QJniObject::fromString(initializationVector).object<jstring>()
                                                         );
    }

    return false;
}

void QAndroidAuthentication::cancel()
{
    if(m_javaAuthentication.isValid())
    {
        m_javaAuthentication.callMethod<void>("cancel");
    }
}

void QAndroidAuthentication::authenticationError(JNIEnv *env, jobject thiz, jlong instancePtr, jstring error)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->error(QJniObject(error).toString());
}

void QAndroidAuthentication::authenticationSucceeded(JNIEnv *env, jobject thiz, jlong instancePtr)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->succeeded();
}

void QAndroidAuthentication::authenticationAndEncryptionSucceeded(JNIEnv *env, jobject thiz, jlong instancePtr, jstring encryptedText, jstring initializationVector)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->succeededAndEncrypted(QJniObject(encryptedText).toString(), QJniObject(initializationVector).toString());
}

void QAndroidAuthentication::authenticationAndDecryptionSucceeded(JNIEnv *env, jobject thiz, jlong instancePtr, jstring decryptedText)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->succeededAndDecrypted(QJniObject(decryptedText).toString());
}

void QAndroidAuthentication::authenticationFailed(JNIEnv *env, jobject thiz, jlong instancePtr)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->failed();
}

void QAndroidAuthentication::authenticationCancelled(JNIEnv *env, jobject thiz, jlong instancePtr)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    Q_EMIT reinterpret_cast<QAndroidAuthentication*>(instancePtr)->cancelled();
}
