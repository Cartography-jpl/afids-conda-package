# The spice kernel needs to have the full path set in the kernel file,
# but with the condition that the directory path needs to be split up if
# it is greater than 80 characters. No easy way for the included conda
# moving build to install directory script to work with this, so we have
# a separate post install step.
#
# Actual work is done by a python script, but conda requires us to have
# a bash script. So we just forward to python

/usr/bin/env python $CONDA_PREFIX/bin/.afids-data-post-link.py
