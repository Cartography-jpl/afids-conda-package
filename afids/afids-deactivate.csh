#!/bin/csh
set vlist="AFIDSTOP AFIDSXVDTOP AFIDSDATATOP VICARTOP AFIDSPYTHONTOP AFIDS_ROOT AFIDS_TCL AFIDS_VERSION VRDIFONTS TAE_PATH DFFPATH AFIDS_JOERC NOTFOUND"
foreach v ( $vlist )
    set sv="__CONDA_SHLVL_${CONDA_SHLVL}_${v}"
    unsetenv $v
    eval set tv=\$\?${sv}
    if ( $tv ) then
	eval setenv $v \$${sv}
	unsetenv $sv
    endif
end
