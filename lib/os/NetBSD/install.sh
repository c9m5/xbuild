#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/NetBSD/install.sh
# Description: Install/update functions for netbsd
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

: ${CVS_RETRIES:=5}
: ${CVS_TIMEOUT:=5}

: ${FTP_RETRIES:=5}
: ${FTP_TIMEOUT:=5}

xb_netbsd_lookup_sources() {
    if [ -z "$xbuild_netbsd_ftp_sources" ] ; then
        : ${netbsd_dirsrc_file:="${xbuild_tempdir}/netbsd-src.dir"}

        ftp -n "${netbsd_ftp_sources}/" << __EOF__
dir . ${netbsd_dirsrc_file}
bye
__EOF__
        if [ ! -r "$netbsd_dirsrc_file" ] ; then
            error "Unable to fetch sources list!"
            exit 1
        fi

        for i in `cat ${netbsd_dirsrc_file} | grep NetBSD | cut -f 9 -w -` ; do
            debug "$i"
            case $i in
                NetBSD-release-*|NetBSD-*.*)
                    xbuild_netbsd_ftp_sources="${xbuild_netbsd_ftp_sources} ${i}"
            esac
        done
    fi
}

xb_netbsd_calc_percent() {
    local x="$(( ($2 * 100) / $1 ))"

    if [ $x -gt 100 ] ; then
        echo 100
    else
        echo $x
    fi
}

xb_netbsd_gauge_percent() {
    if [ $# -eq 2 ] ; then
        cat << __EOF__
XXX
$2
$1
XXX
__EOF__
    else
        echo "$1"
    fi
}

xb_netbsd_install_sources() {
    local downdir="${XBUILD_DOWNLOADDIR}/$1"
    local instdir="${XBUILD_BASEDIR}/src.$1"

    if ([ -n "$2" ] && [ ! -d "$downdir" ]) ; then
        mkdir -vp "$downdir" 2>&1 >> "$2"
    elif [ ! -d "$downdir" ] ; then
        mkdir -vp "$downdir"
    fi

    case $1 in
        NetBSD-release-*)
            local ftp_addr="${netbsd_ftp_sources}/$1/tar_files/src"
            local xf="bin common compat config crypto dist distrib doc etc external extsrc games gnu include lib libexec regress rescue sbin share sys tests tools top-level usr.bin usr.sbin x11"
            for i in $xf; do
                local ftp_files="${ftp_files} ${i}.tar.gz.MD5 ${i}.tar.gz.SHA1 ${i}.tar.gz"
            done
            ;;
        NetBSD-*.*)
            local ftp_addr="${netbsd_ftp_sources}/$1/source/sets"
            local ftp_files="MD5 SHA512 gnusrc.tgz sharesrc.tgz src.tgz syssrc.tgz xsrc.tgz"
            ;;
        *)
            msg="Unknown target \"$1\""
            if [ -n "$2" ] ; then
                error "$msg" 2>&1 >> "$2"
            else
                error "$msg"
            fi
            return 1
            ;;
    esac

    if [ -n "$2" ] ; then
        debug "downdir=\"$downdir\"" >> "$2"
        debug "instdir=\"$instdir\"" >> "$2"
        debug "ftp_addr=\"$ftp_addr\"" >> "$2"
        debug "ftp_files=\"$ftp_files\"" >> "$2"


        local cnt=1
        local n=0
        for i in $ftp_files; do
            case $i in
                *.tgz|*.tar.gz)
                    cnt=$(( $cnt + 2 ))
                    ;;
                *)
                    cnt=$(( $cnt + 1 ))
                    ;;
            esac
        done

        for i in  $ftp_files; do
            local retries=0
            local rv=1

            n=$(( $n + 1 ))
            xb_netbsd_gauge_percent "Downloading $i ..." `xb_netbsd_calc_percent $cnt $n`

            while ([ $rv -ne 0 ] && [ $retries -le $FTP_RETRIES ]); do
                case $i in
                    *.tar.gz|*.tgz)
                        local wget_args="--progress=dot:mega"
                        ;;
                    *)
                        local wget_args="--progress=dot:default"
                        ;;
                esac
                wget ${wget_args} --tries=$FTP_RETRIES --waitretry=$FTP_TIMEOUT -a "$2" --directory-prefix="$downdir" "${ftp_addr}/$i" 2>&1 >> "$2"
                rv=$?
                if [ $rv -ne 0 ] ; then
                    error "Unable to downaload file \"$i\"!" 2>&1 >> "$2"
                    return 1
                fi

                case $i in
                    MD5|*.MD5|SHA512|*.SHA1)
                        rv=0
                        ;;
                    *.tgz)
                        if ([ "`cat "${downdir}/MD5" | grep "($i)" | cut -f 4 -w -`" == "`md5 -q "${downdir}/${i}"`" ] \
                                && [ "`cat "${downdir}/SHA512" | grep "($i)" | cut -f 4 -w -`" == "`sha512 -q "${downdir}/${i}"`" ]) ; then
                            rv=0
                            break
                        else
                            rv=1
                            echo "Checksum mismatch of file \"${downdir}/${i}\"!" >> "$2"
                            echo "[RM] `rm -v "${downdir}/${i}"`" >> "$2"
                            echo "Retrying ..." >> "$2"
                            sleep $FTP_TIMEOUT
                            continue
                        fi
                        ;;
                    *.tar.gz)
                        if ([ "`cat "${downdir}/${i}.MD5" | cut -f 4 -w -`" == "`md5 -q "${downdir}/${i}"`" ] \
                                && [ "`cat "${downdir}/${i}.SHA1" | cut -f 4 -w -`" == "`sha1 -q "${downdir}/${i}"`" ]); then
                            rv=0
                            break
                        else
                            rv=1
                            echo "Checksum mismatch of file \"${downdir}/${i}\"!" >> "$2"
                            echo "[RM] `rm -v "${downdir}/${i}"`"
                            echo "Retrying ..." >> "$2"
                            sleep $FTP_TIMEOUT
                            continue
                        fi
                        ;;
                esac
            done
            if [ $rv = 1 ] ; then
                error "Unable to download file \"${i}\"" 2>&1 >> "$2"
                return 1
            fi
        done

        if [ ! -d "${XBUILD_BASEDIR}/src.$1" ] ; then
            echo "[MKDIR] `mkdir -vp "${XBUILD_BASEDIR}/src.$1"`" 2>&1 >> "$2"
        fi

        for i in ${ftp_files}; do
            case $i in
                *.tgz)
                    n=$(( $n + 1 ))

                    xb_netbsd_gauge_percent "Extracting $i ..." `xb_netbsd_calc_percent $cnt $n`
                    echo "[EXTRACT] ${downdir}/$1" >> "$2"

                    tar -xzvf "${downdir}/$i" --strip-components 1 -C "${XBUILD_BASEDIR}/src.$1" 2>&1 >> "$2"
                    ;;
                *.tar.gz)
                    n=$(( $n + 1 ))

                    xb_netbsd_gauge_percent "Extracting $i ..." `xb_netbsd_calc_percent $cnt $n`
                    echo "[EXTRACT] /$i" >> "$2"

                    tar -xzvf "${downdir}/$i" -C "${XBUILD_BASEDIR}/src.$1" 2>&1 >> "$2"
                    ;;
            esac
        done

        n=$(( $n + 1 ))
        echo "Done" >> "$2"
        xb_netbsd_gauge_percent "Done" `xb_netbsd_clalc_percent $cnt $n`

    else # [ -z "$2" ]
        for i in  $ftp_files; do
            local retries=0
            local rv=1

            while ([ $rv -ne 0 ] && [ $retries -le $FTP_RETRIES ]); do
                wget --tries=$FTP_RETRIES --waitretry=$FTP_TIMEOUT --directory-prefix="$downdir" "${ftp_addr}/$i"
                rv=$?
                if [ $rv -ne 0 ] ; then
                    error "Unable to downaload file \"$i\"!"
                    return 1
                fi

                case $i in
                    MD5|*.MD5|SHA512|*.SHA1)
                        rv=0
                        ;;
                    *.tgz)
                        if ([ "`cat "${downdir}/MD5" | grep "($i)" | cut -f 4 -w -`" == "`md5 -q "${downdir}/${i}"`" ] \
                                && [ "`cat "${downdir}/SHA512" | grep "($i)" | cut -f 4 -w -`" == "`sha512 -q "${downdir}/${i}"`" ]) ; then
                            rv=0
                        else
                            rm "${downdir}/${i}"
                            rv=1
                        fi
                        ;;
                    *.tar.gz)
                        if ([ "`cat "${downdir}/${i}.MD5" | cut -f 4 -w -`" == "`md5 -q "${downdir}/${i}"`" ] \
                                && [ "`cat "${downdir}/${i}.SHA1" | cut -f 4 -w -`" == "`sha1 -q "${downdir}/${i}"`" ]); then
                            rv=0
                        else
                            rv=1
                        fi
                esac
            done
            if [ $rv = 1 ] ; then
                error "Unable to download file \"${i}\""
                return 1
            fi
        done

        if [ ! -d "${XBUILD_BASEDIR}/src.$1" ] ; then
            echo "[MKDIR] `mkdir -vp "${XBUILD_BASEDIR}/src.$1"`"
        fi

        for i in ${ftp_files}; do
            case $i in
                *.tgz)
                    echo "[EXTRACT] ${downdir}/$1"
                    tar -xzvf "${downdir}/$i" --strip-components 1 -C "${XBUILD_BASEDIR}/src.$1"
                    ;;
                *.tar.gz)
                    echo "[EXTRACT] ${downdir}/$1"
                    tar -xzvf "${downdir}/$i" -C "${XBUILD_BASEDIR}/src.$1"
                    ;;
            esac
        done
    fi
}

xb_netbsd_install_pkgsrc() {
    local downdir="${XBUILD_DOWNLOADDIR}"
    local downfiles="pkgsrc.tar.xz.MD5 pkgsrc.tar.xz.SHA1 pkgsrc.tar.gz"
    local instdir="${XBUILD_BASEDIR}/NetBSD.pkgsrc"

    if [ -n "$1" ] ; then
        local cnt=5
        local n=0


        debug "downfiles=\"$downfiles\"" >> "$1"
        debug "downdir=\"$downdir\"" >> "$1"
        debug "instdir=\"$instdir\"" >> "$1"


        for i in $downfiles; do
            n=$(( n + 1 ))

            xb_netbsd_gauge_percent "Downloading \"$i\" ..." `xb_netbsd_calc_percent $cnt $n`
            case $i in
                *.tar.xz.*)
                    wget --progress="dot:default" --waitretry=$FTP_TIMEOUT \
                        --tries=$FTP_RETRIES -a "$1" \
                        --directors-preifx="${downdir}" \
                        "${netbsd_ftp_pkgsrc}/${i}" 2>&1 >> "$1"

                    if [ $? -ne 0 ] ; then
                        error "Unable to download \"${i}\"!" 2>&1 >> "$1"
                        return 1
                    fi
                    ;;
                *.tar.xz)
                    wget_args=""
                    local rv=1
                    local retries=0

                    while ([ $rv -ne 0 ] && [ $retries -le $FTP_RETRIES ]) ; do
                        retries=$(( $retries + 1 ))
                        wget --progress="dot:mega" --waitretry=$FTP_TIMEOUT \
                            --tries=$FTP_RETRIES -a "$1" \
                            --directors-preifx="${downdir}" \
                            "${netbsd_ftp_pkgsrc}/${i}" 2>&1 >> "$1"
                        rv=$?

                        if ([ $rv -eq 0 ] \
                                && [ "`cat "${downdir}/${i}.MD5" | grep "$i" | cut -f 3 -w -`" == "`md5 "${downdir}/${i}" | cut -f 3 -w -`" ] \
                                && "`cat "${downdir}/${i}.SHA1" | grep "$i" | cut -f 3 -w -`" == "`sha1 "${downdir}/${i}" | cut -f 3 -w -`" ]) ; then
                            rv=0
                        else
                            rv=1
                            sleep $FTP_TIMEOUT
                        fi
                    done
                    if [ $rv -ne 0 ] ; then
                        error "Unable to download \"${i}\"!" 2>&1 >> "$1"
                        return 1
                    fi
                    n=$(( n + 1 ))
                    xb_netbsd_gauge_percent "Extracting \"$i\" ..." `xb_netbsd_calc_percent $cnt $n`
                    tar -xJvf "${downdir}/$i" --strip-components 1 -C "${instdir}" 2>&1 >> "$1"
                    ;;
            esac
        done
        xb_netbsd_gauge_percent "Done" 100
    else # [ -z "$1" ]
        local wget_args="--waitretry=$FTP_TIMEOUT --tries=$FTP_RETRIES --directory-prefix='${downdir}'"
            for i in $downwnfiles; do
            case $i in
                *.tar.xz.*)
                    #wget_args="${wget_args} --progress=dot:default"
                    wget ${wget_args} "${netbsd_ftp_pkgsrc}/${i}" >> "$1"
                    if [ $? -ne 0 ] ; then
                        return 1
                    fi
                    ;;
                *.tar.xz)
                    #wget_args="${wget_args} --progress=dot:mega"
                    local rv=1
                    local retries=0

                    while ([ $rv -ne 0 ] && [ $retries -le $FTP_RETRIES ]) ; do
                        retries=$(( $retries + 1 ))
                        wget ${wget_args} "${netbsd_ftp_pkgsrc}/${i}"
                        rv=$?

                        if ([ $rv -eq 0 ] \
                                && [ "`cat "${downdir}/${i}.MD5" | grep "$i" | cut -f 3 -w -`" == "`md5 "${downdir}/${i}" | cut -f 3 -w -`" ] \
                                && "`cat "${downdir}/${i}.SHA1" | grep "$i" | cut -f 3 -w -`" == "`sha1 "${downdir}/${i}" | cut -f 3 -w -`" ]) ; then
                            rv=0
                        else
                            rv=1
                            sleep $FTP_TIMEOUT
                        fi
                    done
                    if [ $rv -ne 0 ] ; then
                        error "Unable to download \"${i}\"!"
                        return 1
                    fi
                    tar -xJvf "${downdir}/$i" --strip-components 1 -C "${instdir}"
                    ;;
            esac
        done
    fi
}

