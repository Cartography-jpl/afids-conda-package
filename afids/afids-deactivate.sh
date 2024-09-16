#!/bin/bash
vlist="AFIDSTOP AFIDSXVDTOP AFIDSDATATOP VICARTOP AFIDSPYTHONTOP AFIDS_ROOT AFIDS_TCL AFIDS_VERSION VRDIFONTS TAE_PATH DFFPATH AFIDS_JOERC"
for v in $vlist; do
    sv="__CONDA_SHLVL_${CONDA_SHLVL}_${v}"
    unset $v
    if [[ -n "${!sv}" ]]; then
	export $v=${!sv}
	unset $sv
    fi
done   
