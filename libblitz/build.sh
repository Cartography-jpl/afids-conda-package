./configure --prefix="$PREFIX" --enable-shared --disable-doxygen
# Make want to generate stencil-classes.cc, but depends on python 2.
# Rather than do something complicated to patch this, just manually install
# the generated file. It doesn't change.
cp $RECIPE_DIR/files/stencil-classes.cc blitz/array
make
make install
rm -f "$PREFIX/lib/pkgconfig/blitz-uninstalled.pc"
rm -f "$PREFIX/lib/libblitz.la"

