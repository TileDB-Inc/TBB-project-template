#
# FindTBB_EP.cmake
#
#
# The MIT License
#
# Copyright (c) 2018 TileDB, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Finds the Intel TBB library, installing with an ExternalProject as necessary.
# This module defines:
#   - TBB_FOUND, whether TBB has been found
#   - TBB_LIB_DIR, the directory in the build tree with the TBB libraries
#   - The TBB::tbb imported target
#
# Note: Currently, TBB's CMake integration does not support the usual pattern
# of ExternalProject, so there are a few customized steps here to support it.

############################################################
# Helper functions specific to TBB
############################################################

#
# Search and manually create a TBB::tbb target if possible.
#
function(backup_find_tbb)
  # Also search the TBB EP build tree for the include and library.
  set(TBB_EXTRA_SEARCH_PATHS
    ${TBB_SRC_DIR}
    ${TBB_BUILD_DIR}/${TBB_BUILD_PREFIX}_release
  )

  if (NOT WIN32)
    find_path(TBB_INCLUDE_DIR
      NAMES tbb/tbb.h
      PATHS ${TBB_EXTRA_SEARCH_PATHS}
      PATH_SUFFIXES include
    )

    find_library(TBB_LIBRARIES
      NAMES
        tbb
        ${CMAKE_STATIC_LIBRARY_PREFIX}tbb${CMAKE_STATIC_LIBRARY_SUFFIX}
      PATHS ${TBB_EXTRA_SEARCH_PATHS}
      PATH_SUFFIXES lib
    )

    include(FindPackageHandleStandardArgs)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(TBB
      REQUIRED_VARS TBB_LIBRARIES TBB_INCLUDE_DIR
    )

    if (TBB_FOUND AND NOT TARGET TBB::tbb)
      add_library(TBB::tbb SHARED IMPORTED)
      set_target_properties(TBB::tbb PROPERTIES
        IMPORTED_LOCATION_RELEASE "${TBB_LIBRARIES}"
        IMPORTED_LOCATION_DEBUG "${TBB_LIBRARIES}"
        INTERFACE_INCLUDE_DIRECTORIES "${TBB_INCLUDE_DIR}"
      )
      set(TBB_IMPORTED_TARGETS TBB::tbb PARENT_SCOPE)
    endif()
  endif()
endfunction()

############################################################
# Regular superbuild EP setup.
############################################################

find_package(TBB CONFIG QUIET)

# The TBB find_package() support is pretty spotty, and can fail e.g. with
# Homebrew installed versions. Try a backup method here.
if (NOT TARGET TBB::tbb)
  backup_find_tbb()
endif()

if (TARGET TBB::tbb)
  message(STATUS "Found TBB imported target: ${TBB_IMPORTED_TARGETS}")
  set(TBB_FOUND TRUE)
else()
  if (SUPERBUILD)
    message(STATUS "Adding TBB as an external project")

    set(TBB_SRC_DIR "${EP_BASE}/src/ep_tbb")
    set(TBB_BUILD_DIR "${EP_BASE}/src/ep_tbb-build")

    if (WIN32)
      # On Windows we download pre-built binaries.
      # TODO: install step here (copying files) is incomplete.
      ExternalProject_Add(ep_tbb
        PREFIX "externals"
        URL "https://github.com/01org/tbb/releases/download/2018_U3/tbb2018_20180312oss_win.zip"
        URL_HASH SHA1=7f0b4b227679637f7a4065b0377d55d12fac983b
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND
          ${CMAKE_COMMAND}
            -DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
            -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
            -DTBB_SRC_DIR=${TBB_SRC_DIR}
            -DTBB_BUILD_DIR=${TBB_BUILD_DIR}
            -P ${PROJECT_SOURCE_DIR}/cmake/Modules/BuildTBB.cmake
        INSTALL_COMMAND ""
        LOG_DOWNLOAD TRUE
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
      )
    else()
      include(GNUInstallDirs)
      set(LIB_DEST_DIR "${EP_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
      set(INC_DEST_DIR "${EP_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")
      set(TBB_LIB_NAME
        "${CMAKE_STATIC_LIBRARY_PREFIX}tbb${CMAKE_STATIC_LIBRARY_SUFFIX}")

      ExternalProject_Add(ep_tbb
        PREFIX "externals"
        URL "https://github.com/01org/tbb/archive/2018_U3.zip"
        URL_HASH SHA1=c17ae26f2be1dd7ca9586f795d07a226ceca2dc2
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND
          ${CMAKE_COMMAND}
            -DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
            -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
            -DTBB_SRC_DIR=${TBB_SRC_DIR}
            -DTBB_BUILD_DIR=${TBB_BUILD_DIR}
            -P ${PROJECT_SOURCE_DIR}/cmake/Modules/BuildTBB.cmake
        INSTALL_COMMAND
          ${CMAKE_COMMAND} -E make_directory
            ${EP_INSTALL_PREFIX}
            ${LIB_DEST_DIR}
            ${INC_DEST_DIR}
          COMMAND
          ${CMAKE_COMMAND} -E copy_if_different
            ${TBB_BUILD_DIR}/_release/${TBB_LIB_NAME}
            ${LIB_DEST_DIR}
          COMMAND
          ${CMAKE_COMMAND} -E copy_directory
            ${TBB_SRC_DIR}/include
            ${INC_DEST_DIR}
        LOG_DOWNLOAD TRUE
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
      )
    endif()

    list(APPEND EXTERNAL_PROJECTS ep_tbb)
  else()
    message(FATAL_ERROR "Unable to find TBB")
  endif()
endif()