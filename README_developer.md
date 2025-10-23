# For Developers

## Build help

We have a top level Makefile that can be used to build all the packages.

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

Building is just

    rattler-build build --output-dir ./afids-conda-channel/ -c conda-forge -c ./afids-conda-channel --recipe vicar-rtl/recipe.yaml
	
Note when creating the recipe that we often need to make small updates to the 
git repository we are building (e.g., add a flag, fix a warning/error). It is usually
good to wait to add a tag until we have built on both linux and the mac. So you
can start using a "rev: \< git_hash \>" ,and then once everything is working add
and final tag and update the recipe to use a "tag: \< git tag \>".
	
(or whatever your package list is). You can then install with, assuming you added the
path when you created pixi - e.g. 

    pixi init -c conda-forge -c <blahblah>/afids-conda-package/afids-conda-channel <env_dir>

with 

    pixi add vicar-rtl
	
## Installing offline

We can create an offline installation of all the dependencies we have.
The instructions for this are at [afids-conda-offline](https://github.jpl.nasa.gov/Cartography/afids-conda-offline).
