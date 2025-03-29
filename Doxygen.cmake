include_guard()

set(DOCUMENTATION_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src CACHE STRING "Choose the path of source files." FORCE)

find_package(Doxygen REQUIRED dot)

if(DOXYGEN_FOUND)

    if(NOT DOXYGEN_AWESOME_VERSION)
        set(DOXYGEN_AWESOME_VERSION "v2.3.4")
    endif()

    message("Dowloading doxygen-awesome-css to ${PROJECT_SOURCE_DIR}/../docs")

    set(STYLE_FILES
        doxygen-awesome.css
        doxygen-awesome-sidebar-only.css
        doxygen-awesome-darkmode-toggle.js
    )
    list(LENGTH STYLE_FILES style_files_count)
    math(EXPR max_index "${style_files_count} - 1")

    foreach(index RANGE 0 ${max_index})
        list(GET STYLE_FILES ${index} style_file_name)

        if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/docs/${style_file_name})
            file(DOWNLOAD https://raw.githubusercontent.com/jothepro/doxygen-awesome-css/${DOXYGEN_AWESOME_VERSION}/${style_file_name}
                ${CMAKE_CURRENT_SOURCE_DIR}/docs/${style_file_name} SHOW_PROGRESS)
        endif()
    endforeach()

    set(DOXYGEN_GENERATE_HTML YES)
    set(DOXYGEN_HTML_OUTPUT ${CMAKE_BINARY_DIR}/docs)
    set(DOXYGEN_GENERATE_TREEVIEW YES)
    set(DOXYGEN_DISABLE_INDEX NO)
    set(DOXYGEN_FULL_SIDEBAR NO)
    set(DOXYGEN_EXCLUDE_PATTERNS */build/*)
    # Habilitar esse header se quiser usar o toggle para Light/Dark Mode. >= v1.92
    # set(DOXYGEN_HTML_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/docs/header.html)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen-awesome.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen-awesome-sidebar-only.css)
    # list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen-awesome-darkmode-toggle.js)

    doxygen_add_docs(documentation ${DOCUMENTATION_SOURCES} COMMENT "Generating documentation")

else()
    message(FATAL_ERROR "Doxygen is needed to build the documentation.")
endif()


