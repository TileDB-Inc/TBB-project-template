#
# The following variables must be defined:
#   - TBB_SRC_DIR
#   - TBB_BUILD_DIR
#   - CMAKE_CXX_COMPILER_ID (not defined automatically when using cmake -P)
#   - CMAKE_SYSTEM_NAME (not defined automatically when using cmake -P)
#

set(TBB_BUILD_PREFIX "")
set(TBB_BUILD_CMAKE "${TBB_SRC_DIR}/cmake/TBBBuild.cmake")
set(TBB_MAKE_ARGS
  "tbb_build_dir=${TBB_BUILD_DIR}"
  "tbb_build_prefix=${TBB_BUILD_PREFIX}"
)

# Adding big_iron.inc specifies that TBB should be built as a static lib.
list(APPEND TBB_MAKE_ARGS "extra_inc=big_iron.inc")

if (EXISTS "${TBB_BUILD_CMAKE}")
  include(${TBB_BUILD_CMAKE})
  # Binaries are downloaded on Windows platforms.
  if (NOT WIN32)
    tbb_build(TBB_ROOT ${TBB_SRC_DIR}
      CONFIG_DIR TBB_DIR
      MAKE_ARGS ${TBB_MAKE_ARGS}
    )
  endif()
endif()