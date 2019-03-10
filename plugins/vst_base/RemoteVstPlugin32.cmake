IF(LMMS_BUILD_WIN32 AND NOT LMMS_BUILD_WIN64)
	ADD_SUBDIRECTORY(RemoteVstPlugin)
	IF(MSVC)
		SET(VCPKG_ROOT "${CMAKE_FIND_ROOT_PATH}")
		INSTALL(FILES "${VCPKG_ROOT}/bin/Qt5Core.dll" DESTINATION "${PLUGIN_DIR}/32")
		INSTALL(FILES "${VCPKG_ROOT}/bin/zlib1.dll" DESTINATION "${PLUGIN_DIR}/32")
	ELSE(MSVC)
		INSTALL(FILES "${MINGW_PREFIX}/bin/Qt5Core.dll" DESTINATION "${PLUGIN_DIR}/32")
		INSTALL(FILES "${MINGW_PREFIX}/bin/zlib1.dll" DESTINATION "${PLUGIN_DIR}/32")
	ENDIF(MSVC)
	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../32/RemoteVstPlugin32.exe" DESTINATION "${PLUGIN_DIR}/32")
ELSEIF(LMMS_BUILD_WIN64 AND MSVC)
	SET(MSVC_VER ${CMAKE_CXX_COMPILER_VERSION})

	IF(NOT CMAKE_GENERATOR_32)
		IF(MSVC_VER VERSION_GREATER 19.10 OR MSVC_VER VERSION_EQUAL 19.10)
			SET(CMAKE_GENERATOR_32 "Visual Studio 15 2017")
			SET(MSVC_YEAR 2017)
		ELSEIF(MSVC_VER VERSION_GREATER 19.0 OR MSVC_VER VERSION_EQUAL 19.0)
			SET(CMAKE_GENERATOR_32 "Visual Studio 14 2015")
			SET(MSVC_YEAR 2015)
		ELSE()
			MESSAGE(SEND_WARNING "Can't build RemoteVstPlugin32, unknown MSVC version ${MSVC_VER} and no CMAKE_GENERATOR_32 set")
			RETURN()
		ENDIF()
	ENDIF()

	IF(NOT QT_32_PREFIX)
		GET_FILENAME_COMPONENT(QT_BIN_DIR ${QT_QMAKE_EXECUTABLE} DIRECTORY)
		SET(QT_32_PREFIX "${QT_BIN_DIR}/../../msvc${MSVC_YEAR}")
	ENDIF()

	#TODO: qt5 installed using vcpkg: I don't know how to detect if the user built the x86 version of qt5 from here. At least not cleanly.
	#So for the moment, we'll allow the built.
	IF(NOT (IS_DIRECTORY ${QT_32_PREFIX} AND EXISTS ${QT_32_PREFIX}/bin/qmake.exe))
		MESSAGE(WARNING "No Qt 32 bit installation found at ${QT_32_PREFIX}. If you're using VCPKG you can ignore this message if you've built x86-windows version of qt5")
	ENDIF()

	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_GENERATOR "${CMAKE_GENERATOR_32}"
		#CMAKE_GENERATOR_TOOLSET "${CMAKE_GENERATOR_TOOLSET}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
			"-DCMAKE_PREFIX_PATH=${QT_32_PREFIX}"
	)

	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../32/RemoteVstPlugin32.exe" DESTINATION "${PLUGIN_DIR}/32")

	#TODO: find a solution when not using vcpkg for qt
	SET(VCPKG_ROOT_32 "${CMAKE_FIND_ROOT_PATH}/../x86-windows")

	INSTALL(FILES "${VCPKG_ROOT_32}/bin/zlib1.dll" DESTINATION "${PLUGIN_DIR}/32")
	INSTALL(FILES "${VCPKG_ROOT_32}/bin/pcre2-16.dll" DESTINATION "${PLUGIN_DIR}/32")
	INSTALL(FILES "${VCPKG_ROOT_32}/bin/double-conversion.dll" DESTINATION "${PLUGIN_DIR}/32")
	INSTALL(FILES "${VCPKG_ROOT_32}/bin/qt5core.dll" DESTINATION "${PLUGIN_DIR}/32")

ELSEIF(LMMS_BUILD_LINUX)
	# Use winegcc
	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_CXX_COMPILER=${WINEGCC}"
			"-DCMAKE_CXX_FLAGS=-m32"
	)

	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../32/RemoteVstPlugin32" "${CMAKE_CURRENT_BINARY_DIR}/../32/RemoteVstPlugin32.exe.so" DESTINATION "${PLUGIN_DIR}/32")

ELSEIF(CMAKE_TOOLCHAIN_FILE_32)
	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_32}"
			"-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE_32}"
	)
	INSTALL(FILES "${CMAKE_PREFIX_PATH_32}/bin/Qt5Core.dll" DESTINATION "${PLUGIN_DIR}/32")
	INSTALL(FILES "${CMAKE_PREFIX_PATH_32}/bin/zlib1.dll" DESTINATION "${PLUGIN_DIR}/32")
	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../32/RemoteVstPlugin32.exe" DESTINATION "${PLUGIN_DIR}/32")
ELSE()
	MESSAGE(WARNING "Can't build RemoteVstPlugin32, unknown environment. Please supply CMAKE_TOOLCHAIN_FILE_32 and optionally CMAKE_PREFIX_PATH_32")
	RETURN()
ENDIF()

