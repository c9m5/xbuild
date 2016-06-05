#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/NetBSD/install.sh
# Description: Description
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

netbsd_install_sources() {
    src="NetBSD-$1"; local src
    downdir="${HOME}/Downloads/xbuild/NetBSD-$1"; local downdir
    pwd_save="$(pwd)"; local pwd_save

    if [ ! -d "$downdir" ] ; then
        mkdir -p "$downdir"
    fi

    case $target in
        *-release-*)
            targz="bin common compat compat config crypto dist distrib doc etc external extsrc games gnu include lib libexec regress rescue sbin share sys tests tools top-level usr.bin usr.sbin x11"; local targz

            for i in $targz; do
                tarball="${i}.tar.gz"; local tarball
                echo "Downloading ${src} \"${tarball}\""
                ftp -inV "${netbsd_ftp_root}/${target}/${tar_files}/" << __EOF__
lcd ${downdir}
get ${tarball}
bye
__EOF__
            done
            ;;
        *)
            targz="gnusrc sharesrc src syssrc xsrc"; local targz

            for i in targz; do
                tarball="${i}.tar.gz"; local tarball
                echo "Downloading ${src} \"${tarball}\"."
                ftp -inV "${netbsd_ftp_root}/${target}/source/sets/" << __EOF__
lcd ${downdir}
get ${tarball}
bye
__EOF__
            done
            ;;
    esac
}

netbsd_install_pkgsrc() {
}

netbsd_install_doc() {
}

