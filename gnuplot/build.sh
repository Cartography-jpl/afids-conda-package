#!/bin/bash

#export CXXFLAGS="$CXXFLAGS -std=c++11"

#if [ "$(uname)" == "Linux" ]
#then
#	export LDFLAGS="$LDFLAGS -L $PREFIX/lib -liconv"
#fi

./configure \
	--prefix=$PREFIX \
	--with-readline=$PREFIX \
	--without-tutorial \
	--disable-wxwidgets \
	--without-list-files \
	--with-gd=$PREFIX \
	--x-includes=$PREFIX/include \
	--x-libraries=$PREFIX/lib \
        --without-qt \
        LIBS="-L$PREFIX/lib -liconv"

make -j${CPU_COUNT} all
make install
