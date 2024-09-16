#!/bin/csh

# Store existing afids_data env vars and set to this conda env

if ($?AFIDS_DATA) then
    setenv _CONDA_SET_AFIDS_DATA $AFIDS_DATA
endif

if ($?LANDSAT_ROOT) then
    setenv _CONDA_SET_LANDSAT_ROOT $LANDSAT_ROOT
endif

if ($?ELEV_ROOT) then
    setenv _CONDA_SET_ELEV_ROOT $ELEV_ROOT
endif

if ($?CIB1_ROOT) then
    setenv _CONDA_SET_CIB1_ROOT $CIB1_ROOT
endif

if ($?CIB5_ROOT) then
    setenv _CONDA_SET_CIB5_ROOT $CIB5_ROOT
endif

if ($?SPICEDATA) then
    setenv _CONDA_SET_SPICEDATA $SPICEDATA
endif

if ($?MARS_KERNEL) then
    setenv _CONDA_SET_MARS_KERNEL $MARS_KERNEL
endif

if ($?AFIDS_VDEV_DATA) then
    setenv _CONDA_SET_AFIDS_VDEV_DATA $AFIDS_VDEV_DATA
endif

setenv AFIDS_DATA ${CONDA_PREFIX}/data
setenv LANDSAT_ROOT ${AFIDS_DATA}/landsat 
setenv ELEV_ROOT ${AFIDS_DATA}/srtmL2_filled 
setenv CIB1_ROOT ${AFIDS_DATA}/cib1 
setenv CIB5_ROOT ${AFIDS_DATA}/cib5
setenv SPICEDATA ${AFIDS_DATA}/cspice 
setenv MARS_KERNEL ${AFIDS_DATA}/mars_kernel
setenv AFIDS_VDEV_DATA ${AFIDS_DATA}/vdev

# Override ELEV_ROOT and SPICEDATA if supplied
if ($?AFIDS_DATA_ELEV_ROOT) then
    setenv ELEV_ROOT $AFIDS_DATA_ELEV_ROOT
endif
if ($?AFIDS_DATA_SPICEDATA) then
    setenv SPICEDATA $AFIDS_DATA_SPICEDATA
endif
