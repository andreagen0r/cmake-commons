include_guard()

option(ENABLE_IPO "Enable Interprocedural Optimization, aka Link Time Optimization (LTO)" OFF)
option(ENABLE_PCH "Enable Precompiled Headers" OFF)
option(ENABLE_CACHE "Enable cache if available" ON)
option(ENABLE_MARCH_NATIVE "Enable march=native if build on the host machine" OFF)

# Generate compile_commands.json to make it easier to work with clang based tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Generate position independent code (-fPIC on UNIX)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Enable folder support for IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# ----------------------------------------------
# BUILD_TYPE
# ----------------------------------------------
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS
    "Debug"
    "Release"
    "MinSizeRel"
    "RelWithDebInfo"
    FORCE)
endif()

if(ENABLE_MARCH_NATIVE)
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -march=native")
endif()

message(STATUS "CMAKE_CXX_FLAGS_DEBUG is ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "CMAKE_CXX_FLAGS_RELEASE is ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "CMAKE_CXX_FLAGS_RELWITHDEBINFO is ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
message(STATUS "CMAKE_CXX_FLAGS_MINSIZEREL is ${CMAKE_CXX_FLAGS_MINSIZEREL}")

# ----------------------------------------------
# IPO / LTO
# ----------------------------------------------
if(ENABLE_IPO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  else()
    message(SEND_ERROR "IPO is not supported: ${output}")
  endif()
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  add_compile_options(-fcolor-diagnostics)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  add_compile_options(-fdiagnostics-color=always)
else()
  message(STATUS "No colored compiler diagnostic set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
endif()

# ----------------------------------------------
# PCH
# ----------------------------------------------
if(ENABLE_PCH)
  message(STATUS "Compiling using pre-compiled header support ${ENABLE_PCH}")
  target_precompile_headers(project_options
    INTERFACE
    <array>
    <vector>
    <string>
    <map>
    <queue>
    <stack>
    <span>
    <utility>
    <memory>
    <algorithm>
    <numeric>
    <string>
    <string_view>
    <random>
    <numbers>
    <chrono>
  )
endif()

# ----------------------------------------------
# TRACE TIME
# ----------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  option(ENABLE_BUILD_WITH_TIME_TRACE "Enable -ftime-trace to generate time tracing .json files on clang" OFF)
  if(ENABLE_BUILD_WITH_TIME_TRACE)
    target_compile_options(project_options INTERFACE -ftime-trace)
  endif()
endif()

# ----------------------------------------------
# CACHE
# ----------------------------------------------
if(ENABLE_CACHE)
  set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
  set(CACHE_OPTION_VALUES "ccache" "sccache")
  set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})

  list(FIND CACHE_OPTION_VALUES ${CACHE_OPTION} CACHE_OPTION_INDEX)

  if(${CACHE_OPTION_INDEX} EQUAL -1)
    message(STATUS "Using custom compiler cache system: '${CACHE_OPTION}', explicitly supported entries are ${CACHE_OPTION_VALUES}")
  endif()

  find_program(CACHE_BINARY ${CACHE_OPTION})

  if(CACHE_BINARY)
    message(STATUS "${CACHE_OPTION} found and enabled")
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY})
  else()
    message(WARNING "${CACHE_OPTION} is enabled but was not found. Not using it")
  endif()
endif()
