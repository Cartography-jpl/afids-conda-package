# ********************************************************
# Note that thesse tags needs to be on the public github, not just the
# JPL one. I tend to forget that, but the source for building is
# downloaded from the public git, not the JPL git.
# ********************************************************
AFIDS_VERSION=20240916
GEOCAL_VERSION=20250904
PYNITF_VERSION=1.13
POMM_UI_VERSION=1.0
POMMOS_VERSION=1.2
DOCKER_BASE_VERSION=1.0

# Few things are different on linux vs mac
OS := $(shell uname -s)

# Note we depend on post-link scripts. No way to avoid this, it is really required
# in a few places (e.g., setting up spice). Need to turn this on, it is off by default
# pixi config set run-post-link-scripts insecure
# (can also just set with --local)
#
# Depends on having pixi, rattler-build, rattler-index
# After pixi is installed:
# pixi global install rattler-build
# pixi global install rattler-index

CONDA_CREATE_ENV = mamba create --channel ./afids-conda-channel

# General rule for building a package

# Don't normally need to run index, it happens automatically when we build.
# But can be useful if for example you manually remove an older version file
reindex:
	-rm -r afids-conda-channel/linux-64/shards
	-rm -r afids-conda-channel/noarch/shards
	-rm -r afids-conda-channel/osx-arm64/shards
	rattler-index fs -f ./afids-conda-channel

afids-conda-channel/built-%: %/recipe.yaml
	rattler-build build --output-dir ./afids-conda-channel/ -c conda-forge -c ./afids-conda-channel --recipe $<
	touch $@
	chmod -R a+rX ./afids-conda-channel

# We don't actually support windows, but we want afids-data to be noarch so we can use
# the same one on linux and osx. So go ahead and add flag needed to support windows
afids-conda-channel/built-afids-data: afids-data/recipe.yaml
	rattler-build build --allow-symlinks-on-windows --output-dir ./afids-conda-channel/ -c conda-forge -c ./afids-conda-channel --recipe $<
	touch $@
	chmod -R a+rX ./afids-conda-channel

build-%: 
	$(MAKE) afids-conda-channel/built-$*

force-build-%:
	-rm afids-conda-channel/built-$*
	$(MAKE) afids-conda-channel/built-$*

# Dependencies between packages
afids-conda-channel/built-afids-carto: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-vicar: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-afids-xvd: afids-conda-channel/built-vicar

afids-conda-channel/built-afids: afids-conda-channel/built-afids-data

afids-conda-channel/built-afids: afids-conda-channel/built-vicar

afids-conda-channel/built-afids: afids-conda-channel/built-afids-carto

afids-conda-channel/built-afids: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-afids: afids-conda-channel/built-tix

afids-conda-channel/built-afids: afids-conda-channel/built-itcl

ifeq ($(OS),Darwin)
# There aren't conda-forge versions of these on the Mac (at least as of
# 10/1/2025). So we build our own. This can go away if these packages
# are ever made available. 
afids-conda-channel/built-afids-xvd: afids-conda-channel/built-openmotif-mac
else
# We build tkheader on linux, and it is generic. Doesn't build on mac (just
# difference in sed syntax). Not worth tracking down, we just use the linux
# built version on the mac
afids-conda-channel/built-tix: afids-conda-channel/built-tkheader

afids-conda-channel/built-itcl: afids-conda-channel/built-tkheader
endif

afids-conda-channel/built-afids: afids-conda-channel/built-vicar-gdalplugin

afids-conda-channel/built-afids: afids-conda-channel/built-afids-xvd

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-data

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-vicar-gdalplugin

# There is a libblitz package, but there are differences. We may eventually change
# geocal to work with the newer version, but for now build our own. This is pretty
# small package, so not a big deal to have our own version
#afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-libblitz

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-carto

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-pynitf

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-spice

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-xvd

# This doesn't build now, and I'm not sure we actually need this. For now just
# use opencv, and we can come back to this if needed
#afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-opencv-nonfree

afids-conda-channel/built-pommos: src/pommos-$(POMMOS_VERSION).tar.bz2

afids-conda-channel/built-pomm-ui: src/pomm-ui-$(POMM_UI_VERSION).tar.bz2

afids-conda-channel/built-pomm-ui: afids-conda-channel/built-pommos

# Rule to build all the afids packages.
build-all:
	$(MAKE) build-afids-development-tools
	$(MAKE) build-geocal
	$(MAKE) build-joe-editor
	$(MAKE) build-afids
#	$(MAKE) build-pomm-ui
	$(MAKE) reindex

# If we have installed an package, and then updated it, the cache might
# have an older version. Simple rule to clean that. Not needed for pix
conda-clean:
	conda clean --all --yes
	mamba clean --all

# Bunch of environments we regularly build, have rules for these

afids-test-env:
	-conda env remove -n afids-test --yes
	$(CONDA_CREATE_ENV) --yes -n afids-test geocal afids-development-tools afids

geocal-test-env:
	-conda env remove -n geocal-test --yes
	$(CONDA_CREATE_ENV) --yes -n geocal-test afids-development-tools

ifeq ($(OS),Darwin)

update-manifest:
	-rm Manifest_osx.yml
	$(MAKE) Manifest_osx.yml
	mkdir -p pixi-osx
	cp test-pixi/pixi.* pixi-osx

else

update-manifest:
	-rm Manifest_linux.yml
	$(MAKE) Manifest_linux.yml
	mkdir -p pixi-linux
	cp test-pixi/pixi.* pixi-linux

endif

Manifest_linux.yml: check-test-env
	cd test-pixi && pixi list > ../Manifest_linux.yml

Manifest_osx.yml: check-test-env
	cd test-pixi && pixi list > ../Manifest_osx.yml

# Rule to install in a local test environment, just to catch any conflicts
test-env:
	-rm -r test-pixi
	pixi init -c conda-forge -c $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/afids-conda-channel test-pixi
	cd test-pixi && pixi config set --local run-post-link-scripts insecure && pixi add afids afids-development-tools geocal

# Look for broken libraries in test-env. This is linux only, probably could come up with
# a mac version if needed.
check-test-env: test-env
	for i in $$(find test-pixi/.pixi/envs/default/lib -name "*.so"); do if ldd -r $$i 2>&1 | grep -qF "not found"; then echo "library $$i seems to be broken"; fi; done

ifeq ($(OS),Darwin)
   TK_DEPS := xorg-libx11 xorg-libxau xorg-libxdmcp tk tkheader
   XVD_DEPS := xorg-libxpm xorg-libxdmcp xorg-libxmu xorg-libxau openjpeg libpng xorg-libxft xorg-xproto
else
   TK_DEPS := itcl tix
   XVD_DEPS := openmotif-dev xorg-libxpm libglx xorg-libxdmcp xorg-libxmu xorg-libxau openjpeg libpng xorg-libxft xorg-xproto
endif

# Rule to install all the conda-forge dependencies used anywhere. We do this
# to try to find a consistent set. We may grab versions from this to use in
# the conda_build_config.yaml to pin consistent versions when we build. It isn't
# exact which things need to go into conda_build_config.yaml, but we can use this
# to at least figure out what the consistent set is
dep-test-env:
	-rm -r dep-test-pixi
	pixi init -c conda-forge -c $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/afids-conda-channel dep-test-pixi
	cd dep-test-pixi && pixi config set --local run-post-link-scripts insecure
# AFIDS development tools
	cd dep-test-pixi && pixi add python perl patch make m4 pkg-config blas automake autoconf libtool parallel numpy scipy matplotlib sphinx pytest pytest-xdist pytest-cov ipython jupyter scikit-umfpack seaborn pandas numpydoc jsonpickle tabulate docopt libnetcdf gdal libgdal boost h5py hdf5 hdfeos2 hdfeos5 gsl pkgconfig doxygen swig ncurses fftw ptpython graphviz opencv gnuplot ruff mypy jupyterlab
# itcl
	cd dep-test-pixi && pixi add $(TK_DEPS)
# AFIDS xvd
	cd dep-test-pixi && pixi add $(XVD_DEPS)
# AFIDS dependencies
	cd dep-test-pixi && pixi add gdal libgdal boost blas tk gsl hdfeos2 geotiff fftw
# Geocal dependencies
	cd dep-test-pixi && pixi add libnetcdf gsl blas scipy matplotlib sphinx pytest pytest-xdist pytest-cov ipython jupyter scikit-umfpack seaborn pandas numpydoc jsonpickle tabulate future six docopt jedi prompt_toolkit pygments black h5py gdal libgdal boost hdf5 hdfeos5 pkgconfig doxygen swig ncurses fftw ptpython graphviz opencv rclone

# Create a sh file to install all of geocal
# Note need "constructor" in the conda environment
geocal-sh:
	constructor geocal-constructor

emit-sh:
	constructor emit-constructor

ecostress-sh:
	constructor ecostress-constructor

afids-sh:
	constructor afids-constructor

afids-sbg-sh:
	constructor sbg-constructor

channel-tar:
	tar --exclude=.cache --exclude=built-* -cjf afids-conda-channel.tar.bz2 ./afids-condachannel

# Install afids in a stand alone conda environment
install-afids: Manifest_linux-modify.yml miniforge
	-rm -r $(AFIDSROOT)
	./miniforge create -p $(AFIDSROOT) -y --file $<
	eval "$$($(AFIDSROOT)/bin/conda shell.bash hook)" && conda activate $(AFIDSROOT) && conda env config vars set ISISROOT=$(ISISROOT) ISISDATA=$(ISISDATA)

Manifest_linux-modify.yml: Manifest_linux.yml
# We need to replace the local-channel line found in the spec file, since
# this is a hard coded path and isn't necessarily the same on this system
	( grep -B 1000 afids-conda-channel Manifest_linux.yml | grep -v afids-conda-channel ) > Manifest_linux-modify.yml
	echo "  - file://$$(pwd)/afids-conda-channel" >> Manifest_linux-modify.yml
	( grep -A 1000 afids-conda-channel Manifest_linux.yml | grep -v afids-conda-channel ) >> Manifest_linux-modify.yml
