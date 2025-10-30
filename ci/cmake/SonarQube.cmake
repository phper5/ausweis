block()
	include(Libraries)
endblock()

if(NOT PACKAGES_DIR)
	set(PACKAGES_DIR $ENV{PACKAGES_DIR})
	if(NOT PACKAGES_DIR)
		set(PACKAGES_DIR ${CMAKE_BINARY_DIR})
	endif()
endif()
message(STATUS "Use PACKAGES_DIR: ${PACKAGES_DIR}")

set(SONARSCANNERCLI_VERSION 7.3.0.5189) # https://binaries.sonarsource.com/?prefix=Distribution/sonar-scanner-cli/
set(SONARSCANNERCLI_ZIP_NAME sonar-scanner-cli-${SONARSCANNERCLI_VERSION}.zip)
set(SONARSCANNERCLI_URL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONARSCANNERCLI_ZIP_NAME})
set(SONARSCANNERCLI_HASH a251d0793cb6bd889e4fd30299bb5dc4e07433e57133b16fc227aca98f8d2c2d)

set(DEPENDENCYCHECK_VERSION 12.1.8) # https://github.com/dependency-check/DependencyCheck
set(DEPENDENCYCHECK_ZIP_NAME dependency-check-${DEPENDENCYCHECK_VERSION}-release.zip)
set(DEPENDENCYCHECK_URL https://github.com/dependency-check/DependencyCheck/releases/download/v${DEPENDENCYCHECK_VERSION}/${DEPENDENCYCHECK_ZIP_NAME})
set(DEPENDENCYCHECK_HASH bd51cf867950ffcfc4e074c43948127f450fceedc93f628d52815588412d38a6)

set(MARIADB_CONNECTOR_VERSION 3.5.6)
set(MARIADB_CONNECTOR_ZIP_NAME mariadb-java-client-${MARIADB_CONNECTOR_VERSION}.jar)
set(MARIADB_CONNECTOR_URL https://downloads.mariadb.com/Connectors/java/connector-java-${MARIADB_CONNECTOR_VERSION}/${MARIADB_CONNECTOR_ZIP_NAME})
set(MARIADB_CONNECTOR_HASH a129703efd7b0f334564d46753de999f09b3a361489a2eb647e6020390981cc9)

set(SONARQUBETOOLS_DIR ${WORKSPACE}/sonarqubetools)
step(${CMAKE_COMMAND} -E make_directory ${SONARQUBETOOLS_DIR})

function(DOWNLOAD_AND_EXTRACT NAME URL ZIP_NAME HASH EXTRACT_DIR RESULT_DIR EXTRACT)
	if(EXISTS "${SONARQUBETOOLS_DIR}/${RESULT_DIR}" AND EXTRACT)
		message(STATUS "Removing previous ${NAME}")
		step(${CMAKE_COMMAND} -E rm -rf ${SONARQUBETOOLS_DIR}/${RESULT_DIR})
	endif()

	if(NOT EXISTS "${PACKAGES_DIR}/${ZIP_NAME}" OR NOT HASH)
		message(STATUS "Download ${NAME}: ${ZIP_NAME}")
		file(DOWNLOAD ${URL} ${PACKAGES_DIR}/${ZIP_NAME})
	endif()

	if(HASH)
		file(SHA256 ${PACKAGES_DIR}/${ZIP_NAME} FILE_HASH)
		if(NOT "${FILE_HASH}" STREQUAL "${HASH}")
			message(FATAL_ERROR "${NAME} hash does not match! Current: ${FILE_HASH}, expected: ${HASH}")
		endif()
	endif()

	message(STATUS "Install ${NAME}: ${ZIP_NAME}")
	if(EXTRACT)
		step(${CMAKE_COMMAND} -E tar xf ${PACKAGES_DIR}/${ZIP_NAME} CHDIR ${SONARQUBETOOLS_DIR})
		if(NOT "${EXTRACT_DIR}" STREQUAL "${RESULT_DIR}")
			step(${CMAKE_COMMAND} -E rename ${SONARQUBETOOLS_DIR}/${EXTRACT_DIR} ${SONARQUBETOOLS_DIR}/${RESULT_DIR})
		endif()
	else()
		step(${CMAKE_COMMAND} -E copy_if_different ${PACKAGES_DIR}/${MARIADB_CONNECTOR_ZIP_NAME} ${SONARQUBETOOLS_DIR}/${RESULT_DIR})
	endif()
endfunction()

DOWNLOAD_AND_EXTRACT("SonarScanner" ${SONARSCANNERCLI_URL} ${SONARSCANNERCLI_ZIP_NAME} ${SONARSCANNERCLI_HASH} "sonar-scanner-${SONARSCANNERCLI_VERSION}" "sonar-scanner" TRUE)
DOWNLOAD_AND_EXTRACT("Dependency Check" ${DEPENDENCYCHECK_URL} ${DEPENDENCYCHECK_ZIP_NAME} ${DEPENDENCYCHECK_HASH} "dependency-check" "dependency-check" TRUE)
DOWNLOAD_AND_EXTRACT("Dependency Check MariaDB Connector" ${MARIADB_CONNECTOR_URL} ${MARIADB_CONNECTOR_ZIP_NAME} ${MARIADB_CONNECTOR_HASH} "dependency-check/lib/" "dependency-check/lib/" FALSE)

set(SONAR_DIR "${WORKSPACE}/sonar")
if(NOT EXISTS ${SONAR_DIR})
	step(${CMAKE_COMMAND} -E make_directory ${SONAR_DIR})
endif()

step(${T_CFG} --preset ci-linux)

step(${SONARQUBETOOLS_DIR}/dependency-check/bin/dependency-check.sh
	--enableExperimental -f HTML -f JSON --scan ${CMAKE_DIR} --noupdate
	--connectionString=jdbc:mariadb://dependency-check-db.govkg.de/dependencycheck
	--dbUser=$ENV{DEPENDENCY_CHECK_USER}
	--dbPassword=$ENV{DEPENDENCY_CHECK_PASSWORD}
	--dbDriverName=org.mariadb.jdbc.Driver
	CHDIR ${T_BUILD_DIR}
)

step(${T_BUILD})

step(${T_CTEST} -LE qml -E Test_ui_qml_Qml)

step(${T_TARGET} gcovr.sonar)

if(DEFINED ENV{GITLAB_CI})
	set(BRANCH $ENV{REV})
elseif(DEFINED ENV{JENKINS_HOME})
	set(BRANCH $ENV{MERCURIAL_REVISION_BRANCH})
else()
	message(FATAL_ERROR "Unknown branch for SonarQube")
endif()

if(REVIEW)
	if(DEFINED ENV{REVIEWBOARD_REVIEW_ID})
		set(KEY $ENV{REVIEWBOARD_REVIEW_ID})
	elseif(DEFINED ENV{GITLAB_CI})
		set(KEY pipeline-$ENV{CI_PIPELINE_ID})
	elseif(DEFINED ENV{JENKINS_HOME})
		set(KEY $ENV{BUILD_TAG})
	else()
		message(FATAL_ERROR "Unknown key for SonarQube")
	endif()

	set(SONAR_CMDLINE
		-Dsonar.pullrequest.key=${KEY}
		-Dsonar.pullrequest.branch=${BRANCH}
		-Dsonar.pullrequest.base=${BRANCH}
	)
else()
	set(SONAR_CMDLINE
		-Dsonar.branch.name=${BRANCH}
	)
endif()

if(DEFINED ENV{JENKINS_HOME})
	list(APPEND SONAR_CMDLINE -Dsonar.cfamily.threads=4)
elseif(DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL})
	list(APPEND SONAR_CMDLINE -Dsonar.cfamily.threads=$ENV{CMAKE_BUILD_PARALLEL_LEVEL})
endif()

step(
	${SONARQUBETOOLS_DIR}/sonar-scanner/bin/sonar-scanner
	-Dsonar.scanner.metadataFilePath=${T_TEMP}/sonar-metadata.txt
	${SONAR_CMDLINE}
	-Dsonar.qualitygate.wait=true
	-Dsonar.qualitygate.timeout=90
	-Dsonar.cfamily.analysisCache.mode=fs
	-Dsonar.cfamily.analysisCache.path=${SONAR_DIR}
	-Dsonar.scanner.skipJreProvisioning=true
	CHDIR ${T_BUILD_DIR}
	ENV SONAR_USER_HOME=${SONAR_DIR}/home
)
