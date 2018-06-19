#
# Superbuild.cmake
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

include (ExternalProject)

############################################################
# Common variables
############################################################

# Variable that will hold a list of all the external projects added
# as a part of the superbuild.
set(EXTERNAL_PROJECTS)

# Forward any additional CMake args to the non-superbuild.
set(INHERITED_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
  -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
)

############################################################
# Set up external projects for dependencies
############################################################

# These includes modify the EXTERNAL_PROJECTS variable.

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindTBB_EP.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/FindTileDB_EP.cmake)

############################################################
# Set up the regular build (i.e. non-superbuild).
############################################################

ExternalProject_Add(main
  SOURCE_DIR ${PROJECT_SOURCE_DIR}
  CMAKE_ARGS
    -DSUPERBUILD=OFF
  ${INHERITED_CMAKE_ARGS}
  INSTALL_COMMAND ""
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/main
  DEPENDS ${EXTERNAL_PROJECTS}
)

