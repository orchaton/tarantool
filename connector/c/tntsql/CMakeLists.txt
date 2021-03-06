#============================================================================#
# build flags
#============================================================================#

# default flags
if (${CMAKE_BUILD_TYPE} STREQUAL "None")
    set (tntsql_cflags "-std=gnu99")
else()
    set (tntsql_cflags "-std=gnu99 -Wall -Wextra")
    set (tntsql_cflags "${tntsql_cflags} -Wno-sign-compare -Wno-strict-aliasing")
endif()

# Only add -Werror if it's a debug build, done by developers.
if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set (tntsql_cflags "${tntsql_cflags} -Werror")
endif()

#============================================================================#
# Build tnt sql project
#============================================================================#

#
# source files
#

set (tntsql_sources
	tnt_utf8.c
	tnt_lex.c
	tnt_sql.c)

#----------------------------------------------------------------------------#
# Builds
#----------------------------------------------------------------------------#

# Here we manage to build static/dynamic libraries ourselves,
# do not use the top level settings.
string(REPLACE "-static-libgcc" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
string(REPLACE "-static" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

if (CMAKE_COMPILER_IS_GNUCC AND NOT CMAKE_COMPILER_IS_CLANG)
    set (tnt_cflags "${tnt_cflags} -static-libgcc")
endif()

#
# Static library
#

project(tntsql)
add_library(tntsql STATIC ${tntsql_sources})
set_target_properties(tntsql PROPERTIES COMPILE_FLAGS "${tntsql_cflags}")
set_target_properties(tntsql PROPERTIES VERSION ${LIBTNT_VERSION} SOVERSION ${LIBTNT_SOVERSION})
set_target_properties(tntsql PROPERTIES OUTPUT_NAME "tarantoolsql")

#
# Shared library
#

project(tntsql_shared)
add_library(tntsql_shared SHARED ${tntsql_sources})
target_link_libraries(tntsql_shared tnt_shared)
set_target_properties(tntsql_shared PROPERTIES OUTPUT_NAME tntsql)
set_target_properties(tntsql_shared PROPERTIES COMPILE_FLAGS "${tntsql_cflags}")
set_target_properties(tntsql_shared PROPERTIES VERSION ${LIBTNT_VERSION} SOVERSION ${LIBTNT_SOVERSION})
set_target_properties(tntsql_shared PROPERTIES OUTPUT_NAME "tarantoolsql")

#----------------------------------------------------------------------------#
# Install
#----------------------------------------------------------------------------#

install (TARGETS tntsql ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install (TARGETS tntsql_shared LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
