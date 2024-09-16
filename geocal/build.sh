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

ln -s $SRC_DIR/cspice/lib/cspice.a $SRC_DIR/cspice/lib/libcspice.a
ln -s $SRC_DIR/cspice/lib/csupport.a $SRC_DIR/cspice/lib/libcsupport.a
mkdir geocal/build
cd geocal/build

# Suppress afids dependency, that only affects some python unit tests (and
# we build geocal before we build afids).
# Skip static libraries. They are large, and we don't actually use them anywhere
# Disable documentation, we'll have a separate build for just the documentation
# Also disable pynitf, we'll install that separately.
# Skip conda-install-support, this was put in when we were working on integrating
# in with vicar open source, which is currently on hold
#./configure --prefix="$PREFIX" --without-mspi-shared --without-afids --disable-static --without-documentation --with-conda-install-support
../configure --prefix="$PREFIX" --without-mspi-shared --without-afids --disable-static --without-documentation
make -j${CPU_COUNT} all
make install
rm -f "$PREFIX/lib/libgeocal.la"
#rm -f "$PREFIX/share/doc/afids/python/.doctrees/environment.pickle"
#rm -f "$PREFIX/share/doc/geocal/python/.doctrees/environment.pickle"

# Not sure if these should go here or not. run_test.sh actually runs in the
# built environment, so this isn't where we want this. For now, just put
# as part of the build. We may change over time.
make -j${CPU_COUNT} check VERBOSE=t
make -j${CPU_COUNT} installcheck

cp "$RECIPE_DIR"/geocal-post-link.sh "$PREFIX"/bin/.geocal-post-link.sh
cp "$RECIPE_DIR"/geocal-post-link.py "$PREFIX"/bin/.geocal-post-link.py

cat "$RECIPE_DIR"/extra_for_setup "$PREFIX"/setup_geocal.sh > "$PREFIX"/setup_geocal.sh.temp
mv -f "$PREFIX"/setup_geocal.sh.temp "$PREFIX"/setup_geocal.sh
cat "$RECIPE_DIR"/extra_for_setup "$PREFIX"/setup_geocal.csh > "$PREFIX"/setup_geocal.csh.temp
mv -f "$PREFIX"/setup_geocal.csh.temp "$PREFIX"/setup_geocal.csh


