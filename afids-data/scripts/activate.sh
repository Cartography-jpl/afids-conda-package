#!/bin/bash

# Store existing afids_data env vars and set to this conda env

if [[ -n "$AFIDS_DATA" ]]; then
    export _CONDA_SET_AFIDS_DATA=$AFIDS_DATA
fi

if [[ -n "$LANDSAT_ROOT" ]]; then
    export _CONDA_SET_LANDSAT_ROOT=$LANDSAT_ROOT
fi

if [[ -n "$ELEV_ROOT" ]]; then
    export _CONDA_SET_ELEV_ROOT=$ELEV_ROOT
fi

if [[ -n "$CIB1_ROOT" ]]; then
    export _CONDA_SET_CIB1_ROOT=$CIB1_ROOT
fi

if [[ -n "$CIB5_ROOT" ]]; then
    export _CONDA_SET_CIB5_ROOT=$CIB5_ROOT
fi

if [[ -n "$SPICEDATA" ]]; then
    export _CONDA_SET_SPICEDATA=$SPICEDATA
fi

if [[ -n "$MARS_KERNEL" ]]; then
    export _CONDA_SET_MARS_KERNEL=$MARS_KERNEL
fi

if [[ -n "$AFIDS_VDEV_DATA" ]]; then
    export _CONDA_SET_AFIDS_VDEV_DATA=$AFIDS_VDEV_DATA
fi

export AFIDS_DATA=${CONDA_PREFIX}/data
export LANDSAT_ROOT=${AFIDS_DATA}/landsat 
export ELEV_ROOT=${AFIDS_DATA}/srtmL2_filled 
export CIB1_ROOT=${AFIDS_DATA}/cib1 
export CIB5_ROOT=${AFIDS_DATA}/cib5
export SPICEDATA=${AFIDS_DATA}/cspice 
export MARS_KERNEL=${AFIDS_DATA}/mars_kernel
export AFIDS_VDEV_DATA=${AFIDS_DATA}/vdev
# Override ELEV_ROOT and SPICEDATA if supplied
if [[ -n "$AFIDS_DATA_ELEV_ROOT" ]]; then
    export ELEV_ROOT=$AFIDS_DATA_ELEV_ROOT
fi
if [[ -n "$AFIDS_DATA_SPICEDATA" ]]; then
    export SPICEDATA=$AFIDS_DATA_SPICEDATA
fi
    
