#!/bin/bash
# Restore previous afids_data env vars if they were set

unset AFIDS_DATA
if [[ -n "$_CONDA_SET_AFIDS_DATA" ]]; then
    export AFIDS_DATA=$_CONDA_SET_AFIDS_DATA
    unset _CONDA_SET_AFIDS_DATA
fi

unset SPICEDATA
if [[ -n "$_CONDA_SET_SPICEDATA" ]]; then
    export SPICEDATA=$_CONDA_SET_SPICEDATA
    unset _CONDA_SET_SPICEDATA
fi

unset AFIDS_VDEV_DATA
if [[ -n "$_CONDA_SET_AFIDS_VDEV_DATA" ]]; then
    export AFIDS_VDEV_DATA=$_CONDA_SET_AFIDS_VDEV_DATA
    unset _CONDA_SET_AFIDS_VDEV_DATA
fi
