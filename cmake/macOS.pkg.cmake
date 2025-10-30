cmake_minimum_required(VERSION 3.25)

find_program(XCRUN xcrun)
if(NOT XCRUN)
	message(FATAL_ERROR "Cannot find 'xcrun'")
endif()

set(APP_PATH ${CPACK_TEMPORARY_DIRECTORY}/${CPACK_PACKAGE_NAME}.app)
set(PKG_PATH ${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.pkg)

execute_process(COMMAND ${XCRUN} productbuild --sign "3rd Party Mac Developer Installer: Governikus GmbH & Co. KG (G7EQCJU4BR)" --component ${APP_PATH} /Applications ${PKG_PATH})
