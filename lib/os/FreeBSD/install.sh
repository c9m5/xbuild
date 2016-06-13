#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/FreeBSD/install.sh
# Description: install functions for FreeBSD
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


xb_freebsd_lookup_sources() {
    #: ${FREEBSD_SRC_RELENG_ENABLE:="no"}
    : ${FREEBSD_SRC_ATLEAST_VERSION:=10}

    local svn_src="release stable releng"

    echo "head:FreeBSD-CURRENT"

    for i in $svn_src; do
        case $i in
            release)
                local name_suffix="RELEASE"
                ;;
            stable)
                local name_suffix="STABLE"
                ;;
            releng)
                local name_suffix="RELENG"
                ;;
        esac


        #for s in `"svn" ls "https://svn.freebsd.org/base/${i}"`; do
        for s in `"${XBUILD_SVN}" ls "${freebsd_svn}/base/${i}"`; do
            local x=$(echo "$s" | cut -f 1 -d "/" - | cut -f 1 -d . -)
            local ver=$(echo "$s" | cut -f 1 -d "/" -)

            case $ver in
                ALPHA*) ;;
                BETA*) ;;
                1*|2*|3*|4*|5*|6*|7*|8*|9*)
                    if [ $x -ge "$FREEBSD_SRC_ATLEAST_VERSION" ] ; then
                        echo "${i}/${ver}:FreeBSD-${ver}-${name_suffix}"
                    fi
                    ;;
            esac
        done
    done
}

xb_freebsd_install_sources() {
    case $1 in
        head)
            local srcdir="src.FreeBSD-CURRENT"
            ;;
        release/*)
            local srcdir="src.FreeBSD-`echo "${1}" | cut -f 2 -d / -`-RELEASE"
            ;;
        stable/*)
            local srcdir="src.FreeBSD-`echo "${1}" | cut -f 2 -d / -`-STABLE"
            ;;
        releng/*)
            local srcdir="src.FreeBSD-`echo "${1}" | cut -f 2 -d / -`-RELENG"
            ;;
        *)
            echo "Unknown target $1" >&2
            return 1
            ;;
    esac

    echo "INSTALLING `echo $srcdir | cut -f 2 -d . -`"
    if [ ! -d "${XBUILD_BASEDIR}/${srcdir}" ] ; then
        mkdir -p "${XBUILD_BASEDIR}/${srcdir}"
    fi
    local retries=0

    local rv=1
    while ([ $rv -ne 0 ] && [ $retries -le $SVN_RETRIES ]) ; do
        retries=$(( $retries + 1 ))
        $XBUILD_SVN checkout "${freebsd_svn}/base/$1" "${XBUILD_BASEDIR}/${srcdir}"
        rv=$?
    done
    return $rv
}

xb_freebsd_update_sources() {
 for i in `ls "${XBUILD_BASEDIR}/src.FreeBSD-*"`; do
    cd "${XBUILD_BASEDIR}/${i}"
    $XBUILD_SVN update .
    cd -
 done
}


xb_freebsd_install_ports() {
    : ${SVN_RETRIES:=10}
    : ${SVN_RETRY_SLEEP:=5}

    case $1 in
        svn)
            if [ ! -d "${XUILD_BASEDIR}/FreeBSD.ports" ] ; then
                mkdir -p "${XBUILD_BASEDIR}/FreeBSD.ports"
            fi
            local n=0
            local rv=1
            while ([ $rv -ne 0 ] && [ $n -le $SVN_RETRIES ]) ; do
                n=$(( $n + 1 ))
                "$XBUILD_SVN" checkout "${freebsd_svn}/ports/head" "${XBUILD_BASEDIR}/FreeBSD.ports"
                rv=$?
                if [ $rv -ne 0 ] ; then
                    sleep $SVN_RETRY_SLEEP
                fi
            done
            ;;
        portsnap)
            local dirs="FreeBSD.ports FreeBSD.portsnap.db FreeBSD.distfiles"
            for i in $dirs ; do
                if [ ! -d "${XBUILD_BASEDIR}/${i}" ] ; then
                    echo "[mkdir] ${XBUILD_BASEDIR}/${i}"
                    mkdir -p "${XBUILD_BASEDIR}/${i}"
                fi
            done
            portsnap -d "${XBUILD_BASEDIR}/FreeBSD.portsnap.db" -p "${XBUILD_BASEDIR}/FreeBSD.ports" fetch extract
            rv=$? ; local rv
            ;;
    esac
    return $rv
}

xb_freebsd_update_ports() {
    : ${FREEBSD_PORTSDIR:="${XBUILD_BASEDIR}/FreeBSD.ports"}
    : ${FREEBSD_PORTSNAP_WORKDIR:="${XBUILD_BASEDIR}/FreeBSD.portsnap.db"}
    : ${SVN_RETRIES:=10}
    : ${SVN_RETRY_SLEEP:=5}

    if [ -d "$FREEBSD_PORTSDIR/.svn" ] ; then
        cd "$FREEBSD_PORTSDIR"
        "$XBUILD_SVN" update
        cd -
    else
        portsnap -d "$FREEBSD_PORTSNAP_WORKDIR" -p "$FREEBSD_PORTSDIR" update
    fi
}

xb_freebsd_install_doc() {
    : ${SVN_RETRIES:=10}
    : ${SVN_RETRY_SLEEP:=5}
    : ${FREEBSD_DOCDIR:="${XBUILD_BASEDIR}/FreeBSD.doc"}

    if [ ! -d "$FREEBSD_DOCDIR" ] ; then
        echo "[mkdir] $FREEBSD_DOCDIR "
        mkdir -p "$FREEBSD_DOCDIR"
    fi
    local n=0
    local rv=1
    while ([ $rv -ne 0 ] && [ $n -le $SVN_RETRIES ]) ; do
        n=$(( $n + 1 ))
        "$XBUILD_SVN" checkout "${freebsd_svn}/doc/head" "$FREEBSD_DOCDIR"
        rv=$?
        if [ $rv -ne 0 ] ; then
            sleep $SVN_RETRY_SLEEP
        fi
    done
    return $rv
}

xb_freebsd_update_doc() {
    : ${FREEBSD_DOCDIR:="${XBUILD_BASEDIR}/FreeBSD.doc"}
    cd "$FREEBSD_DOCDIR"
    "$XBUILD_SVN" update .
    cd -
}

