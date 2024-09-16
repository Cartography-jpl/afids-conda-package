#!/bin/csh
set vlist="AFIDSTOP AFIDSXVDTOP AFIDSDATATOP VICARTOP AFIDSPYTHONTOP AFIDS_ROOT AFIDS_TCL AFIDS_VERSION VRDIFONTS TAE_PATH DFFPATH AFIDS_JOERC NOTFOUND"
foreach v ( $vlist )
    eval set tv=\$\?${v}
    if ( $tv ) then
	set sv="__CONDA_SHLVL_${CONDA_SHLVL}_${v}"
	eval setenv $sv \$${v}
    endif
end

setenv AFIDSTOP $CONDA_PREFIX
setenv AFIDSXVDTOP $CONDA_PREFIX
setenv AFIDSDATATOP $CONDA_PREFIX/data
setenv VICARTOP $CONDA_PREFIX
setenv AFIDSPYTHONTOP $CONDA_PREFIX
setenv AFIDS_ROOT $CONDA_PREFIX/afids
setenv AFIDS_TCL $CONDA_PREFIX/afids/tcl
setenv AFIDS_VERSION "1.26"
setenv VRDIFONTS $CONDA_PREFIX/share/fonts/vrdi
setenv TAE_PATH "$CONDA_PREFIX/afids/vdev:$CONDA_PREFIX/vicar/bin:$CONDA_PREFIX/vicar/lib:$CONDA_PREFIX/vicar/vids/lib:$CONDA_PREFIX/afids/pommos"
setenv DFFPATH $CONDA_PREFIX/data/vextract
setenv AFIDS_JOERC $CONDA_PREFIX/share/joe
