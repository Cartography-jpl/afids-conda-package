# Conda is in the middle of removing .la files from libtool (see
# https://github.com/conda-forge/staged-recipes/issues/673). But right
# now a lot of these are still around, and they can be inconsistent.
# In particular some of the motif stuff points to libXext.la, which isn't
# installed anymore. In any case, remove all the la files before we try
# building, so it doesn't mangle things. Ok if nothing to remove, so we
# ignore the exit status of rm.
rm -f $PREFIX/lib/*.la || true
ln -s $SRC_DIR/cspice/lib/cspice.a $SRC_DIR/cspice/lib/libcspice.a
ln -s $SRC_DIR/cspice/lib/csupport.a $SRC_DIR/cspice/lib/libcsupport.a
mkdir afids/build
cd afids/build
../configure --prefix="$PREFIX" --without-gdal --with-spice=$SRC_DIR/cspice
make -j${CPU_COUNT} all
make install

mkdir -p "$PREFIX"/bin/
# I think this can go away, and we just use the normal activate/deactivate
# scripts
#cp "$RECIPE_DIR"/afids-post-link.sh "$PREFIX"/bin/.afids-post-link.sh

ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR
cp $RECIPE_DIR/afids-activate.sh $ACTIVATE_DIR/afids-activate.sh
cp $RECIPE_DIR/afids-deactivate.sh $DEACTIVATE_DIR/afids-deactivate.sh
cp $RECIPE_DIR/afids-activate.csh $ACTIVATE_DIR/afids-activate.csh
cp $RECIPE_DIR/afids-deactivate.csh $DEACTIVATE_DIR/afids-deactivate.csh
rm "$PREFIX"/setup_afids_env.sh
rm "$PREFIX"/setup_afids_env.csh
echo "conda_prefix=$PREFIX" > "$PREFIX"/setup_afids_env.sh
cat "$RECIPE_DIR"/setup_afids_env.sh >> "$PREFIX"/setup_afids_env.sh
echo "setenv conda_prefix $PREFIX" > "$PREFIX"/setup_afids_env.csh
cat "$RECIPE_DIR"/setup_afids_env.csh >> "$PREFIX"/setup_afids_env.csh

