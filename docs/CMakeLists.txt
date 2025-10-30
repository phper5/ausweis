if(SPHINX_FOUND)
	if(NOT PANDOC_BIN)
		set(BUILD_LATEX "latex")
	endif()

	SPHINX_GEN("${CMAKE_CURRENT_SOURCE_DIR}/releasenotes" "notes" BUILDER html text ${BUILD_LATEX})

	SPHINX_GEN("${CMAKE_CURRENT_SOURCE_DIR}/sdk" "sdk" BUILDER html ${BUILD_LATEX} DEFAULT_LANG en)

	SPHINX_GEN("${CMAKE_CURRENT_SOURCE_DIR}/installation_de" "installation_integration_de" BUILDER changes html ${BUILD_LATEX} DEFAULT_LANG de)

	SPHINX_GEN("${CMAKE_CURRENT_SOURCE_DIR}/installation_en" "installation_integration_en" BUILDER changes html ${BUILD_LATEX} DEFAULT_LANG en)

	SPHINX_GEN("${CMAKE_CURRENT_SOURCE_DIR}/failurecodes" "failurecodes" BUILDER changes html ${BUILD_LATEX} DEFAULT_LANG en)
else()
	message(STATUS "No sphinx documentation will be generated")
endif()

if(PANDOC_BIN)
	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/releasenotes" "notes" OUTPUT_NAME "ReleaseNotes")

	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/sdk" "sdk" CUSTOM_PANDOC_PARAM -f rst-auto_identifiers OUTPUT_NAME "SDK")

	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/installation_en" "installation_integration_en" OUTPUT_NAME "NetInstallation_Integration_en")

	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/installation_de" "installation_integration_de" OUTPUT_NAME "NetInstallation_Integration_de")

	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/failurecodes" "failurecodes_en" OUTPUT_NAME "Failure-Codes-en")

	PANDOC_RST_TO_PDF("${CMAKE_CURRENT_SOURCE_DIR}/failurecodes" "failurecodes_de" OUTPUT_NAME "Failure-Codes-de" TRANSLATE "de")
else()
	message(STATUS "No PDF documentation will be generated")
endif()
