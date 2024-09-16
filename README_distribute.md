# Introduction

NOTE - this is half written directions, we were trying to work out how to
distribute the environment. Leave this is place, but these directions aren't
complete yet.

# Distribute environment

A common need is to create a copy of an environment on another machine
(e.g., to put in a docker container)

There are three ways to do this that I'm aware of, each with different 
trade offs:

1. Install conda using miniconda, point to the channels in this repository,
   and do an install
2. Use conda-pack
3. Use constructor.

## Install using miniconda

To use this method, copy this repository along with the packages to the
the other machine. You can then install by:

First, make sure the environment you wish to recreate has a yaml file:

    source activate <my_env>
	conda list --export > my_env.txt

Create conda enviroment on the destination machine. Note that only needs to
be done once. If you are installing on a machine that won't be updated (e.g.
a docker container where you version the container rather than environment),
then you can skip creating the versioned environment and just use the base
environment.

    pkg_repository=/data/smyth/afids-conda-package
	base_dir=/data/smyth/anaconda-fresh-install
    bash $pkg_repository/conda-install/Miniconda3-4.5.4-Linux-x86_64.sh -p $base_dir -b
	export PATH=$base_dir/bin:$PATH
	conda create -n env_v1.0 --yes
	source activate env_v1.0
    (If skipping create, do "source activate base")

The my_env.yml will list all the 
Then install the the packages:

    conda install --yes --offline -c file://$pkg_repository/jpl-conda-channel -c file://$pkg_repository/conda-install/offline-channel --file my_env.txt
	
## conda-pack

Blah blah. This installs without needing to have a repository available,
it just creates on tar file. This has problems.

## constructor

Blah blah. This create a ".sh" file like the original "Anaconda*.sh" file
with all our packages. It has the limitation that it doesn't handle the 
no-arch packages.

## Recommendations

Since we already have all the packages available in a conda channel, for
most cases I recommend using the install bases on Miniconda.



	
