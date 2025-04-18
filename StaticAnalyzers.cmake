include_guard()

option(ENABLE_CPPCHECK "Enable static analysis with cppcheck" OFF)
option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
option(ENABLE_INCLUDE_WHAT_YOU_USE "Enable static analysis with include-what-you-use" OFF)


# ----------------------------------------------
# CPPCHECK
# ----------------------------------------------
if(ENABLE_CPPCHECK)
  find_program(CPPCHECK cppcheck REQUIRED)
  if(CPPCHECK)
  # cppcheck --project=compile_commands.json --enable=all 
  # --inconclusive --xml --xml-version=2 --output-file=../cppcheck.xml
    set(CMAKE_CXX_CPPCHECK
        ${CPPCHECK}
        --suppress=missingInclude
        --enable=all
        --inline-suppr
        --inconclusive)
    if(WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
    endif()
  else()
    message(SEND_ERROR "cppcheck requested but executable not found")
  endif()
endif()

# ----------------------------------------------
# CLANG_FORMAT
# ----------------------------------------------
file(GLOB_RECURSE
     ALL_CXX_SOURCE_FILES
     *.[chi]pp *.[chi]xx *.cc *.hh *.ii *.[CHI]
     )
find_program(CLANG_FORMAT "clang-format")
if(CLANG_FORMAT)
  add_custom_target(clang-format
    COMMAND /usr/bin/clang-format
    -i
    -style=file
    ${ALL_CXX_SOURCE_FILES}
    )
endif()

# ----------------------------------------------
# CLANG_TIDY
# ----------------------------------------------
if(ENABLE_CLANG_TIDY)
  find_program(CLANGTIDY clang-tidy REQUIRED)
  if(CLANGTIDY)
    set(${CLANGTIDY} -checks=*;)
    if(WARNINGS_AS_ERRORS)
      list(APPEND CMAKE_CXX_CLANG_TIDY -warnings-as-errors=*)
    endif()
  else()
    message(SEND_ERROR "clang-tidy requested but executable not found")
  endif()
endif()

# ----------------------------------------------
# IWYU
# ----------------------------------------------
if(ENABLE_INCLUDE_WHAT_YOU_USE)
  find_program(INCLUDE_WHAT_YOU_USE include-what-you-use REQUIRED)
  if(INCLUDE_WHAT_YOU_USE)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE})
  else()
    message(SEND_ERROR "include-what-you-use requested but executable not found")
  endif()
endif()
