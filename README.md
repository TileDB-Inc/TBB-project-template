# TileDB + TBB Project Template

This repository contains a template CMake project that includes both TileDB and TBB as CMake ExternalProjects.

The main target of this project builds a sample executable that statically links with both TBB and TileDB to produce a single binary. Both the resulting executable and the TileDB library are linked to the same TBB runtime. TileDB can then use TBB for internal parallelism, and the example executable can use the same TBB for its own parallelism.

Normally TileDB itself is distributed as a shared library that has been statically linked with TBB. This can be problematic when using TileDB from a project where you also wish to use TBB. While there is an option to build TileDB with shared linkage against TBB, it's often desirable to produce a single binary instead of multiple. Therefore, this project template produces a single executable statically linked with both TBB and TileDB.

## Build

```
$ mkdir build
$ cd build
$ cmake ..
$ make -j4
```

## Run

```
$ cd main
$ ./main
```
