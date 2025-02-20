AFIDS_VERSION=20240916
GEOCAL_VERSION=20240916
EMIT_VERSION=20240415
EMIT_PACKAGE_VERSION=1.6.19
PYNITF_VERSION=1.13
POMM_UI_VERSION=1.0
POMMOS_VERSION=1.2
DOCKER_BASE_VERSION=1.0

# Create a isolated docker instance to make package creation cleaner, and
# to test installation on a clean system. We currently use oralelinux 8
# here. Mostly anaconda doesn't care about the parent OS system.

# Normally want no-cache. If we are rebuilding things, something changed
# and we want to build everything
EXTRA_DOCKER_FLAG= --squash
EXTRA_DOCKER_FLAG+= --no-cache
EXTRA_DOCKER_FLAG+= --build-arg UID=$(UID)
EXTRA_DOCKER_FLAG+= --build-arg GID=$(GID)

# Do this in a few places, so collect into a function
define check_for_broken_libraries
docker exec $$(cat docker_run.id) bash --login -c 'for i in $$(find /root/miniforge3/lib -name "*.so"); do if ldd -r $$i 2>&1 | grep -qF "not found"; then echo "library $$i seems to be broken"; fi; done | tee workdir/broken_list/$1'
endef

define check_for_broken_libraries_env
docker exec $$(cat docker_run.id) bash --login -c 'for i in $$(find /root/miniforge3/envs/$2/lib -name "*.so"); do if ldd -r $$i 2>&1 | grep -qF "not found"; then echo "library $$i seems to be broken"; fi; done | tee workdir/broken_list/$1'
endef

# Not currently used, we have this in place just in case we need to use these.
# This was for the more detailed package determination we needed for the
# offline channel, we pretty much do what these were designed for in one
# step with our determine-conda-forge-package rule.
define before_determine_package
docker run -t -d --cidfile=docker_run.id -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/$2:$(DOCKER_BASE_VERSION) /bin/bash
docker exec $$(cat docker_run.id) bash --login -c "cd workdir && ./conda_support_util package-from-env $1 manifest_collect/before.pkl"
endef

define after_determine_package
$(call check_for_broken_libraries,determine_package_broken_library.lst)
docker exec $$(cat docker_run.id) bash --login -c "cd workdir && ./conda_support_util package-from-env $1 manifest_collect/after.pkl"
docker container stop $$(cat docker_run.id)
rm docker_run.id
endef


# Podman doesn't let us set the user for afids-conda like we can with
# docker. For right now, we just use a separate docker file. We can perhaps
# come up with something more clever, but this is fine for now.
docker-base-podman:
	@echo "If you are using docker, run docker-base-docker instead"
	docker build $(EXTRA_DOCKER_FLAG) -t afids-conda-package/docker-base:$(DOCKER_BASE_VERSION) docker/afids-conda-base-podman

# Next step of docker, we have installed miniforge but haven't done anything
# else
docker-miniforge-base:
	docker run -t -d --cidfile=docker_run.id -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/docker-base:$(DOCKER_BASE_VERSION) /bin/bash
# See https://docs.anaconda.com/anaconda/install/linux, which list these
# packages as needed
	docker exec $$(cat docker_run.id) bash --login -c "dnf install -y libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver"
# Also seem to need these packages, at least
	docker exec $$(cat docker_run.id) bash --login -c "dnf install -y libICE ocl-icd libSM libquadmath pciutils-libs tbb xcb-util-renderutil xcb-util-wm xcb-util-image xcb-util-keysyms"
	docker exec $$(cat docker_run.id) bash --login -c "curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && bash ./Miniforge3-Linux-x86_64.sh -b && /root/miniforge3/bin/conda init bash"
	docker exec $$(cat docker_run.id) bash --login -c "conda config --add channels file:///home/afids-conda/workdir/afids-conda-channel"
# Still have some libraries that look broken. List these, just so we know
# what it is. I don't think any of these matter, but we should have it
	$(call check_for_broken_libraries,miniforge_base_broken_library.lst)
	docker commit $$(cat docker_run.id) afids-conda-package/docker-miniforge-base:$(DOCKER_BASE_VERSION)
	docker container stop $$(cat docker_run.id)
	rm docker_run.id

# Install miniforge, mamba and build package
docker-mamba-base:
	docker run -t -d --cidfile=docker_run.id -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/docker-miniforge-base:$(DOCKER_BASE_VERSION) /bin/bash
	docker exec $$(cat docker_run.id) bash --login -c "mamba install --yes conda-build click pandas boa --freeze-installed"
	$(call check_for_broken_libraries,mamba_broken_library.lst)
	docker exec $$(cat docker_run.id) bash --login -c "cd workdir && ./conda_support_util package-from-env base base_with_mamba_package_set.pkl"
	docker commit $$(cat docker_run.id) afids-conda-package/docker-mamba-base:$(DOCKER_BASE_VERSION)
	docker container stop $$(cat docker_run.id)
	rm docker_run.id

# If we have a failure and want to start with a new container, this
# stops the old one and removes the docker_run.id file
docker-cleanup:
	docker container stop $$(cat docker_run.id)
	rm docker_run.id

# Version of docker we use below, can change as we progress through
# development

DOCKER_NAME=docker-mamba-base
#DOCKER_NAME=docker-afids-base
#DOCKER_NAME=docker-miniforge-base

# Rule to start a interactive docker instance, just so I don't need to
# remember the syntax
docker-start:
	docker run -it -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/$(DOCKER_NAME):$(DOCKER_BASE_VERSION) /bin/bash

# Rule to start a interactive docker instance with x11, just so I don't need to
# remember the syntax
docker-start-x11:
	docker run -e DISPLAY -it -v $$(pwd):/home/afids-conda/workdir:Z -v /tmp/.X11-unix:/tmp/.X11-unix --security-opt label=type:container_runtime_t --volume="$$HOME/.Xauthority:/root/.Xauthority:rw" --net=host afids-conda-package/$(DOCKER_NAME):$(DOCKER_BASE_VERSION) /bin/bash

# Version of docker with no network. docker has a --package argument, but
# good to check that we can install/build things with zero access to
# internet
docker-start-nonetwork:
	docker run -it --network none -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/$(DOCKER_NAME):$(DOCKER_BASE_VERSION) /bin/bash

# When a failure occurs, can connect to the docker instance used in a rule
docker-connect:
	docker exec -it $$(cat docker_run.id) bash --login

# Run with docker. Note if you have a failure case that you need to look
# more deeply into, you can do a "docker container ls -a"
# Might be something like "bold_feynman", so can do
# "docker restart bold_feynman"
# "docker container exec -i -t bold_feynman bash"
# The build will be in  /home/smyth/miniforge3/conda-bld/
# go to the work directory and do source build_env_setup.sh to
# set up everything
DOCKER_RUN = docker run -it -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/docker-mamba-base:$(DOCKER_BASE_VERSION) bash --login -c

# Doesn't seem to work with everything yet. Note mambabuild is in the package
# "boa" which isn't at all an obvious package name.
define mamba_build
$(DOCKER_RUN) "cd workdir && conda mambabuild --output-folder afids-conda-channel/ -m conda_build_config.yaml $1"
endef
# Version that uses conda build, for the packages that need that instead of
# mambabuild.
define conda_build
$(DOCKER_RUN) "cd workdir && conda build --output-folder afids-conda-channel/ -m conda_build_config.yaml $1"
endef
CONDA_CREATE_ENV = mamba create --channel ./afids-conda-channel

# General rule for building a package

afids-conda-channel/built-%: %/meta.yaml
	$(call mamba_build,$(dir $<))
	touch $@

build-%: 
	$(MAKE) afids-conda-channel/built-$*

# Dependencies between packages
afids-conda-channel/built-afids-carto: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-vicar: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-afids-xvd: afids-conda-channel/built-vicar

afids-conda-channel/built-tix: afids-conda-channel/built-tkheader

afids-conda-channel/built-itcl: afids-conda-channel/built-tkheader

afids-conda-channel/built-afids: afids-conda-channel/built-afids-data

afids-conda-channel/built-afids: afids-conda-channel/built-vicar

# Use conda-forge version instead
#afids-conda-channel/built-afids: afids-conda-channel/built-gdal

afids-conda-channel/built-afids: afids-conda-channel/built-afids-carto

afids-conda-channel/built-afids: afids-conda-channel/built-vicar-rtl

afids-conda-channel/built-afids: afids-conda-channel/built-tix

afids-conda-channel/built-afids: afids-conda-channel/built-itcl

# Use conda-forge version instead
#afids-conda-channel/built-afids: afids-conda-channel/built-hdfeos

afids-conda-channel/built-afids: afids-conda-channel/built-vicar-gdalplugin

afids-conda-channel/built-afids: afids-conda-channel/built-afids-xvd

# We need our own gnuplot, it has lots of x libraries that conflict with afids-xvd
# unless we build our own.
afids-conda-channel/built-afids: afids-conda-channel/built-gnuplot

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-data

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-vicar-rtl

# Use conda-forge version instead
#afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-gdal

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-vicar-gdalplugin

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-libblitz

# Use conda-forge version instead
afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-ptpython

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-carto

# Use conda-forge version instead
#afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-hdfeos

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-pynitf

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-spice

# Use conda-forge version instead
# afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-scikit-umfpack

afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-afids-xvd

# This doesn't build now, and I'm not sure we actually need this. For now just
# use opencv, and we can come back to this if needed
#afids-conda-channel/built-afids-development-tools: afids-conda-channel/built-opencv-nonfree

afids-conda-channel/built-python-pptx: afids-conda-channel/built-xlsxwriter

afids-conda-channel/built-pommos: src/pommos-$(POMMOS_VERSION).tar.bz2

afids-conda-channel/built-pomm-ui: src/pomm-ui-$(POMM_UI_VERSION).tar.bz2

afids-conda-channel/built-pomm-ui: afids-conda-channel/built-pommos

afids-conda-channel/built-geocal: src/geocal-$(GEOCAL_VERSION).tar.bz2

afids-conda-channel/built-emit: src/emit-$(EMIT_PACKAGE_VERSION).tar.bz2

# Rule to build all the afids packages.
build-all:
#	$(MAKE) determine-conda-forge-package
	$(MAKE) build-afids-development-tools
	$(MAKE) build-geocal
	$(MAKE) build-joe-editor
	$(MAKE) build-afids
#	$(MAKE) build-pomm-ui
	$(MAKE) fresh-conda-index

# If we update a package (as opposed to build a new one), the cache is
# probably out of date. This rule clears the cache and reruns conda index
fresh-conda-index:
	-rm -rf ./afids-conda-channel/linux-64/.cache ./afids-conda-channel/noarch/.cache
	conda index ./afids-conda-channel

# If we have installed an package, and then updated it, the cache might
# have an older version. Simple rule to clean that
conda-clean:
	conda clean --all --yes
	mamba clean --all
#	conda-build purge-all

# Rule to build a test environment with afids in it, check for broken
# packages, create a docker instance.
docker-afids-base:
	docker run -t -d --cidfile=docker_run.id -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/docker-mamba-base:$(DOCKER_BASE_VERSION) /bin/bash
	docker exec $$(cat docker_run.id) bash --login -c "mamba create -y -n afids-env afids-development-tools geocal joe-editor afids pomm-ui"
	$(call check_for_broken_libraries_env,afids_base_broken_library.lst,afids-env)
	docker exec $$(cat docker_run.id) bash --login -c "cd workdir && ./conda_support_util package-from-env afids-env afids_package_set.pkl"
	docker commit $$(cat docker_run.id) afids-conda-package/docker-afids-base:$(DOCKER_BASE_VERSION)
	docker container stop $$(cat docker_run.id)
	rm docker_run.id

# We have packages that we need to get from conda forge. We go ahead and
# download these and hold them fixed, it seems to work better to only have
# afids depend on the defualts channel.
determine-conda-forge-package: afids-conda-channel/built-conda-forge-package

# We use to use the anaconda defaults channel, and find what packages we need
# from conda-forge separately. This was before the license changed, we can now
# no longer use anconda or the default channel. But leave this rule here in case
# we need something similar in the future
afids-conda-channel/built-conda-forge-package:
	mkdir -p afids-conda-channel
	conda index afids-conda-channel
	docker run -t -d --cidfile=docker_run.id -v $$(pwd):/home/afids-conda/workdir:Z afids-conda-package/docker-mamba-base:$(DOCKER_BASE_VERSION) /bin/bash
	docker exec $$(cat docker_run.id) bash --login -c "mamba create -n afids-env -y --file workdir/needed_from_conda_forge.txt -c defaults -c conda-forge"
	docker exec $$(cat docker_run.id) bash --login -c "cd workdir && ./conda_support_util package-from-env afids-env needed_from_conda_forge.pkl"
	./conda_support_util download-conda-forge needed_from_conda_forge.pkl
# Add download
	docker container stop $$(cat docker_run.id)
	rm docker_run.id
	$(MAKE) fix-libiconv-dependency
	touch $@

# Fix libiconv dependency issues for a few packages (see description in
# conda_support_util for the details of this fix). Also fix openssl issue
# if needed (not currently needed, although we have that in our offline
# version)
fix-libiconv-dependency:
	./conda_support_util fix-libiconv-dependency afids-conda-channel/linux-64/openmotif-* afids-conda-channel/linux-64/doxygen-*


# $(call make_tar,<directory>,<version>,<git tag>)
define make_tar
( ( cd ../$1 && git archive --format=tar --prefix=$1-$2/ $3 ) && touch $@.ok) | bzip2 > $@
rm $@.ok || rm $@
endef

# $(call make_tar2,<directory>,<name>,<version>,<git tag>)
define make_tar2
( ( cd ../$1 && git archive --format=tar --prefix=$2-$3/ $4 ) && touch $@.ok) | bzip2 > $@
rm $@.ok || rm $@
endef

# Build tar files of source. Note we don't do this anymore, instead we
# get stuff from the public github. But leave these old rules in place
# in case we need them again

# Note - for afids we don't have this change very often. Just grab the
# tar file we already create for generating the RPM build of AFIDS. No
# reason at least now to have newer versions.

src/pynitf-$(PYNITF_VERSION).tar.bz2:
	$(call make_tar,pynitf,$(PYNITF_VERSION),$(PYNITF_VERSION))

src/pomm-ui-$(POMM_UI_VERSION).tar.bz2:
	$(call make_tar,pomm-ui,$(POMM_UI_VERSION),v$(POMM_UI_VERSION)_rc2)

src/pommos-$(POMMOS_VERSION).tar.bz2:
	$(call make_tar2,afids-repo,pommos,$(POMMOS_VERSION),pommos-$(POMMOS_VERSION):afids_python/pommos)

src/geocal-$(GEOCAL_VERSION).tar.bz2:
	$(call make_tar,geocal-repo,$(GEOCAL_VERSION),conda-$(GEOCAL_VERSION))

src/emit-$(EMIT_PACKAGE_VERSION).tar.bz2:
	$(call make_tar,emit,$(EMIT_PACKAGE_VERSION),v$(EMIT_PACKAGE_VERSION)_rc1)

geocal-tar: src/geocal-$(GEOCAL_VERSION).tar.bz2

# Bunch of environments we regularly build, have rules for these

afids-test-env:
	-conda env remove -n afids-test --yes
	$(CONDA_CREATE_ENV) --yes -n afids-test geocal afids-development-tools afids

# Same as afids-test-env, except we get this from our cartography-jpl channel
afids-test2-env:
	-conda env remove -n afids-test2 --yes
	mamba create --channel cartography-jpl --yes -n afids-test2 geocal afids-development-tools afids

geocal-test-env:
	-conda env remove -n geocal-test --yes
	$(CONDA_CREATE_ENV) --yes -n geocal-test afids-development-tools

upload-to-anaconda:
	@echo "Make sure afids-test is the latest (so make Manifest_linux.yml if needed)"
	@echo "Before running, you should conda activate afids-test and then do"
	@echo "make Manifest_linux.yml (if afids-test isn't already made)"
	@echo "anaconda login"
	@echo "then run this command"
	./conda_support_util upload-to-anaconda-from-env

Manifest_linux.yml:
	-conda env remove -n afids-test
	$(CONDA_CREATE_ENV) --yes -n afids-test geocal afids-development-tools afids joe-editor 
	conda env export --override-channels --channel conda-forge --channel ./afids-conda-channel -n afids-test > $@

# OSX currently doesn't work, although we could possibly dust this off and
# build these again.
Manifest_osx.yml:
	-conda env remove -n afids-test
	$(CONDA_CREATE_ENV) --yes -n afids-test geocal afids-development-tools afids
	conda env export -n afids-test > $@

# Rule for making EMIT conda environment
emit-env:
	-mamba env remove -p /store/shared/nostripe/conda-shared-envs/afids-$(EMIT_VERSION) --yes
	mamba create -y --override-channels -c $$(pwd)/afids-conda-channel -c conda-forge -p /store/shared/nostripe/conda-shared-envs/afids-$(EMIT_VERSION) afids geocal afids-development-tools
	mamba install -c conda-forge -y -p /store/shared/nostripe/conda-shared-envs/afids-$(EMIT_VERSION) h5netcdf git-annex=*=nodep_*
	-rm $$(find /store/shared/nostripe/conda-shared-envs/afids-$(EMIT_VERSION) -name '*.la')
	conda env config vars set -p /store/shared/nostripe/conda-shared-envs/afids-$(EMIT_VERSION) AFIDS_DATA_ELEV_ROOT=/store/shared/dem/srtm_v3_dem_L2 AFIDS_DATA_SPICEDATA=/store/shared/spice_data/cspice

# Version without geocal installed, so we can install our own development version
emit-development-env:
	mamba create -y --override-channels -c $$(pwd)/afids-conda-channel -c conda-forge -p /home/smyth/conda-local-envs/geocal-development afids  afids-development-tools
	mamba install -c conda-forge -y -p /home/smyth/conda-local-envs/geocal-development h5netcdf git-annex=*=nodep_*
	-rm $$(find /home/smyth/conda-local-envs/geocal-development -name '*.la')
	conda env config vars set -p /home/smyth/conda-local-envs/geocal-development AFIDS_DATA_ELEV_ROOT=/beegfs/store/shared/dem/srtm_v3_dem_L2 AFIDS_DATA_SPICEDATA=/beegfs/store/shared/spice_data/cspice

# Create a sh file to install all of geocal
# Note need "constructor" in the conda environment
geocal-sh:
	constructor geocal-constructor

emit-sh:
	constructor emit-constructor

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

# DOCKER has some weird permission issues I don't understand. We may
# eventually sort this out, but for now just skip setting owner and group
# if we are in docker
ifdef IN_DOCKER
TAR_ARG=--no-same-owner
else
TAR_ARG=
endif

# We don't want to depend on there being an exisiting conda environment.
# So we download a minimum environment micromamba. This is just enough
# of a system to turn around and create an environment.
miniforge:
# Not all systems have wget, so we use curl here
	curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && bash ./Miniforge3-Linux-x86_64.sh -b

Manifest_linux-modify.yml: Manifest_linux.yml
# We need to replace the local-channel line found in the spec file, since
# this is a hard coded path and isn't necessarily the same on this system
	( grep -B 1000 afids-conda-channel Manifest_linux.yml | grep -v afids-conda-channel ) > Manifest_linux-modify.yml
	echo "  - file://$$(pwd)/afids-conda-channel" >> Manifest_linux-modify.yml
	( grep -A 1000 afids-conda-channel Manifest_linux.yml | grep -v afids-conda-channel ) >> Manifest_linux-modify.yml
