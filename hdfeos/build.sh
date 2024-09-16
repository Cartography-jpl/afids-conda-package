# Conda is in the middle of removing .la files from libtool (see
# https://github.com/conda-forge/staged-recipes/issues/673). But right
# now a lot of these are still around, and they can be inconsistent.
# In particular some of the motif stuff points to libXext.la, which isn't
# installed anymore. In any case, remove all the la files before we try
# building, so it doesn't mangle things. Ok if nothing to remove, so we
# ignore the exit status of rm.
rm -f $PREFIX/lib/*.la || true

./configure --prefix="$PREFIX" --disable-hdfeos5
make -j${CPU_COUNT} all
make install
rm -f "$PREFIX/lib/libhdfeos.la"
rm -f "$PREFIX/lib/libGctp.la"
rm -f "$PREFIX/lib/libhe5_hdfeos.la"



