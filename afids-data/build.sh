./configure --prefix="$PREFIX"
make
make install
mkdir -p "$PREFIX"/bin/
cp "$RECIPE_DIR"/afids-data-post-link.sh "$PREFIX"/bin/.afids-data-post-link.sh
cp "$RECIPE_DIR"/afids-data-post-link.py "$PREFIX"/bin/.afids-data-post-link.py
cp "$RECIPE_DIR"/readme_for_install "$PREFIX"/data/README
cat "$RECIPE_DIR"/extra_for_setup "$PREFIX"/data/setup_afids_data.sh > "$PREFIX"/data/setup_afids_data.sh.temp
mv -f "$PREFIX"/data/setup_afids_data.sh.temp "$PREFIX"/data/setup_afids_data.sh
cat "$RECIPE_DIR"/extra_for_setup "$PREFIX"/data/setup_afids_data.csh > "$PREFIX"/data/setup_afids_data.csh.temp
mv -f "$PREFIX"/data/setup_afids_data.csh.temp "$PREFIX"/data/setup_afids_data.csh
# The symbolic links to external files seems to confuse conda, so replace
# with dummy directories
rm "$PREFIX"/data/adrg
rm "$PREFIX"/data/cib1
rm "$PREFIX"/data/cib5
rm "$PREFIX"/data/landsat
rm "$PREFIX"/data/mars_kernel
rm "$PREFIX"/data/srtmL1_filled
rm "$PREFIX"/data/srtmL2_filled
rm "$PREFIX"/data/vmap1
rm "$PREFIX"/data/vdev/port_gaston_doq.img
rm "$PREFIX"/data/vdev/port_gaston_elv.hlf
rm "$PREFIX"/data/pommosdata/planet_dem
rm "$PREFIX"/data/pommosdata/testcases

# Think we want to handle this with the postlink step instead
#ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
#DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
#mkdir -p $ACTIVATE_DIR
#mkdir -p $DEACTIVATE_DIR

#cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/afids-data-activate.sh
#cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/afids-data-deactivate.sh
#cp $RECIPE_DIR/scripts/activate.csh $ACTIVATE_DIR/afids-data-activate.csh
#cp $RECIPE_DIR/scripts/deactivate.csh $DEACTIVATE_DIR/afids-data-deactivate.csh




