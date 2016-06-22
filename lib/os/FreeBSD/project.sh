#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/FreeBSD/project.sh
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

################################################################################
# Project Creation
################################################################################
xb_freebsd_project_new_base() {
    #_args=$(getopt "" $*)
}

xb_freebsd_project_new_sources() {
    _args=$(getopt "CLMd:s:" $*)
    rv=$?
    local _args rv
    if [ $rv -ne 0 ] ; then
        return 2
    fi
    set -- $_args

    local src=""
    local inst=""

    while [ $# -gt 0 ]; do
        case $1 in
            -d)
                src="`echo "$2" | cut -f1 -d:`"
                case "`echo "$2" | cut -f2 -d:`" in
                    C)
                        inst="copy"
                        ;;
                    M)
                        inst="nullfs"
                        ;;
                    L)
                        inst="symlink"
                        ;;
                esac
            -C)
                inst="copy"
                shift
                ;;

            -L)
                inst="symlink"
                shift
                ;;
            -M)
                inst="nullfs"
                shift
                ;;
            -s)
                src="$2"
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done

    if [ $# -lt 1 ] ; then
        return 2
    fi
    local instdir="$1"

    : ${inst:="symlink"}
    case $inst in
        symlink)
            [ -d "${instdir}/src" ] && for i in `rm -rv "${instdir}/src"`; do
                echo "[RM] $i"
            done
            [ -e "${instdir}/src" ] && echo "[RM] `rm -v "${instdir}/src"`"
            ln -s "${XBUILD_BASEDIR}/src.${src} ${2}/src"
            ;;
        nullfs)
            [ ! -d "${instdir}/src" ] && echo "[MKDIR] `mkdir -v "${instdir}/src"`"
            echo "Writing /etc/fstab"
            xb_sudo "sh -s" << __EOFSTAB__
echo "#XBUILD:${LOGNAME}" >> /etc/fstab
echo ${XBUILD_BASE_DIR}/src.${src} ${instdir} nullfs rw,late 0 0
__EOFSTAB__
            ;;
        copy)
            ;;
    esac
}

xb_freebsd_project_new_ports() {
    _args=$(getopt "CLMd:s:" $*)
    rv=$?
    local _args rv
    if [ $rv -ne 0 ] ; then
        return 2
    fi
    set -- $_args

    local ports=""
    local inst=""

    while [ $# -gt 0 ] ; do
        case
            -C)
                inst="copy"
                shift
                ;;
            -L)
                inst="symlink"
                shift
                ;;
            -M)
                inst="nullfs"
                shift
                ;;
            -s)
                ports="$2"
                shift; shift
                ;;
            -d)
                ports="`echo "$2" | cut -f1 -d:`"
                case "`echo "$2" | cut -f2 -d:`" in
                    C)
                        inst="copy"
                        ;;
                    L)
                        inst="symlink"
                        ;;
                    M)
                        inst="nullfs"
                        ;;
                esac
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done
    if [ $# -lt 1 ] ; then
        return 2
    fi
    local instdir="$2"


}


