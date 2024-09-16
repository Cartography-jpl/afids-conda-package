cp -r tk* tcl* $PREFIX/lib
sed -i "s#REPLACE_ME#$PREFIX/lib#g" $PREFIX/lib/tkheader/tclConfig.sh
sed -i "s#REPLACE_ME#$PREFIX/lib#g" $PREFIX/lib/tkheader/tkConfig.sh
sed -i "s#VERSION#${PKG_VERSION}#g" $PREFIX/lib/tkheader/tclConfig.sh
sed -i "s#VERSION#${PKG_VERSION}#g" $PREFIX/lib/tkheader/tkConfig.sh
