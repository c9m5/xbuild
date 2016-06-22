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

xbuild_version="0.0.2"

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
# Generic Config
################################################################################

. "${xbuild_libdir}/misc.sh"

# load global config-files
for i in "/etc" "/usr/local/etc" "${xbuild_prefix}/etc"; do
    if [ -r "${i}/xbuild.rc" ] ; then
        . "${i}/xbuild.rc"
    fi
done

: ${xbuild_suppress_dialogs:="no"}
: ${xbuild_dialog:="dialog"}
xbuild_dialog_backtitle="xbuild - Cross Build Toolkit for Embedded Systems"

# Check if we are installed
if [ -r "${HOME}/.xbuildrc" ] ; then
    xbuild_is_installed="yes"
    . "${HOME}/.xbuildrc"

    : ${XBUILD_CONFIGDIR:="${XBUILD_ROOT}/config"}
    : ${XBUILD_BASEDIR:="${XBUILD_ROOT}/xbuild"}
    debug "XBUILD_CONFIGDIR=${XBUILD_CONFIGDIR}"
    debug "XBUILD_BASEDIR=${XBUILD_BASEDIR}"
else
    xbuild_is_installed="no"
fi

: ${xbuild_tempdir:="`mktemp -d /tmp/c9.xbuild.XXXX`"}
if [ ! -d "$xbuild_tempdir" ] ; then
    mkdir -p "${xbuild_tempdir}"
fi
trap "rm -rf $xbuild_tempdir" EXIT QUIT
if ([ "${xbuild_is_installed}" == "yes" ] && [ -r "${XBUILD_CONFIGDIR}/xbuild.rc" ]) ; then
    debug "Loading \"${XBUILD_CONFIGDIR}/xbuild.rc\""
    . "${XBUILD_CONFIGDIR}/xbuild.rc"

    # load files
    if [ -n "${XBUILD_IMPORT_FILES}" ] ; then
        for i in ${XBUILD_IMPORT_FILES}; do
            if [ "`echo $i | cut -c 1 -`" == "/" ] ; then
                local ifile="$i"
            else
                local ifile="${XBUILD_CONFIGDIR}/${i}"
            fi
            if [ -r "$ifile" ] ; then
                debug "Loading $ifile"
                . "$ifile"
            else
                error "Unable to read file \"$ifile\"! Ignoring!"
            fi
        done
    fi
fi

if [ "xbuild_is_installed" == "yes" ] ; then
    : ${XBUILD_CACHEDIR:="${XBUILD_BASEDIR}/cache}"}
    : ${XBUILD_DOWNLOADDIR:="${XBUILD_CACHEDIR}"}
fi

. "${xbuild_libdir}/dialogs.sh"

################################################################################
# Programs
################################################################################

if [ -z "`command -v sudo`" ] ; then
    echo "sudo not found" >&2
    echo "Please install sudo" >&2
fi
: ${XBUILD_SUDO:="sudo"}

if [ ! -z "`command -v svn`" ] ; then
    : ${XBUILD_SVN:="`command -v svn`"}
elif [ ! -z "`command -v svnlite`" ] ; then
    : ${XBUILD_SVN:="`command -v svnlite`"}
fi
if [ -z "$XBUILD_SVN" ] ; then
    error "\"svn\"  is not installed!"
    error "Please install \"svn\" or \"svnlite\"!"
fi
: ${SVN_RETRIES:=10}
: ${SVN_RETRY_TIMEOUT:=5}
: ${CVS_RETRIES:=10}
: ${CVS_RETRY_TIMEOUT:=5}
: ${FTP_RETRIES:=10}
: ${FTP_RETRY_TIMEOUT:=10}

################################################################################
# Library Files
################################################################################

. "${xbuild_libdir}/os.sh"
. "${xbuild_libdir}/board.sh"
. "${xbuild_libdir}/projects.sh"

# load supported operating systems
xbuild_os_list=""

for i in ${xbuild_oslibdir}/* ; do
    if ([ -d "$i" ] && [ -r "${i}/os.conf" ]) ; then
        debug "Loading OS ${i##$xbuild_oslibdir}"
        . "${i}/os.conf"
        if [ -r ${i}/imports ] ; then
            for ifile in `cat ${i}/imports`; do
                debug "IMPORT \"${i}/${ifile}\""
                . "${i}/${ifile}"
            done
        fi
    fi
    unset x
done

################################################################################
# Boards
################################################################################




################################################################################
# Functions
################################################################################



