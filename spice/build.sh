# Download spice as so we can link to everything, but then delete it since
# we can't include in our package due to licensing constraints. The package get
# installed as a set of links of $PREFIX/cspice, and we then have a script for
# downloading the cspice package.
curl -L https://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z | tar -xz -C $PREFIX
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/bin
cd $PREFIX/include
ln -s ../cspice/include/Spice*.h .
cd $PREFIX/bin
ln -s ../cspice/exe/* .
cd $PREFIX/lib
ln -s ../cspice/lib/* .
ln -s ../lib/cspice.a libcspice.a
ln -s ../lib/csupport.a libcsupport.a
rm -r $PREFIX/cspice
cp "$RECIPE_DIR"/spice-pre-link.sh "$PREFIX"/bin/.spice-pre-link.sh
cp "$RECIPE_DIR"/spice-pre-unlink.sh "$PREFIX"/bin/.spice-pre-unlink.sh


