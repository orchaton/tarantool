if (TARGET_OS_DARWIN)
    set(module_link_flags "-pagezero_size 10000 -image_base 100000000")
endif()

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/box/lua)

set(lua_sources)
lua_source(lua_sources lua/box.lua)
lua_source(lua_sources lua/box_net.lua)
lua_source(lua_sources lua/misc.lua)

add_custom_target(box_generate_lua_sources
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/box
    DEPENDS ${lua_sources})
set_property(DIRECTORY PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${lua_sources})

tarantool_module("box"
    tuple.cc
    tuple_convert.cc
    tuple_update.cc
    key_def.cc
    index.cc
    hash_index.cc
    tree_index.cc
    avl_tree_index.cc
    bitset_index.cc
    space.cc
    port.cc
    request.cc
    txn.cc
    box.cc
    ${lua_sources}
    box_lua.cc
    box_lua_space.cc)

target_link_libraries(ltbox salad)
set_source_files_properties(box_lua.cc PROPERTIES COMPILE_FLAGS "-Wno-deprecated")
target_link_libraries(tarantool_box bitset)
