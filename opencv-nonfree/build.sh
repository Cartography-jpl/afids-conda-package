# Conda is in the middle of removing .la files from libtool (see
# https://github.com/conda-forge/staged-recipes/issues/673). But right
# now a lot of these are still around, and they can be inconsistent.
# In particular some of the motif stuff points to libXext.la, which isn't
# installed anymore. In any case, remove all the la files before we try
# building, so it doesn't mangle things. Ok if nothing to remove, so we
# ignore the exit status of rm.
rm -f $PREFIX/lib/*.la || true

if [ `uname` = 'Linux' ]; then
   export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

cmake opencv -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GTK=OFF -DWITH_PARALLEL_PF=OFF -DWITH_V4L=OFF -DWITH_IPP=OFF -DBUILD_TESTS=OFF -DOPENCV_EXTRA_MODULES_PATH=opencv_contrib/modules -DOPENCV_ENABLE_NONFREE=ON -DLAPACK_LIBRARIES="-L${PREFIX}/lib -llapack -lcblas -lblas" -DWITH_LAPACK=ON -DBUILD_PERF_TESTS=OFF
make -j${CPU_COUNT}
make install



