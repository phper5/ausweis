/**
 * Copyright (c) 2021-2025 Governikus GmbH & Co. KG, Germany
 */

#include "PinResetInformationModel.h"

#include "Env.h"
#include "ProviderConfiguration.h"
#include "TestFileHelper.h"

#include <QtTest>


using namespace Qt::Literals::StringLiterals;
using namespace governikus;


Q_DECLARE_METATYPE(QMetaMethod)


class test_PinResetInformationModel
	: public QObject
{
	Q_OBJECT

	QTemporaryDir mTranslationDir;

	private Q_SLOTS:
		void initTestCase()
		{
			TestFileHelper::createTranslations(mTranslationDir.path());
			LanguageLoader::getInstance().setPath(mTranslationDir.path());
		}


		void cleanup()
		{
			if (LanguageLoader::getInstance().isLoaded())
			{
				LanguageLoader::getInstance().unload();
			}
		}


		void test_fireUpdateOnTranslationChanged()
		{
			auto pinResetInformationModel = Env::getSingleton<PinResetInformationModel>();
			QSignalSpy spy(pinResetInformationModel, &PinResetInformationModel::fireUpdated);

			pinResetInformationModel->onTranslationChanged();

			QCOMPARE(spy.count(), 1);
		}


		void test_fireUpdateOnProviderConfigurationUpdated()
		{
			QSignalSpy spy(Env::getSingleton<PinResetInformationModel>(), &PinResetInformationModel::fireUpdated);

			Q_EMIT Env::getSingleton<ProviderConfiguration>()->fireUpdated();

			QCOMPARE(spy.count(), 1);
		}


		void test_PinResetUrl()
		{
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getPinResetUrl(), QUrl(QStringLiteral("https://servicesuche.bund.de/#/en")));

			auto* config = Env::getSingleton<ProviderConfiguration>();
			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getPinResetUrl(), QUrl(QStringLiteral("https://www.pin-ruecksetzbrief-bestellen.de/en")));

			LanguageLoader::getInstance().load(QLocale::German);
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getPinResetUrl(), QUrl(QStringLiteral("https://www.pin-ruecksetzbrief-bestellen.de")));

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getPinResetUrl(), QUrl(QStringLiteral("https://servicesuche.bund.de")));
		}


		void test_PinResetActivationUrl()
		{
			QVERIFY(!Env::getSingleton<PinResetInformationModel>()->getPinResetActivationUrl().isEmpty());
		}


		void test_AdministrativeSearchUrl()
		{
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getAdministrativeSearchUrl(), QUrl(QStringLiteral("https://servicesuche.bund.de/#/en")));

			LanguageLoader::getInstance().load(QLocale::German);
			QCOMPARE(Env::getSingleton<PinResetInformationModel>()->getAdministrativeSearchUrl(), QUrl(QStringLiteral("https://servicesuche.bund.de")));

		}


		void test_HasPinResetService()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			QVERIFY(!Env::getSingleton<PinResetInformationModel>()->hasPinResetService());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			QVERIFY(Env::getSingleton<PinResetInformationModel>()->hasPinResetService());
		}


		void test_getNoPinAndNoPukHint()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getNoPinAndNoPukHint();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getNoPinAndNoPukHint();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getRequestNewPinHint()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getRequestNewPinHint();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getRequestNewPinHint();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getActivateOnlineFunctionHint()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getActivateOnlineFunctionHint();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getActivateOnlineFunctionHint();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getActivateOnlineFunctionActionText()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getActivateOnlineFunctionActionText();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getActivateOnlineFunctionActionText();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getPinResetHintNoPin()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getPinResetHintNoPin();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getPinResetHintNoPin();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getPinResetHintTransportPin()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getPinResetHintTransportPin();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getPinResetHintTransportPin();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getPinResetHint()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getPinResetHint();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getPinResetHint();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


		void test_getPinResetActionText()
		{
			auto* config = Env::getSingleton<ProviderConfiguration>();

			config->parseProviderConfiguration(":/updatable-files/supported-providers_no-prs.json"_L1);
			const auto& noPrs = Env::getSingleton<PinResetInformationModel>()->getPinResetActionText();
			QVERIFY(!noPrs.isNull());

			config->parseProviderConfiguration(":/updatable-files/supported-providers_prs.json"_L1);
			const auto& prs = Env::getSingleton<PinResetInformationModel>()->getPinResetActionText();
			QVERIFY(!prs.isNull());

			QVERIFY(noPrs != prs);
		}


};

QTEST_GUILESS_MAIN(test_PinResetInformationModel)
#include "test_PinResetInformationModel.moc"
