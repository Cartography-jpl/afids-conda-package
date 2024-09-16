# Download the actual JPL spice library. We can't redistribute this ourselves
# because of license restrictions, but we can download from the NAIF site
curl -L https://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z | tar -xz -C $PREFIX
