./configure --prefix="$PREFIX"
make -j${CPU_COUNT} all
make install
rm -f "$PREFIX/lib/libvicar_rtl.la"
