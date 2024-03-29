#
# FindTileDB_EP.cmake
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
# Finds the TileDB library, installing with an ExternalProject as necessary.

find_package(TileDB CONFIG QUIET)

if (TILEDB_FOUND)
  get_target_property(TILEDB_LIB TileDB::tiledb_static IMPORTED_LOCATION_RELEASE)
  message(STATUS "Found TileDB: ${TILEDB_LIB}")
else()
  if (SUPERBUILD)
    message(STATUS "Adding TileDB as an external project")

    # If TBB is being built as an external project, TileDB should only be built
    # after TBB.
    set(DEPENDS)
    if (TARGET ep_tbb)
      set(DEPENDS ep_tbb)
    endif()

    ExternalProject_Add(ep_tiledb
      PREFIX "externals"
      # TODO: change to 1.3.0 tag
      URL "https://github.com/TileDB-Inc/TileDB/archive/dev.zip"
      # URL_HASH SHA1=bccd93ad3cee39c3d08eee68d45b3e11910299f2
      DOWNLOAD_NAME "tiledb.zip"
      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${EP_INSTALL_PREFIX}
        -DCMAKE_PREFIX_PATH=${EP_INSTALL_PREFIX}
        -DTILEDB_STATIC=ON
      UPDATE_COMMAND ""
      INSTALL_COMMAND
        ${CMAKE_COMMAND} --build . --target install-tiledb
      LOG_DOWNLOAD TRUE
      LOG_CONFIGURE TRUE
      LOG_BUILD TRUE
      LOG_INSTALL TRUE
      DEPENDS ${DEPENDS}
    )
    list(APPEND EXTERNAL_PROJECTS ep_tiledb)
  else()
    message(FATAL_ERROR "Unable to find TileDB library.")
  endif()
endif()