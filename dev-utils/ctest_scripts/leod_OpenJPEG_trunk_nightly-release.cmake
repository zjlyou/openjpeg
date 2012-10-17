# -----------------------------------------------------------------------------
# Nightly script for OpenJPEG trunk
# This will retrieve/compile/run tests/upload to cdash OpenJPEG
# Results will be available at: http://my.cdash.org/index.php?project=OPENJPEG
# ctest -S leod_openJPEG_trunk_nightly.cmake -V
# Author: mickael.savinaud@c-s.fr
# Date: 2012-10-17
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

# Set where to find src and test data and where to build binaries.
SET (CTEST_SOURCE_DIRECTORY       "$ENV{HOME}/Dashboard/nightly/OpenJPEG-trunk-release/src")
SET (CTEST_BINARY_DIRECTORY       "$ENV{HOME}/Dashboard/nightly/OpenJPEG-trunk-release/build")
SET (CTEST_SOURCE_DATA_DIRECTORY  "$ENV{HOME}/Data/OPJ-Data")

# User inputs:
SET( CTEST_CMAKE_GENERATOR      "Unix Makefiles" )    # What is your compilation apps ?
SET( CTEST_CMAKE_COMMAND        "cmake" )
SET( CTEST_BUILD_COMMAND        "/usr/bin/make -j6" )
SET( CTEST_SITE                 "leod.c-s.fr" )       # Generally the output of hostname
SET( CTEST_BUILD_CONFIGURATION  Release)                # What type of build do you want ?
SET( CTEST_BUILD_NAME           "MacOSX10.8-32bits-${CTEST_BUILD_CONFIGURATION}") # Build Name

set( CACHE_CONTENTS "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_C_FLAGS:STRING= -Wall 

BUILD_TESTING:BOOL=TRUE

OPJ_DATA_ROOT:PATH=${CTEST_SOURCE_DATA_DIRECTORY}

" )

# Files to submit to the dashboard
SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

# Update method 
# repository: http://openjpeg.googlecode.com/trunk
# need to use https for CS machine
set( CTEST_UPDATE_COMMAND   "svn")

# 3. cmake specific:
#set( CTEST_NOTES_FILES      "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

ctest_empty_binary_directory( "${CTEST_BINARY_DIRECTORY}" )
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${CACHE_CONTENTS}")

# Perform the Nightly build
ctest_start(Nightly TRACK "Nightly Expected")
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit()

