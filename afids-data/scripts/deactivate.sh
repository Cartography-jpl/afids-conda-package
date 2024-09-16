#!/bin/bash
# Restore previous afids_data env vars if they were set

unset AFIDS_DATA
if [[ -n "$_CONDA_SET_AFIDS_DATA" ]]; then
    export AFIDS_DATA=$_CONDA_SET_AFIDS_DATA
    unset _CONDA_SET_AFIDS_DATA
fi

unset LANDSAT_ROOT
if [[ -n "$_CONDA_SET_LANDSAT_ROOT" ]]; then
    export LANDSAT_ROOT=$_CONDA_SET_LANDSAT_ROOT
    unset _CONDA_SET_LANDSAT_ROOT
fi

unset ELEV_ROOT
if [[ -n "$_CONDA_SET_ELEV_ROOT" ]]; then
    export ELEV_ROOT=$_CONDA_SET_ELEV_ROOT
    unset _CONDA_SET_ELEV_ROOT
fi

unset CIB1_ROOT
if [[ -n "$_CONDA_SET_CIB1_ROOT" ]]; then
    export CIB1_ROOT=$_CONDA_SET_CIB1_ROOT
    unset _CONDA_SET_CIB1_ROOT
fi

unset CIB5_ROOT
if [[ -n "$_CONDA_SET_CIB5_ROOT" ]]; then
    export CIB5_ROOT=$_CONDA_SET_CIB5_ROOT
    unset _CONDA_SET_CIB5_ROOT
fi

unset SPICEDATA
if [[ -n "$_CONDA_SET_SPICEDATA" ]]; then
    export SPICEDATA=$_CONDA_SET_SPICEDATA
    unset _CONDA_SET_SPICEDATA
fi

unset MARS_KERNEL
if [[ -n "$_CONDA_SET_MARS_KERNEL" ]]; then
    export MARS_KERNEL=$_CONDA_SET_MARS_KERNEL
    unset _CONDA_SET_MARS_KERNEL
fi

unset AFIDS_VDEV_DATA
if [[ -n "$_CONDA_SET_AFIDS_VDEV_DATA" ]]; then
    export AFIDS_VDEV_DATA=$_CONDA_SET_AFIDS_VDEV_DATA
    unset _CONDA_SET_AFIDS_VDEV_DATA
fi
