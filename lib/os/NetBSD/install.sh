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

netbsd_install_base() {
    if [ ! -d "${netbsd_base_dir}" ] ; then
        echo "[DIR] ${netbsd_base_dir}"
        mkdir -p "${xbuild_base_dir}/NetBSD"
    fi
}

netbsd_install_sources() {
    : ${ftp_retries:=10}

    src="NetBSD-$1"; local src
    downdir="${xbuild_temp_dir}/downloads/${src}"; local downdir
    pwd_save="$(pwd)"; local pwd_save

    if [ ! -d "$downdir" ] ; then
        mkdir -p "$downdir"
    fi

    if [ ! -d "${netbsd_base_dir}/${src}" ] ; then
        echo "[DIR] ${netbsd_base_dir}/${src}"
        mkdir -p "${netbsd_base_dir}/${src}"
    fi

    case $target in
        *-release-*)
            targz="bin common compat compat config crypto dist distrib doc etc external extsrc games gnu include lib libexec regress rescue sbin share sys tests tools top-level usr.bin usr.sbin x11"; local targz

            for i in $targz; do
                tarball="${i}.tar.gz"; local tarball
                file_ok="no"; local file_ok
                retr=0; local retr
                echo "Downloading ${src} \"${tarball}\""

                while ([ "$file_ok" == "no" ] && [ $retr -le $ftp_retries ]); do
                    retr=$(( $retr + 1 ))
                    ftp -inV "${netbsd_ftp_root}/${target}/tar_files/src/" << __EOF__
lcd ${downdir}
get ${tarball}.MD5
get ${tarball}.SHA1
get ${tarball}
bye
__EOF__
                    # checksum tarballs
                    if ([ "`md5 "${downdir}/${tarball}" | cut -f 2 -d = -`" == "`cat "${downdir}/${tarball}.MD5" | cut -f 2 -d = -`" ] \
                            && [ "`sha1 "${downdir}/${tarball}" | cut -f 2 -d = -`" =0 "`cat "${downdir}/${tarball}.SHA1" | cut -f 2 -d = -`" ]) ; then
                        echo "Checksum of \"${tarball}\" OK"
                        file_ok="yes"
                    else
                        error "Download of \"${src}/${tarball}\" failed!"
                        if [ $retr -le $ftp_retries ] ; then
                            error "Retry ..."
                        fi
                    fi
                done
                if [ file_ok="yes" ] ; then
                    # extract files to temp dir and move them to dest
                    tar -xzvC "${netbsd_base_dir}/${src}" -f "${downdir}/${tarball}"
                else
                    error "Unable to download tarballs for \"${src}\"!"
                    return 1
                fi
            done
            ;;
        *)
            targz="gnusrc sharesrc src syssrc xsrc"; local targz

            for i in targz; do
                file_ok="no"; local file_ok
                retr=0; local retr
                tarball="${i}.tar.gz"; local tarball

                while ([ "$file_ok" == "no" ] && [ $retr -le $ftp_retries ]) ; do
                    retr=$(( $retr + 1 ))

                    echo "Downloading ${src} \"${tarball}\"."
                    ftp -inV "${netbsd_ftp_root}/${target}/source/sets/" << __EOF__
lcd ${downdir}
get ${tarball}.MD5
get ${tarball}.SHA1
get ${tarball}
bye
__EOF__
                    if ([ "`cat "${downdir}/${tarball}.MD5" | cut -f 2 -d = -`" == "`md5 "${downdir}/${tarball}" | cut -f 2 -d = -`" ] \
                            && "`cat "${downdir}/${tarball}.SHA1" | cut -f 2 -d = -`" == "`sha1 "${downdir}/${tarball}" | cut -f 2 -d = -`" ]) ; then
                        file_ok="yes"
                    else
                        error "Download of \"${src}/${tarball}\" failed!"
                        if [ $retr -le $ftp_retries ] ; then
                            error "Retry ..."
                        fi
                    fi
                done

                if [ file_ok="yes" ] ; then
                    # extract files to temp dir and move them to dest
                    tar -xzvC "${netbsd_base_dir}/${src}" -f "${downdir}/${tarball}"
                    mv -v "${netbsd_base_dir}/${src}/usr/*" "${netbsd_base_dir}/${src}/"
                else
                    error "Unable to download tarballs for \"${src}\"!"
                    return 1
                fi
            done
            ;;
    esac
}

netbsd_install_pkgsrc() {
    ftpaddr="ftp://ftp.NetBSD.org/pub/pkgsrc/stable"; local ftpaddr
    max_retries=5; local max_retries
    file_ok="no"; local file_ok
    retr=0; local retr

    mkdir -p "${netbsd_base_dir}/pkgsrc"

    echo "Downloading \"pkgsrc.tar.xz\""
    while ([ "$file_ok" == "no" ] && [ $retr -le $max_retries ]); do
        retr=$(( $retr + 1 ))

        wget -t 10 -T 10 -p "${xbuild_temp_dir}" "${ftpaddr}/pkgsrc.tar.xz" \
            && wget -t 10 -T 10 -p "${xbuild_temp_dir}" "${ftpaddr}/pkgsrc.tar.xz.MD5" \
            && wget -t 10 -T 10 -p "${xbuild_temp_dir}" "${ftpaddr}/pkgsrc.tar.xz.SHA1"
        if [ $? - ne 0 ] ; then
            error "Unable to download \"pkgsrc\"."
            return 2
        fi

        if ([ "`cat "${xbuild_temp_dir}/pkgsrc.tar.xz.MD5" | cut -f 2 -d = -`" == "`md5 "${xbuild_temp_dir}/pkgsrc.tar.xz" | cut -f 2 -d = -`" ] \
                && [ "`cat "${xbuild_temp_dir}/pkgsrc.tar.xz.SHA1" | cut -f 2 -d = -`" == "`sha1 "${xbuild_temp_dir}/pkgsrc.tar.xz" | cut -f 2 -d = -`" ]); then
            file_ok="yes"
        fi
    done
    if [ "$file_ok" == "yes" ] ; then
        tar -xJvC "${netbsd_base_dir}" -f "{xbuild_temp_dir}/pkgsrc.tar.xz"
    else
        error "Downloading pkgsrc failed!"
        return 2
    fi
}

