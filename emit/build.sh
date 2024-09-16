# Conda is in the middle of removing .la files from libtool (see
# https://github.com/conda-forge/staged-recipes/issues/673). But right
# now a lot of these are still around, and they can be inconsistent.
# In particular some of the motif stuff points to libXext.la, which isn't
# installed anymore. In any case, remove all the la files before we try
# building, so it doesn't mangle things. Ok if nothing to remove, so we
# ignore the exit status of rm.
rm -f $PREFIX/lib/*.la || true

# Note that LDFLAGS will include dead_strip_dylibs on osx. This causes
# a problem with running because GSL does lazy binding of blas stuff, and
# conda will wrongly cause this to be stripped out.
LDFLAGS="$(echo $LDFLAGS | sed s/-Wl,-dead_strip_dylibs//)"

./configure --prefix="$PREFIX"
make -j${CPU_COUNT} all
make install
rm -f "$PREFIX/lib/libemit.la"



