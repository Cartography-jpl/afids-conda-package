#!/bin/csh

# Store existing GDAL env vars and set to this conda env
# so other GDAL installs don't pollute the environment

if ($?GDAL_DATA) then
    setenv _CONDA_SET_GDAL_DATA $GDAL_DATA
endif

if ($?GDAL_DRIVER_PATH) then
    setenv _CONDA_SET_GDAL_DRIVER_PATH $GDAL_DRIVER_PATH
endif

# On Linux GDAL_DATA is in $CONDA_PREFIX/share/gdal, but
# Windows keeps it in $CONDA_PREFIX/Library/share/gdal
if(-e $CONDA_PREFIX/share/gdal ) then
    setenv GDAL_DATA $CONDA_PREFIX/share/gdal
    setenv GDAL_DRIVER_PATH $CONDA_PREFIX/lib/gdalplugins
else
    setenv GDAL_DATA $CONDA_PREFIX/Library/share/gdal
    setenv GDAL_DRIVER_PATH $CONDA_PREFIX/Library/lib/gdalplugins
endif


# Support plugins if the plugin directory exists
# i.e if it has been manually created by the user
if (! -e $GDAL_DRIVER_PATH ) then
    unsetenv GDAL_DRIVER_PATH
endif

# vsizip does not work without this.
setenv CPL_ZIP_ENCODING UTF-8
