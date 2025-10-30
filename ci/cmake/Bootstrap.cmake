set(ENV_FILE ${CMAKE_BINARY_DIR}/env)

function(append_env_file _line)
	file(APPEND "${ENV_FILE}" ${_line}\n)
endfunction()

step(hg log -r . -T {node} -R ${CMAKE_SOURCE_DIR} OUTPUT REVISION)

set(IS_FINAL_VERSION false)
if(RELEASE)
	message(STATUS "Used REV: ${REV}")

	string(REPLACE "." ";" VERSION_LIST "${REV}")
	list(LENGTH VERSION_LIST VERSION_LIST_LENGTH)
	if(VERSION_LIST_LENGTH GREATER_EQUAL 3)
		list(GET VERSION_LIST 1 PROJECT_VERSION_MINOR)
		list(GET VERSION_LIST 2 PROJECT_VERSION_PATCH)
		set(PROJECT_VERSION ${REV})

		list(APPEND CMAKE_MODULE_PATH ${CMAKE_DIR})
		include(DVCS)
		list(POP_BACK CMAKE_MODULE_PATH)
		if(NOT IS_BETA_VERSION)
			set(IS_FINAL_VERSION true)
		endif()
	endif()
endif()

append_env_file("RELEASE_FINAL=${IS_FINAL_VERSION}")
append_env_file("RELEASE=${RELEASE}")
append_env_file("REV=${REV}")
append_env_file("REVISION=${REVISION}")

configure_file("${CMAKE_SOURCE_DIR}/.gitlab-ci-child.yml" "${CMAKE_BINARY_DIR}/gitlab-ci-child.yml" COPYONLY)
