./configure --prefix="$PREFIX" --with-tcl="$PREFIX/lib/tkheader" --with-tclinclude="$PREFIX/include" --disable-rpath
# For some odd reason, this decides we are on a windows system. Not sure why,
# but we just back out the windows part
sed -i "s#dllEntryPoint.[co]##g" Makefile
# Also, looks for the .a file in the wrong place, so copy to where
# it is looking for this.
cp $PREFIX/lib/libtclstub*.a $PREFIX/lib/tkheader
make -j${CPU_COUNT}
make INSTALL=install install


