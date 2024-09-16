# afids-conda-package

This contains conda recipes for building the afids system in conda,
or for using prebuilt afids package to install in conda.

Conda is a packaging system (e.g., similar to redhat "yum" or debian 
"apt-get"). It is different than other packaging systems in that 1) it can
be installed with no special user permission (e.g., no need to be root) and
2) it can install multiple environments, like python virtual environments.
However conda installs the entire environment, not just python packages.

## Tl;dr

A fresh installation of Afids/GeoCal can be done on a linux system by:

Go to [afids releases](https://github.com/Cartography-jpl/afids-conda-package/releases) 
and download the latest afids-xxxxx-Linux-x86_64.sh

On your system:

    bash ./afids-xxxxx-Linux-x86_64.sh
	
Follow directions to install.	

## Installing

1. Install the base system. This only needs to be done once
   initially. The directions for this can be found
   at [Miniforge Installing](https://github.com/conda-forge/miniforge).
   
2. Go to https://github.com/Cartography-jpl/afids-conda-package/releases
   and download the latest afids-conda-channel-xxxxx.tar.bz2

3. Unpack the conda channel where desired on your system

    tar -xzf ./afids-conda-channel-xxxxx.tar.bz2
      
4. Create a Conda environment with the AFIDS software installed, described 
   in the next section.
   
## Preparation for creating conda environment

The packages used by conda are controlled by supplying a number of
"channels".  The stock afids install uses just the conda-forge channel.
	
We have packages that we have built at JPL not available
on any of the standard channels. 
	
You can then either add this as a permanent channel used by conda:

    conda config --prepend channels file://blah/blah/afids-conda-channel
	
Or alternatively when you execute a mamba install command you can specify the channel 
to search:

    mamba install --channel file://blah/blah/afids-conda-channel -n geocal-env geocal afids-development-tools

You can check that your channel list is correct by:

    conda config --show channels
	
This should be something like:

    channels:
      - file://blah/blah/afids-conda-channel
      - conda-forege

## Packages

The package "geocal" installs GeoCal. "afids-development-tools"
installs a number of useful tools, including everything needed to
build geocal from source. A common installation is

    mamba install -n geocal-env geocal afids-development-tools
	
which installs both geocal and other useful tools.

## Manifest files

Conda tries to track all the dependencies of software, but it sometimes fails.
It is not unheard of to come up with an inconsistent environment with packages
that conflict - either because of an error in the packages we have created or
a problem with Conda itself.

To help with this, there is a manifest files that give a complete list
of an known, working environment. [Manifest_linux.yml](Manifest_linux.yml) 
gives a linux version gives a full list of packages that we know work together.

It is *not* a requirement that you match each of the package versions. But
if you run into problems with an install, it can be useful to have a reference.

If desired, you can exactly recreate our environment from the Manifest files.
The file contains a hardcoded path to the refractor channel, you should edit
the file to replace this with the path you are using. Then:

    conda env create -n my_afids_env -f Manifest_linux.yml
	
or give Manifest_osx.yml to build on the Mac.	


## For Developers

See [developer documentation](README_developer.md)

