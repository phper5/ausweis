find_program(CURL curl REQUIRED)
list(APPEND CURL --fail -v -u $ENV{CLOUD_USER}:$ENV{CLOUD_PSW})
set(CLOUD_DESTINATION "$ENV{CLOUD_URL}/$ENV{REV}")

step(${CURL} -X MKCOL "${CLOUD_DESTINATION}")

file(GLOB files "${WORKSPACE}/*.msi" "${WORKSPACE}/*.dmg" "${WORKSPACE}/*.pkg" "${WORKSPACE}/*.apk" "${WORKSPACE}/*.ipa")
foreach(file ${files})
	cmake_path(GET file FILENAME filename)
	step(${CURL} -T ${file} "${CLOUD_DESTINATION}/${filename}")
endforeach()
