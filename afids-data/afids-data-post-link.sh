# The spice kernel needs to have the full path set in the kernel file,
# but with the condition that the directory path needs to be split up if
# it is greater than 80 characters. No easy way for the included conda
# moving build to install directory script to work with this, so we have
# a separate post install step.
#
# Actual work is done by a python script, but conda requires us to have
# a bash script. So we just forward to python

/usr/bin/env python $PREFIX/bin/.afids-data-post-link.py
# Not 100% sure setting these variables in the post link step is correct.
# But we want to make sure the users set these values, so we have this
# here.
conda env config vars set AFIDS_DATA=$PREFIX/data LANDSAT_ROOT=need_to_set ELEV_ROOT=need_to_set CIB1_ROOT=need_to_set CIB5_ROOT=need_to_set AFIDS_VDEV_DATA=$PREFIX/data/vdev SPICEDATA=$PREFIX/data/cspice
