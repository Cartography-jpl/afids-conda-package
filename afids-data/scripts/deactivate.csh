#!/bin/csh
# Restore previous afids_data env vars if they were set

unsetenv AFIDS_DATA
if ($?_CONDA_SET_AFIDS_DATA) then
    setenv AFIDS_DATA $_CONDA_SET_AFIDS_DATA
    unsetenv _CONDA_SET_AFIDS_DATA
endif

unsetenv LANDSAT_ROOT
if ($?_CONDA_SET_LANDSAT_ROOT) then
    setenv LANDSAT_ROOT $_CONDA_SET_LANDSAT_ROOT
    unsetenv _CONDA_SET_LANDSAT_ROOT
endif

unsetenv ELEV_ROOT
if ($?_CONDA_SET_ELEV_ROOT) then
    setenv ELEV_ROOT $_CONDA_SET_ELEV_ROOT
    unsetenv _CONDA_SET_ELEV_ROOT
endif

unsetenv CIB1_ROOT
if ($?_CONDA_SET_CIB1_ROOT) then
    setenv CIB1_ROOT $_CONDA_SET_CIB1_ROOT
    unsetenv _CONDA_SET_CIB1_ROOT
endif

unsetenv CIB5_ROOT
if ($?_CONDA_SET_CIB5_ROOT) then
    setenv CIB5_ROOT $_CONDA_SET_CIB5_ROOT
    unsetenv _CONDA_SET_CIB5_ROOT
endif

unsetenv SPICEDATA
if ($?_CONDA_SET_SPICEDATA) then
    setenv SPICEDATA $_CONDA_SET_SPICEDATA
    unsetenv _CONDA_SET_SPICEDATA
endif

unsetenv MARS_KERNEL
if ($?_CONDA_SET_MARS_KERNEL) then
    setenv MARS_KERNEL $_CONDA_SET_MARS_KERNEL
    unsetenv _CONDA_SET_MARS_KERNEL
endif

unsetenv AFIDS_VDEV_DATA
if ($?_CONDA_SET_AFIDS_VDEV_DATA) then
    setenv AFIDS_VDEV_DATA $_CONDA_SET_AFIDS_VDEV_DATA
    unsetenv _CONDA_SET_AFIDS_VDEV_DATA
endif
