# Note you do not actually need to run this setup file. All you need to
# so is activate the conda environment. But we have the setup script here
# just for external programs that expect a setup script
if [ "$conda_prefix" != "$CONDA_PREFIX" ]; then
    source ${conda_prefix}/etc/profile.d/conda.sh
    conda activate ${conda_prefix}
fi
