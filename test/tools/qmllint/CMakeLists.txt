if(QT_VERSION VERSION_GREATER_EQUAL 6.9)
	if(TARGET ${Qt}::QmlCompiler)
		qt_add_plugin(PluginQmllint)
		file(GLOB_RECURSE FILES "*.cpp")
		target_sources(PluginQmllint PRIVATE ${FILES})
		target_link_libraries(PluginQmllint PRIVATE Qt::QmlCompiler)
	endif()

	get_filename_component(PARENT_DIR "${CMAKE_CURRENT_BINARY_DIR}" DIRECTORY)
	add_test(NAME qmllint
			COMMAND ${CMAKE_COMMAND} -E env QT_PLUGIN_PATH=${PARENT_DIR} --  ${CMAKE_COMMAND} --build . --target all_qmllint
			WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
	set_tests_properties(qmllint PROPERTIES LABELS "qml")
endif()
