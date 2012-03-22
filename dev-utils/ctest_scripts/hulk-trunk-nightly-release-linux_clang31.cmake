# Client maintainer: julien . malik  gmail . com

set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

set(KDUPATH $ENV{HOME}/Dashboard/src/OpenJPEG/kakadu)
set(CLANGPATH $ENV{HOME}/tools/install/llvm/bin)
set(ENV{LD_LIBRARY_PATH} ${KDUPATH})
set(ENV{PATH} $ENV{PATH}:${KDUPATH})
set(ENV{PATH} $ENV{PATH}:${CLANGPATH})
set(ENV{CC} clang)
set(ENV{CFLAGS} "-Wall")

macro(dashboard_hook_init)
  set( dashboard_cache "
  BUILD_TESTING:BOOL=ON
  BUILD_JPIP:BOOL=ON
  BUILD_JPIP_SERVER:BOOL=ON
  BUILD_THIRDPARTY:BOOL=ON

  OPJ_DATA_ROOT:PATH=$ENV{HOME}/Dashboard/src/OpenJPEG/opj-data
    "
    )
endmacro(dashboard_hook_init)

# Filename convention is:
# ctestsite-branchname-model-configuration-buildname.ctest
get_filename_component(OPJ_CTEST_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
include(${CTEST_SCRIPT_DIRECTORY}/openjpeg_common.cmake)
