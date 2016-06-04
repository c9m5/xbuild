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

#xbuild_tmp_dir=$(mktemp -d -u /tmp/xbuild.${LOGNAME:=$USER}.XXXX)
xbuild_tmp_dir="/tmp/xbuild"
#trap "rm -rf ${xbuild_tmp_dir}" EXIT
if [ ! -d "$xbuild_tmp_dir" ] ; then
    mkdir -p "$xbuild_tmp_dir"
fi

for i in ${xbuild_libdir}/os/* ; do
    if ([ -d "$i" ] && [ -r ${i}/os.conf ]) ; then
        os_tag="`cat "${i}/os.conf" | grep "XBUILD_OS_TAG=" | cut -f 2 -d '"' -`"
        os_name="`cat "${i}/os.conf" | grep "XBUILD_OS_NAME=" | cut -f 2 -d '"' -`"
        echo -n "${os_tag}:${os_name}:${i};" >> $xbuild_tmp_dir/os.tmp
    fi
done
XBUILD_OS_LIST="`cat $xbuild_tmp_dir/os.tmp`"
readonly XBUILD_OS_LIST
rm $xbuild_tmp_dir/os.tmp

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



# check for host system
xbuild_host="`uname -o`"

. ${xbuild_libdir}/misc.sh
xbuild_dialog_backtitle="xbuild - Cross build toolkit for embedded platforms"


# configure for installer
config_install() {
    # default installation dir
    # might be set in $X/etc/xbuild.rc
    xbuild_install_dir=${XBUILD_DEFAULT_ROOTDIR:="${HOME}/xbuild"}
    install_log="${xbuild_tmp_dir}/install.log"
    xbuild_install_script="${xbuild_tmp_dir}/install.sh"

    for i in `os_get_tags` ; do
        libdir="`os_get_libdir_from_tag $i`"; local libdir
        . "${libdir}/os.conf"
        . "${libdir}/os.sh"
        . "${libdir}/install.sh"
        . "${libdir}/dialog.install.sh"
    done
    . "${xbuild_libdir}/dialog.install.sh"
}


