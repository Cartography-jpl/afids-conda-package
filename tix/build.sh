./configure --enable-threads --prefix="$PREFIX" --x-includes="$PREFIX/include" --x-libraries="$PREFIX/lib" --with-tcl="$PREFIX/lib/tkheader" --with-tk="$PREFIX/lib/tkheader" CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" CFLAGS="$CFLAGS -Wno-incompatible-pointer-types"
make -j${CPU_COUNT}
make install


