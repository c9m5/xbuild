#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/config.sh
# Description: configuration script
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

VERSION=0.0.1

if [ ! "$xbuild_prefix" ] ; then
    echo "[ERROR] xbuild_prefix needs to be set by the calling shellscript!"
    exit 2
fi
xbuild_bindir="${xbuild_prefix}/bin"
xbuild_libdir="${xbuild_prefix}/lib/xbuild"
xbuild_datadir="${xbuild_prefix}/share/xbuild"

XBUILD_OS_LIST=""
for i in ${xbuild_libdir}/os/* ; do
    if ([ -d "$i" ] && [ -r os.conf ] && {})
        os_tag="`cat "${i}/os.conf" | grep "OS_TAG=" | cut -f 2 -d '"' -`"
        os_name="`cat "${i}/os.conf" | grep "OS_NAME=" | cut -f 2 -d '"' -`"

        if [ -z "$XBUILD_OS_LIST" ] ; then
            XBUILD_OS_LIST="${os_tag}:${os_name}:${i}"
        else
            XBUILD_OS_LIST="${os_list};${os_tag}:${os_name}:${i}"
        fi
        unset -v os_tag os_name
    fi
done
readonly XBUILD_OS_LIST

# sourcing global config files
for i in /etc /usr/local/etc ${xbuild_prefix}/etc ${HOME}/.loacal/etc; do
    if [ -r "${i}/xbuild.rc" ] ; then
        . ${i}/xbuild.rc
    fi
done

if [ -r "${HOME}/.xbuildrc" ] ; then
    . ${i}/.xbuildrc
    xbuild_is_installed="yes"
else
    xbuild_is_installed="no"
fi

xbuild_tmpdir="${XBUILD_TMP_PREFIX:=/etc}/xbuild.${LOGNAME:=$USER}"
if [ ! -d "$xbuild_tmpdir}" ] ; then
    mkdir -p "$xbuild_tmpdir"
fi

# check for host system
xbuild_host="`uname -o`"

#case "$xbuild_host" in
#    FreeBSD)
#        xbuild_host_is_freebsd="yes"
#        freebsd_syssrc_dir="/usr/src"
#        freebsd_sysdoc_dir="/usr/doc"
#        freebsd_sysports_dir="/usr/ports"
#        ;;
#    NetBSD)
#        xbuild_host_is_netbsd="yes"
#        netbsd_syssrc_dir="/usr/src"
#        netbsd_sysdoc_dir="/usr/doc"
#        netbsd_syspkgsrc_dir="/usr/pkgsrc"
#        ;;
#    *)
#        xbuild_host_is_unknown="yes"
#        xbuild_host=`uname -o`
#        ;;
#esac
#: ${xbuild_host_is_freebsd:="no"}
#: ${xbuild_host_is_netbsd:="no"}
#: ${xbuild_host_is_unknown:="no"}

. ${xbuild_libdir}/misc.sh
xbuild_dialog_backtitle="xbuild - Cross build toolkit for embedded platforms"


# configure for installer
config_install() {
    # default installation dir
    # might be set in $X/etc/xbuild.rc
    : ${XBUILD_DEFAULT_ROOTDIR:="${HOME}/xbuild.root"}
    install_log="/tmp/xbuild.${LOGNAME:=$USER}.install.log"

    #freebsd_src_releng_enable="`is_true $FREEBSD_SRC_RELENG`"



#    . "${xbuild_libdir}/freebsd.sh"
#    . "${xbuild_libdir}/netbsd.sh"

#    . "${xbuild_libdir}/freebsd.install.sh"
#    . "${xbuild_libdir}/netbsd.install.sh"

    . "${xbuild_libdir}/dialog.install.sh"
}


