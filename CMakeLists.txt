#
# CMakeLists.txt
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

############################################################
# CMake setup
############################################################

cmake_minimum_required(VERSION 2.8)

# Superbuild option must be on by default.
option(SUPERBUILD "If true, perform a superbuild (builds all missing dependencies)." ON)

# Set C++11 as required standard for all C++ targets (required to use the TileDB
# C++ API).
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

############################################################
# Superbuild setup
############################################################

# Build paths for external projects
set(EP_BASE "${CMAKE_CURRENT_BINARY_DIR}/externals")
set(EP_SOURCE_DIR "${EP_BASE}/src")
set(EP_INSTALL_PREFIX "${EP_BASE}/install")

# Search the externals install directory for dependencies.
list(APPEND CMAKE_PREFIX_PATH "${EP_INSTALL_PREFIX}")

if (SUPERBUILD)
  project(TileDBExampleProj-Superbuild)
  message(STATUS "Starting superbuild.")
  include("cmake/Superbuild.cmake")
  # Stop processing this file here.
  return()
endif()

############################################################
# Regular build
############################################################

project(TileDBExampleProj)
message(STATUS "Starting regular build.")

# Find TileDB.
#
# If TileDB is not installed globally on your system, either set
# CMAKE_PREFIX_PATH on the CMake command line:
#   $ cmake -DCMAKE_PREFIX_PATH=/path/to/TileDB-installation ..
# or you can hardcode it here e.g.
#   list(APPEND CMAKE_PREFIX_PATH "/path/to/TileDB-installation")
find_package(TileDB REQUIRED)

# Set up the example program.
add_executable(main "src/main.cc")

# Link the example program with the TileDB shared library.
# This also configures include paths to find the TileDB headers.
target_link_libraries(main PRIVATE TileDB::tiledb_static)
