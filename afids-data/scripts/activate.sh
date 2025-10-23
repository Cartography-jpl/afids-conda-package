#!/bin/bash

# Store existing afids_data env vars and set to this conda env

if [[ -n "$AFIDS_DATA" ]]; then
    export _CONDA_SET_AFIDS_DATA=$AFIDS_DATA
fi

if [[ -n "$AFIDS_VDEV_DATA" ]]; then
    export _CONDA_SET_AFIDS_VDEV_DATA=$AFIDS_VDEV_DATA
fi

if [[ -n "$SPICEDATA" ]]; then
    export _CONDA_SET_SPICEDATA=$SPICEDATA
fi

export AFIDS_DATA=${CONDA_PREFIX}/data
export AFIDS_VDEV_DATA=${AFIDS_DATA}/vdev
export SPICEDATA=${AFIDS_DATA}/cspice 
# We don't set these anymore. Instead, these should get set at the
# environment level since they usually point outside. The one possible
# exception is SPICEDATA, which is sometimes pointed outside, and sometimes
# internal
#export LANDSAT_ROOT=${AFIDS_DATA}/landsat 
#export ELEV_ROOT=${AFIDS_DATA}/srtmL2_filled 
#export CIB1_ROOT=${AFIDS_DATA}/cib1 
#export CIB5_ROOT=${AFIDS_DATA}/cib5
#export MARS_KERNEL=${AFIDS_DATA}/mars_kernel
# Override SPICEDATA if supplied
if [[ -n "$AFIDS_DATA_SPICEDATA" ]]; then
    export SPICEDATA=$AFIDS_DATA_SPICEDATA
fi
    
