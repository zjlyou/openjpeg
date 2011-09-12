# -----------------------------------------------------------------------------
# Example ot ctest script for OpenJPEG project
# This will retrieve/compile/run tests/upload to cdash OpenJPEG
# Results will be available at: http://my.cdash.org/index.php?project=OPENJPEG
# ctest -S ctest_script_example.cmake -V
# Author: mickael.savinaud@c-s.fr
# Date: 2011-09-12
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

#####################
# Begin User inputs (1/2):

SET( CTEST_DASHBOARD_ROOT	"/tmp" ) 		# Writable directory
SET( CTEST_CMAKE_GENERATOR	"Unix Makefiles")	# What is your compilation apps ?
SET( CTEST_SITE			"mymachine" )		# Generally the output of hostname
SET( CTEST_BUILD_CONFIGURATION	Debug)			# What type of build do you want ?

# Options 
SET( CACHE_CONTENTS "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

# Warning level
CMAKE_C_FLAGS:STRING= -Wall

# Use to activate the test suite
BUILD_TESTING:BOOL=TRUE

# Build Thirdparty, useful but not required for test suite 
BUILD_THIRDPARTY:BOOL=FALSE

# JPEG2000 test files are available with svn checkout http://openjpeg.googlecode.com/svn/data or with the execute # process command which could be found later
#OPJ_DATA_ROOT:PATH=path/to/the/data/directory
OPJ_DATA_ROOT:PATH=/home/mickael/dev/src/OpenJPEG/opj-data

# To execute the encoding test suite, kakadu binaries are needed to decode encoded image and compare 
# it to the baseline. Kakadu binaries are freely available for non-commercial purposes 
# at http://www.kakadusoftware.com. Please specify the binary path in the following variable:  
REF_DECODER_BIN_PATH:PATH=path/to/the/kakadu/binary/directory

" )

# End User inputs (1/2)
#####################


#---------------------
#1. openjpeg specific: 
SET( CTEST_PROJECT_NAME	"OPENJPEG" )
SET( CTEST_SOURCE_NAME	"opj-src")
SET( CTEST_BUILD_NAME	"${CMAKE_SYSTEM}-${CTEST_CMAKE_GENERATOR}-${CTEST_BUILD_CONFIGURATION}")
SET( CTEST_BINARY_NAME	"${CTEST_BUILD_NAME}")

#---------------------
# 2. cdash/openjpeg specific:
# In some cases you need to use https protocol
#SET( CTEST_SVN_URL          "http://openjpeg.googlecode.com/svn")
SET( CTEST_SVN_URL          "https://openjpeg.googlecode.com/svn")
SET( CTEST_UPDATE_COMMAND   "svn")

#####################
# Begin User inputs (2/2):

# Chose if you want sources from trunk or openjpeg-1.5 branche
#SET( CTEST_CHECKOUT_COMMAND "${CTEST_UPDATE_COMMAND} co ${CTEST_SVN_URL}/trunk ${CTEST_SOURCE_NAME}")
SET( CTEST_CHECKOUT_COMMAND "${CTEST_UPDATE_COMMAND} co ${CTEST_SVN_URL}/branches/openjpeg-1.5 ${CTEST_SOURCE_NAME}")

# End User inputs (2/2)
#####################

# 3. cmake specific:
SET( CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_SOURCE_NAME}")
SET( CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_BINARY_NAME}")

#---------------------
# Files to submit to the dashboard
SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt )

ctest_empty_binary_directory( "${CTEST_BINARY_DIRECTORY}" )
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${CACHE_CONTENTS}")

# Perform a Experimental build
ctest_start(Experimental)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit()
