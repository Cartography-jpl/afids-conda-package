# Conda is in the middle of removing .la files from libtool (see
# https://github.com/conda-forge/staged-recipes/issues/673). But right
# now a lot of these are still around, and they can be inconsistent.
# In particular some of the motif stuff points to libXext.la, which isn't
# installed anymore. In any case, remove all the la files before we try
# building, so it doesn't mangle things. Ok if nothing to remove, so we
# ignore the exit status of rm.
rm -f $PREFIX/lib/*.la || true

./configure --prefix=$PREFIX --sysconfdir=$PREFIX/etc

make -j$CPU_COUNT
make install

# Remove any new Libtool files we may have installed. It is intended that
# conda-build will eventually do this automatically.
rm -f $PREFIX/lib/*.la || true
