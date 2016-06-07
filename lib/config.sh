#!/bin/sh
##
# Author(s): c9m5
# File: lib/xbuild/config.sh
# Description: configuration script for xbuild
#
################################################################################
# This is free and unencumbered software released into the public domain.      #
#                                                                              #
# Anyone is free to copy, modify, publish, use, compile, sell, or              #
# distribute this software, either in source code form or as a compiled        #
# binary, for any purpose, commercial or non-commercial, and by any            #
# means.                                                                       #
#                                                                              #
# In jurisdictions that recognize copyright laws, the author or authors        #
# of this software dedicate any and all copyright interest in the              #
# software to the public domain. We make this dedication for the benefit       #
# of the public at large and to the detriment of our heirs and                 #
# successors. We intend this dedication to be an overt act of                  #
# relinquishment in perpetuity of all present and future rights to this        #
# software under copyright law.                                                #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,              #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF           #
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.       #
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR            #
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,        #
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR        #
# OTHER DEALINGS IN THE SOFTWARE.                                              #
#                                                                              #
# For more information, please refer to <http://unlicense.org>                 #
################################################################################
#
# Changelog:

xbuild_version="0.0.0"

################################################################################
# xbuild directories
################################################################################

if [ -z "$xbuild_prefix" ] ; then
    echo "\"\$xbuild_prefix\" not set!" >&2
    exit 1
fi
: ${xbuild_bindir:="${xbuild_prefix}/bin"}
: ${xbuild_libdir:="${xbuild_prefix}/lib/xbuild"}
: ${xbuild_oslibdir:="${xbuild_libdir}/os"}
: ${xbuild_boardlibdir:="${xbuild_libdir}/boards"}

################################################################################
# generic config
################################################################################

: ${xbuild_dialog:="dialog"}
xbuild_dialog_backtitle="xbuild - Cross Build Toolkit for Embedded Systems"

################################################################################
# Check if we are installed
################################################################################

if [ -r "${HOME}/.xbuildrc" ] ; then
    xbuild_is_installed="yes"
else
    xbuild_is_installed="no"
fi


