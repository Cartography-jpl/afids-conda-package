#!/bin/csh
# Restore previous GDAL env vars if they were set

unsetenv GDAL_DATA
if ($?_CONDA_SET_GDAL_DATA ) then
    setenv GDAL_DATA $_CONDA_SET_GDAL_DATA
    unsetenv _CONDA_SET_GDAL_DATA
endif

unsetenv GDAL_DRIVER_PATH
if ($?_CONDA_SET_GDAL_DRIVER_PATH ) then
    setenv GDAL_DRIVER_PATH $_CONDA_SET_GDAL_DRIVER_PATH
    unsetenv _CONDA_SET_GDAL_DRIVER_PATH
endif


#   vsizip does not work without this.
unset CPL_ZIP_ENCODING
