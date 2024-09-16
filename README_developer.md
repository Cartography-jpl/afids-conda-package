# For Developers

## Build help

We have a top level Makefile that can be used to build all the packages.

## Docker instance

We have had problems when building packages of having them pull out libraries
that happen to be on the system we were building. GDAL was particulary bad 
about this, grabbing various system jpeg etc libraries. To give a cleaner
package creation environment, we use a docker instance to isolate the system.
This is just a oraclelinux 8 system with miniforge installed, but it prevents 
anything not on a base oraclelinux 8 system from being used.

## Channels

We use to the conda-forge channel.

# General directions
## Dependencies

Conda does a pretty good job of tracking all the dependencies for python
packages. It has support for tracking other types of packages, but it has
the standard "dependency hell" problem. It is very common to depend on
package A and B, where A -> C and B -> C' (C and C' different versions).
It also has the common problem of package managers of not really tracking
all the dependencies correctly, so it may install A and B but not realize
they are inconstistent.

The big pieces we depend on which can conflict are gdal, matplotlib,
xorg-libxft and tk. If you have a consistent environment with all of these,
then afids should be fine.

Gdal depends on a large number of packages, so it causing a problem makes
sense. For matplotlib, xorg-libxft, and tk we have matplotlib using both tk
and freetype. xorg-libxft uses freetype, and there is only one building which
currently use 2.7. The 2.7 version of freetype is always used with tk 8.5 for
matplotlib, which ties them together. So:

   matplotlib  -> freetype
               -> tk
   xorg-libxft -> freetype

To help with this, we have an Manifest_linux.yml which gives a consistent
set of packages that can be installed for afids.

If you just directly install the afids package into a conda environment,
you may or may not get a consistent environment.

You can install using:

    mamba env create -f Manifest_linux.yml -n my_afids_env

This assumes you have afids-conda-channel added permantly as described below.
Without this, you need to add 

   mamba env create -f Manifest_linux.yml -n my_afids_env --channel file://<top_dir>/afids-conda-channel
   
## Building packages

You only need to build packages if you are in an environment that the prebuilt
packages don't support (e.g., different version of python), or if you have
modified something.

There is a src directory where tar files can be placed if desired, which can
then be used to do a conda build.

Building is just

    conda mambabuild --output-folder afids-conda-channel/ -m conda_build_config.yaml ptpython
	
(or whatever your package list is). You can then install with

    mamba install -c afids-conda-channel ptipython
	
Note that you can create a local channel, in its own directory if you like

    conda index <local_dir>
	
This is already run by conda-build, but it can be useful to know how to run
directly also.

## Creating recipes

We created the recipes by:

    conda skeleton pypi ptipython
    conda skeleton pypi ptpython	

Then manually edited the meta.yaml to point to local files rather than
pypi.

For vicar-rtl, manually created file. It is a straight forward configure/make
cycle, so we can just use a simple template. Note that this is similar to
what is in the RPM spec file in the vicar-rtl repository.

## Installing offline

We can create an offline installation of all the dependencies we have.
The instructions for this are at [afids-conda-offline](https://github.jpl.nasa.gov/Cartography/afids-conda-offline).
