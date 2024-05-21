cmake_minimum_required(VERSION 3.16)
project(OSPRAY_GSG LANGUAGES CXX)

# CMakeLists.txt will find required OSPRay build assets from the env files that set CMAKE_PREFIX_PATH
# Lin/macOS:
#  source <path/to/renderkit>/ospray/rk-ospray-vars.sh
#  source <path/to/renderkit>/rkcommon/rk-rkcommon-vars.sh
#  source <path/to/renderkit>/tbb/rk-onetbb-vars.sh
# Win:
#  call <path/to/renderkit>/ospray/rk-ospray-vars.bat
#  call <path/to/renderkit>/rkcommon/rk-rkcommon-vars.bat
#  call <path/to/renderkit>/tbb/rk-onetbb-vars.bat

find_package(ospray REQUIRED)

set(RKCOMMON_BASE_PATH "${OSPRAY_ROOT}/../rkcommon")

list(APPEND CMAKE_PREFIX_PATH "${RKCOMMON_BASE_PATH}")
find_package(rkcommon REQUIRED PATHS "${RKCOMMON_BASE_PATH}")

if(MSVC)
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif(MSVC)

set(RKCOMMON_INCLUDE_PATH "${RKCOMMON_BASE_PATH}/include")
include_directories(${OSPRAY_INCLUDE_DIR} ${RKCOMMON_INCLUDE_PATH})
link_directories(${OSPRAY_ROOT}/lib ${RKCOMMON_BASE_PATH}/lib)

add_executable(ospTutorialCpp ${OSPRAY_RESOURCE} src/ospTutorial.cpp)
target_link_libraries(ospTutorialCpp PRIVATE ospray rkcommon)

install(TARGETS ospTutorialCpp
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)
