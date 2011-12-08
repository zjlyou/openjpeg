# OpenJPEG Common Dashboard Script
#
# This script contains basic dashboard driver code common to all
# clients.
#
# Put this script in a directory such as "~/Dashboards/Scripts" or
# "c:/Dashboards/Scripts".  Create a file next to this script, say
# 'my_dashboard.cmake', with code of the following form:
#
#   # Client maintainer: me@mydomain.net
#   set(CTEST_SITE "machine.site")
#   set(CTEST_BUILD_NAME "Platform-Compiler")
#   set(CTEST_BUILD_CONFIGURATION Debug)
#   set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
#   include(${CTEST_SCRIPT_DIRECTORY}/openjpeg_common.cmake)
#
# Then run a scheduled task (cron job) with a command line such as
#
#   ctest -S ~/Dashboards/Scripts/my_dashboard.cmake -V
#
# By default the source and build trees will be placed in the path
# "../My Tests/" relative to your script location.
#
# The following variables may be set before including this script
# to configure it:
#
#   dashboard_model           = Nightly | Experimental | Continuous
#   dashboard_loop            = Repeat until N seconds have elapsed
#   dashboard_root_name       = Change name of "My Tests" directory
#   dashboard_source_name     = Name of source directory (OpenJPEG)
#   dashboard_binary_name     = Name of binary directory (OpenJPEG-build)
#   dashboard_cache           = Initial CMakeCache.txt file content
#   dashboard_do_coverage     = True to enable coverage (ex: gcov)
#   dashboard_do_memcheck     = True to enable memcheck (ex: valgrind)
#   dashboard_no_clean        = True to skip build tree wipeout
#   CTEST_UPDATE_COMMAND      = path to svn command-line client
#   CTEST_BUILD_FLAGS         = build tool arguments (ex: -j2)
#   CTEST_DASHBOARD_ROOT      = Where to put source and build trees
#   CTEST_TEST_CTEST          = Whether to run long CTestTest* tests
#   CTEST_TEST_TIMEOUT        = Per-test timeout length
#   CTEST_TEST_ARGS           = ctest_test args (ex: PARALLEL_LEVEL 4)
#   CMAKE_MAKE_PROGRAM        = Path to "make" tool to use
#
# Options to configure builds from svn repository:
#   dashboard_svn_url      = Custom svn checkout url
#   dashboard_svn_branch   = Custom remote branch to track
#   dashboard_svn_crlf     = Value of core.autocrlf for repository
#
# The following macros will be invoked before the corresponding
# step if they are defined:
#
#   dashboard_hook_init       = End of initialization, before loop
#   dashboard_hook_start      = Start of loop body, before ctest_start
#   dashboard_hook_build      = Before ctest_build
#   dashboard_hook_test       = Before ctest_test
#   dashboard_hook_coverage   = Before ctest_coverage
#   dashboard_hook_memcheck   = Before ctest_memcheck
#   dashboard_hook_submit     = Before ctest_submit
#   dashboard_hook_end        = End of loop body, after ctest_submit
#
# For Makefile generators the script may be executed from an
# environment already configured to use the desired compilers.
# Alternatively the environment may be set at the top of the script:
#
#   set(ENV{CC}  /path/to/cc)   # C compiler
#   set(ENV{CXX} /path/to/cxx)  # C++ compiler
#   set(ENV{LD_LIBRARY_PATH} /path/to/vendor/lib) # (if necessary)

cmake_minimum_required(VERSION 2.8.2 FATAL_ERROR)

# Calling parent script has a name, let's figure out settings from the filename:
if(DEFINED OPJ_CTEST_NAME)
  # Compute default options from filename
  string(REPLACE "-" ";" output_variable "${OPJ_CTEST_NAME}")
  list(GET output_variable 0 CTEST_SITE)
  list(GET output_variable 1 dashboard_svn_branch)
  list(GET output_variable 2 dashboard_model)
  list(GET output_variable 3 CTEST_BUILD_CONFIGURATION)
  list(GET output_variable 4 ctest_build_name_root)
endif()

set(dashboard_user_home "$ENV{HOME}")

get_filename_component(dashboard_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

# Select the top dashboard directory.
if(NOT DEFINED dashboard_root_name)
  set(dashboard_root_name "MyTests")
endif()
if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  get_filename_component(CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}/../${dashboard_root_name}" ABSOLUTE)
endif()

# Make sure directory exist:
file(MAKE_DIRECTORY ${CTEST_DASHBOARD_ROOT})
if(NOT IS_DIRECTORY ${CTEST_DASHBOARD_ROOT})
  message(FATAL_ERROR "Could not create ${CTEST_DASHBOARD_ROOT}")
endif()

# Select the model (Nightly, Experimental, Continuous).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^([N|n]ightly|[E|e]xperimental|Continuous)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

# Default to a Debug build.
if(NOT DEFINED CTEST_CONFIGURATION_TYPE AND DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

# Make sure CTEST_COVERAGE_COMMAND is set:
if(NOT DEFINED CTEST_COVERAGE_COMMAND AND dashboard_do_coverage)
  SET(CTEST_COVERAGE_COMMAND "/usr/bin/gcov")
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE Debug)
endif()

# Choose CTest reporting mode.
if(NOT "${CTEST_CMAKE_GENERATOR}" MATCHES "Make")
  # Launchers work only with Makefile generators.
  set(CTEST_USE_LAUNCHERS 0)
elseif(NOT DEFINED CTEST_USE_LAUNCHERS)
  # The setting is ignored by CTest < 2.8 so we need no version test.
  set(CTEST_USE_LAUNCHERS 1)
endif()

# Configure testing.
if(NOT DEFINED CTEST_TEST_CTEST)
  set(CTEST_TEST_CTEST 1)
endif()
if(NOT CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()


# Select svn source to use.
if(NOT DEFINED dashboard_svn_root_url)
  set(dashboard_svn_root_url "http://openjpeg.googlecode.com/svn")
endif()
if(NOT DEFINED dashboard_svn_branch)
  if("${dashboard_model}" STREQUAL "Nightly")
    set(dashboard_svn_branch trunk)
  endif()
endif()
# b15 -> branches 1.5
if("${dashboard_svn_branch}" STREQUAL "b15")
  set(dashboard_svn_branch branches/openjpeg-1.5)
  # make sure that on same client source checkout will not conflict:
  if(NOT DEFINED dashboard_source_name)
    set(dashboard_source_name openjpeg-b15)
  endif()
  set(CTEST_BUILD_NAME ${ctest_build_name_root}-v1.5-${CTEST_BUILD_CONFIGURATION})
  set(TRACK_NAME "Nightly Release v1.5")
elseif("${dashboard_svn_branch}" STREQUAL "b20")
  set(dashboard_svn_branch branches/v2)
  if(NOT DEFINED dashboard_source_name)
    set(dashboard_source_name openjpeg-b20)
  endif()
  set(CTEST_BUILD_NAME ${ctest_build_name_root}-v2-${CTEST_BUILD_CONFIGURATION})
  set(TRACK_NAME "Nightly Release v2.0")
else()
  set(CTEST_BUILD_NAME ${ctest_build_name_root}-${dashboard_svn_branch}-${CTEST_BUILD_CONFIGURATION})
  if("${dashboard_model}" MATCHES "^[N|n]ightly$")
    set(TRACK_NAME "Nightly Expected")
  elseif("${dashboard_model}" MATCHES "^[E|e]xperimental$")
    set(TRACK_NAME "Experimental")
  else()
    message(FATAL_ERROR "${dashboard_svn_branch} / ${dashboard_model} unhandled")
  endif()
endif()

# compute full URL:
set(dashboard_svn_url "${dashboard_svn_root_url}/${dashboard_svn_branch}")


# Look for a SVN command-line client.
if(NOT DEFINED CTEST_SVN_COMMAND)
  find_program(CTEST_SVN_COMMAND NAMES svn)
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/openjpeg)
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}-${CTEST_BUILD_NAME})
  endif()
endif()

set(CTEST_CHECKOUT_COMMAND "${CTEST_SVN_COMMAND} co ${dashboard_svn_url} \"${CTEST_SOURCE_DIRECTORY}\"")

# data dir too:
# http://www.cmake.org/Wiki/CMake_Scripting_Of_CTest#More_Settings
#set(CTEST_CVS_COMMAND "svn")
#set(CTEST_EXTRA_UPDATES_1 "--non-interactive" "http://openjpeg.googlecode.com/svn/data")
#set(CTEST_EXTRA_UPDATES_1 "--non-interactive" "${CTEST_DASHBOARD_ROOT}/data")
# cant get the above to work at all. instead manually update data dir:

# need to call the directory data so that it is automatically found during openjpeg conf:
if(NOT EXISTS "${CTEST_DASHBOARD_ROOT}/data")
  message("pulling data from scratch")
  execute_process(
    COMMAND ${CTEST_SVN_COMMAND} "checkout" "http://openjpeg.googlecode.com/svn/data"
    WORKING_DIRECTORY ${CTEST_DASHBOARD_ROOT}
    )
else()
  message("updating data")
  execute_process(
    COMMAND ${CTEST_SVN_COMMAND} "update"
    WORKING_DIRECTORY ${CTEST_DASHBOARD_ROOT}/data
    )
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )

# Check for required variables.
foreach(req
    CTEST_CMAKE_GENERATOR
    CTEST_SITE
    CTEST_BUILD_NAME
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "The containing script must set ${req}")
  endif()
endforeach(req)

# Print summary information.
foreach(v
    CTEST_SITE
    CTEST_BUILD_NAME
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_BUILD_CONFIGURATION
    CTEST_SVN_COMMAND
    CTEST_CHECKOUT_COMMAND
    CTEST_SCRIPT_DIRECTORY
    CTEST_USE_LAUNCHERS
    )
  set(vars "${vars}  ${v}=[${${v}}]\n")
endforeach(v)
message("Dashboard script configuration:\n${vars}\n")

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

# Helper macro to write the initial cache.
macro(write_cache)
  set(cache_build_type "")
  set(cache_make_program "")
  if(CTEST_CMAKE_GENERATOR MATCHES "Make")
    set(cache_build_type CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION})
    if(CMAKE_MAKE_PROGRAM)
      set(cache_make_program CMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM})
    endif()
  endif()
  file(WRITE ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt "
SITE:STRING=${CTEST_SITE}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
${cache_build_type}
${cache_make_program}
${dashboard_cache}
")
endmacro(write_cache)

# Start with a fresh build tree.
file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
if(NOT "${CTEST_SOURCE_DIRECTORY}" STREQUAL "${CTEST_BINARY_DIRECTORY}"
    AND NOT dashboard_no_clean)
  message("Clearing build tree...")
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
endif()

set(dashboard_continuous 0)
if("${dashboard_model}" STREQUAL "Continuous")
  set(dashboard_continuous 1)
endif()
if(NOT DEFINED dashboard_loop)
  if(dashboard_continuous)
    set(dashboard_loop 43200)
  else()
    set(dashboard_loop 0)
  endif()
endif()

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()

set(dashboard_done 0)
while(NOT dashboard_done)
  if(dashboard_loop)
    set(START_TIME ${CTEST_ELAPSED_TIME})
  endif()
  set(ENV{HOME} "${dashboard_user_home}")

  # Start a new submission.
  if(COMMAND dashboard_hook_start)
    dashboard_hook_start()
  endif()
  ctest_start(${dashboard_model} TRACK ${TRACK_NAME})

  # Always build if the tree is fresh.
  set(dashboard_fresh 0)
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    set(dashboard_fresh 1)
    message("Starting fresh build...")
    write_cache()
  endif()

  # Look for updates.
  ctest_update(RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  message("Found ${count} changed files")

  if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)
    ctest_configure(OPTIONS "${CTEST_CONFIGURE_OPTIONS}")
    ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

    if(COMMAND dashboard_hook_build)
      dashboard_hook_build()
    endif()
    ctest_build()

    if(COMMAND dashboard_hook_test)
      dashboard_hook_test()
    endif()
    if(NOT DEFINED dashboard_do_test)
      set(dashboard_do_test TRUE)
    endif()
    if(dashboard_do_test)
      ctest_test(${CTEST_TEST_ARGS})
    endif(dashboard_do_test)
    set(safe_message_skip 1) # Block further messages

    if(dashboard_do_coverage)
      if(COMMAND dashboard_hook_coverage)
        dashboard_hook_coverage()
      endif()
      ctest_coverage()
    endif()
    if(dashboard_do_memcheck)
      if(COMMAND dashboard_hook_memcheck)
        dashboard_hook_memcheck()
      endif()
      ctest_memcheck()
    endif()
    if(COMMAND dashboard_hook_submit)
      dashboard_hook_submit()
    endif()
    if(NOT dashboard_no_submit)
      ctest_submit()
    endif()
    if(COMMAND dashboard_hook_end)
      dashboard_hook_end()
    endif()
  endif()

  if(dashboard_loop)
    # Delay until at least 5 minutes past START_TIME
    ctest_sleep(${START_TIME} 300 ${CTEST_ELAPSED_TIME})
    if(${CTEST_ELAPSED_TIME} GREATER ${dashboard_loop})
      set(dashboard_done 1)
    endif()
  else()
    # Not continuous, so we are done.
    set(dashboard_done 1)
  endif()
endwhile()
