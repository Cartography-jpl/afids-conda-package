mkdir build
cd build
../configure --prefix="$PREFIX" FFLAGS="$FFLAGS -std=legacy"
make -j${CPU_COUNT} all
make install

