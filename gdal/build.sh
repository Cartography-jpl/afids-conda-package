#!/bin/bash

set -ex # Abort on error.

# recommended in https://gitter.im/conda-forge/conda-forge.github.io?at=5c40da7f95e17b45256960ce
find ${PREFIX}/lib -name '*.la' -delete

# Force python bindings to not be built.
unset PYTHON

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# See https://github.com/AnacondaRecipes/aggregate/pull/103
# PG causes problems with mac build, so we just drop it for the mac.
if [[ $target_platform =~ linux.* ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
  mkdir -p ${PREFIX}/include/linux
  cp ${RECIPE_DIR}/userfaultfd.h ${PREFIX}/include/linux/userfaultfd.h
  CONFIG_OPTIONS="--with-pg=yes"
else  
  CONFIG_OPTIONS=""
fi

# `--without-pam` was removed.
# See https://github.com/conda-forge/gdal-feedstock/pull/47 for the discussion.

# Currently poppler package conflicts with others. Turn off for now.
# Tiledb doesn't work (compile failure), so just turn off
bash configure --prefix=${PREFIX} \
               --host=${HOST} \
               --with-curl \
               --with-dods-root=no \
               --with-expat=${PREFIX} \
               --without-freexl \
               --with-geos=${PREFIX}/bin/geos-config \
               --with-geotiff=${PREFIX} \
               --with-hdf4=${PREFIX} \
               --with-cfitsio=${PREFIX} \
               --with-hdf5=${PREFIX} \
               --without-tiledb \
               --with-jpeg=${PREFIX} \
               --without-kea \
               --with-libiconv-prefix=${PREFIX} \
               --with-libjson-c=internal \
               --with-libkml=${PREFIX} \
               --with-liblzma=yes \
               --with-libtiff=${PREFIX} \
               --with-libz=${PREFIX} \
               --without-netcdf  \
               --with-openjpeg=${PREFIX} \
               --with-pcre \
               --with-png=${PREFIX} \
               --without-poppler \
               --with-spatialite=${PREFIX} \
               --with-sqlite3=${PREFIX} \
               --with-proj=${PREFIX} \
               --with-webp=${PREFIX} \
               --with-xerces=${PREFIX} \
               --with-xml2=yes \
               --with-zstd=${PREFIX} \
               --without-python \
               --disable-static \
	       $(CONFIG_OPTIONS) --verbose \
               ${OPTS}

make -j $CPU_COUNT ${VERBOSE_AT}

if [[ $target_platform =~ linux.* ]]; then
  rm ${PREFIX}/include/linux/userfaultfd.h
fi
