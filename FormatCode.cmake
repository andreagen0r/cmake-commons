function(add_clang_format_target TARGET_NAME SOURCE_DIR)
    find_program(CLANG-FORMAT_PATH clang-format REQUIRED)
    
    file(GLOB_RECURSE FORMAT_SOURCES
        LIST_DIRECTORIES false
        "${SOURCE_DIR}/*.cpp"
        "${SOURCE_DIR}/*.mm"
        "${SOURCE_DIR}/*.hpp"
        "${SOURCE_DIR}/*.h"
    )
    
    add_custom_target(${TARGET_NAME}
        COMMAND ${CLANG-FORMAT_PATH} -i ${FORMAT_SOURCES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} #Avaliar se pode ser assim
        COMMENT "Running clang-format on ${SOURCE_DIR} sources"
    )

endfunction()
