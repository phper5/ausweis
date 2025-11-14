/**
 * Copyright (c) 2015-2025 Governikus GmbH & Co. KG, Germany
 */

#include "NfcCard.h"

#include <QLoggingCategory>
#include <QThread>
#include <QSysInfo>


using namespace governikus;


Q_DECLARE_LOGGING_CATEGORY(card_nfc)


// Device-specific NFC configuration for improved stability
struct NfcDeviceConfig {
	int maxRetries = 3;
	int baseTimeoutMs = 5000;
	int retryDelayMs = 100;
	int timeoutRetryDelayMs = 200;
	bool logRetryAttempts = true;
};

static NfcDeviceConfig getDeviceSpecificConfig()
{
	NfcDeviceConfig config;
	
#ifdef Q_OS_ANDROID
	// Get device manufacturer and model information
	const QString manufacturer = QSysInfo::productType();
	const QString model = QSysInfo::prettyProductName();
	
	qCDebug(card_nfc) << "Detecting NFC configuration for device:" << manufacturer << model;
	
	// Special handling for known problematic devices
	if (manufacturer.contains(QStringLiteral("android"), Qt::CaseInsensitive))
	{
		// Try to get more specific device info from QSysInfo
		const QString machineHostName = QSysInfo::machineHostName();
		const QString productName = QSysInfo::productName();
		
		// Check for Xiaomi devices (various brand names)
		if (machineHostName.contains(QStringLiteral("xiaomi"), Qt::CaseInsensitive) ||
		    productName.contains(QStringLiteral("xiaomi"), Qt::CaseInsensitive) ||
		    machineHostName.contains(QStringLiteral("redmi"), Qt::CaseInsensitive) ||
		    productName.contains(QStringLiteral("redmi"), Qt::CaseInsensitive) ||
		    machineHostName.contains(QStringLiteral("mi "), Qt::CaseInsensitive) ||
		    model.contains(QStringLiteral("k70"), Qt::CaseInsensitive))
		{
			qCInfo(card_nfc) << "Detected Xiaomi/Redmi device, using enhanced NFC stability settings";
			config.maxRetries = 4;  // More retries for stability
			config.baseTimeoutMs = 6000;  // Longer base timeout
			config.retryDelayMs = 150;  // Longer delays between retries
			config.timeoutRetryDelayMs = 300;
		}
		// Check for other potentially problematic manufacturers
		else if (machineHostName.contains(QStringLiteral("oppo"), Qt::CaseInsensitive) ||
		         machineHostName.contains(QStringLiteral("vivo"), Qt::CaseInsensitive) ||
		         machineHostName.contains(QStringLiteral("realme"), Qt::CaseInsensitive))
		{
			qCInfo(card_nfc) << "Detected device with potential NFC quirks, using moderate enhanced settings";
			config.maxRetries = 3;
			config.baseTimeoutMs = 5500;
			config.retryDelayMs = 120;
			config.timeoutRetryDelayMs = 250;
		}
	}
#endif
	
	qCDebug(card_nfc) << "NFC Config - maxRetries:" << config.maxRetries 
			  << "baseTimeout:" << config.baseTimeoutMs << "ms"
			  << "retryDelay:" << config.retryDelayMs << "ms"
			  << "timeoutRetryDelay:" << config.timeoutRetryDelayMs << "ms";
	
	return config;
}


NfcCard::NfcCard(QNearFieldTarget* pNearFieldTarget)
	: Card()
	, mConnected(false)
	, mIsValid(true)
	, mNearFieldTarget(pNearFieldTarget)
{
	qCDebug(card_nfc) << "Card created";

	pNearFieldTarget->setParent(nullptr);
	connect(pNearFieldTarget, &QNearFieldTarget::error, this, &NfcCard::fireTargetError);
}


bool NfcCard::isValid() const
{
	return mIsValid;
}


bool NfcCard::invalidateTarget(const QNearFieldTarget* pNearFieldTarget)
{
	if (pNearFieldTarget == mNearFieldTarget.data())
	{
		mIsValid = false;
		return true;
	}

	return false;
}


CardReturnCode NfcCard::establishConnection()
{
	if (isConnected())
	{
		qCCritical(card_nfc) << "Card is already connected";
		return CardReturnCode::COMMAND_FAILED;
	}

	mConnected = true;
	return CardReturnCode::OK;
}


CardReturnCode NfcCard::releaseConnection()
{
	if (!mIsValid || mNearFieldTarget == nullptr)
	{
		qCWarning(card_nfc) << "NearFieldTarget is no longer valid";
		return CardReturnCode::COMMAND_FAILED;
	}

	if (!isConnected())
	{
		qCCritical(card_nfc) << "Card is already disconnected";
		return CardReturnCode::COMMAND_FAILED;
	}

	mConnected = false;
	mNearFieldTarget->disconnect();
	return CardReturnCode::OK;
}


bool NfcCard::isConnected() const
{
	return mConnected;
}


void NfcCard::setProgressMessage(const QString& pMessage, int pProgress)
{
	QString message = generateProgressMessage(pMessage, pProgress);
	Q_EMIT fireSetProgressMessage(message);
}


void NfcCard::setErrorMessage(const QString& pMessage)
{
	QString message = generateErrorMessage(pMessage);
	Q_EMIT fireSetProgressMessage(message);
}


ResponseApduResult NfcCard::transmit(const CommandApdu& pCmd)
{
	if (!mIsValid || mNearFieldTarget == nullptr)
	{
		qCWarning(card_nfc) << "NearFieldTarget is no longer valid";
		return {CardReturnCode::COMMAND_FAILED};
	}

	qCDebug(card_nfc) << "Transmit command APDU:" << pCmd;

	if (!mNearFieldTarget->accessMethods().testFlag(QNearFieldTarget::AccessMethod::TagTypeSpecificAccess))
	{
		qCWarning(card_nfc) << "No TagTypeSpecificAccess supported";
		return {CardReturnCode::COMMAND_FAILED};
	}

	// Get device-specific configuration for enhanced stability
	static const NfcDeviceConfig config = getDeviceSpecificConfig();
	
	for (int retry = 0; retry < config.maxRetries; ++retry)
	{
		// Check if target is still valid before each attempt
		if (!mIsValid || mNearFieldTarget == nullptr)
		{
			qCWarning(card_nfc) << "NearFieldTarget became invalid during retry" << (retry + 1);
			return {CardReturnCode::COMMAND_FAILED};
		}

		QNearFieldTarget::RequestId id = mNearFieldTarget->sendCommand(pCmd);
		if (!id.isValid())
		{
			qCWarning(card_nfc) << "Cannot write messages, retry" << (retry + 1) << "of" << config.maxRetries;
			if (retry < config.maxRetries - 1)
			{
				// Short delay before retry to allow NFC subsystem to recover
				QThread::msleep(config.retryDelayMs);
				continue;
			}
			return {CardReturnCode::COMMAND_FAILED};
		}

		// Use progressive timeout: longer timeout for subsequent retries
		int timeoutMs = config.baseTimeoutMs + (retry * 1000);
		if (!mNearFieldTarget->waitForRequestCompleted(id, timeoutMs))
		{
			qCWarning(card_nfc) << "Transmit timeout reached after" << timeoutMs << "ms, retry" 
					 << (retry + 1) << "of" << config.maxRetries;
			if (retry < config.maxRetries - 1)
			{
				// Longer delay before timeout retry to allow device to stabilize
				QThread::msleep(config.timeoutRetryDelayMs + (retry * 100));
				continue;
			}
			// Final timeout - this might indicate card removal or severe communication issues
			qCWarning(card_nfc) << "Final timeout after" << config.maxRetries << "retries - possible card removal";
			return {CardReturnCode::COMMAND_FAILED};
		}

		QVariant response = mNearFieldTarget->requestResponse(id);
		if (!response.isValid())
		{
			qCWarning(card_nfc) << "Invalid response received, retry" << (retry + 1) << "of" << config.maxRetries;
			if (retry < config.maxRetries - 1)
			{
				QThread::msleep(config.retryDelayMs + 50);
				continue;
			}
			return {CardReturnCode::COMMAND_FAILED};
		}

		// Success - log retry count for debugging if configured
		if (retry > 0 && config.logRetryAttempts)
		{
			qCInfo(card_nfc) << "Transmit succeeded after" << (retry + 1) << "attempts";
		}

		const QByteArray recvBuffer = response.toByteArray();
		const ResponseApdu responseApdu(recvBuffer);
		qCDebug(card_nfc) << "Transmit response APDU:" << responseApdu;
		return {CardReturnCode::OK, responseApdu};
	}

	// This should never be reached, but added for completeness
	qCCritical(card_nfc) << "Transmit failed after all retries - unexpected code path";
	return {CardReturnCode::COMMAND_FAILED};
}
