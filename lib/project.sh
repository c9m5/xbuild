#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/project.sh
# Description: Project Functions
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

__prj_create_ncmd=0

################################################################################
# Project creation
################################################################################

xb_mk_base() {
    _args="`getopt "O:B:d:" $*`"
    if [ $? -ne 0 ] ; then
        return 2
    fi
    set -- _args
    local _args

    while [ $# -gt 0 ] ; do
        case $1 in
            -O)
                prj_os="$2"
                shift; shift
                ;;
            -B)
                prj_board="$2"
                shift; shift
                ;;
            -D)
                prj_desc="${2}"
                shift; shift
                ;;
            -d)
                prj_dir="$2"
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done
    if [ -z "$1" ] ; then
        return 2
    fi
    project_dir="${XBUILD_ROOT}/${1}"

    if [ -d "${XBUILD_ROOT}/${1}" ] ; then
        echo "[MKDIR]  `mkdir -vp "${prj_dir}"`"
    fi

    # creating skeleton
    for i in `cp -fRv ${xbuild_skeldir}`; do
        echo "[CP] ${i}"
    done

    # creating initial config
    prj_configdir="${prj_dir}/config"
    prj_configfile="${prj_configdir}/xbuild.conf"
    echo "[FILE] ${prj_dir}/config/"
    cat >> "${prj_configfile}" << __EOF__
PRJ_NAME="${prj_name}"
: ${PRJ_DIR:="${prj_dir}"}
: ${PRJ_ROOT:="\${XBUILD_ROOT}/\${PRJ_DIR}"}
PRJ_CONFIGDIR="\${PROJECT_ROOT}/config"
PRJ_DESCRIPTION="${prj_desc}"
PRJ_OS="${prj_os}"
PRJ_BOARD="${prj_board}"
__EOF__
}



xb_project_new_reset_commands() {
    local n=${__PRJ_CREATE_CMD};
    local subn=0
    while [ $n -gt 0 ] ; do
        n=$(( $n - 1 ))
        subn=0
        local nsubcmd=$(eval echo "$`echo "__PRJ_CREATE_SUBCMD{n}"`")
        unset "__PRJ_CREATE_CMD${n}" "__PRJ_CREATE_MSG${n}" "__PRJ_CREATE_SUBCMD${n}"

        while [ $subn -lt $nsubcmd ] ; do
            unset "__PRJ_CREATE_CMD${n}_${subn}" "__PRJ_CREATE_MSG${n}_${subn}"
        done

    done
    __prj_create_ncmd=0
}
__prj_create_subcmd=0

# $1 desc
# $2 CMD
xb_project_new_add_cmd() {

    _args="`getopt "m:" $*`"
    [ $? -ne 0 ] && return 2
    local _args
    set -- $_args

    while [ $# -gt 0 ] ; do
        case $1 in
            -m)
                eval "__PRJ_CREATE_MSG${__PRJ_CREATE_CMD}=\"$2\""
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done

    eval "__PRJ_CREATE_CMD${__PRJ_CREATE_CMD}=$*"
    eval "__PRJ_CREATE_SUBCMD${__PRJ_CREATE_CMD}=0"

    __PRJ_CREATE_CMD=$(( $__PRJ_CREATE_CMD  + 1 ))
}

xb_project_new_add_subcmd() {
    _args="`getopt "n:m:" $*`"
    if [ $? -ne 0 ] ; then
        return 2
    fi
    local _args
    set -- $_args

    local msg=""
    local cmdn="`[ $(( $__PRJ_CREATE_CMD - 1 )) -gt 0 ] && echo $(( $__PRJ_CREATE_CMD - 1 )) || echo 0`"
    while [ $# -gt 0 ] ; do
        case $1 in
            -n)
                if ([ $2 -lt $_PRJ_CREATE_CMD ] && [ $2 -ge 0 ]); then
                    cmdn="$2"
                elif ([ $2 -lt 0 ]); then
                    cmdn="`[ $(( $__PRJ_CREATE_CMD - 1  -gt 0 )) ] && echo $(( $__PRJ_CREATE_CMD - 1 )) || echo 0`"
                else
                    cmdn="`[ $(( $__PRJ_CREATE_CMD - 1 )) -gt 0 ] && echo $(( $__PRJ_CREATE_CMD -1 )) || echo 0`"
                fi
                shift; shift
                ;;
            -m)
                msg="$2"
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done
    # no command defined
    if [ $__PRJ_CREATE_CMD -lt 1 ] ; then
        error "No Command set"
        return 1
    fi


    local subcmdn=$(eval echo "$`echo "__PRJ_CREATE_SUBCMD${ncmd}"`")

    eval "__PRJ_CREATE_CMD${cmdn}_${subcmdn}=${*}"
    eval "__PRJ_CREATE_DESC${cmdn}_${subcmdn}=${msg}"
    subcmdn=$(( $subcmdn + 1 ))
    eval "__PRJ_CREATE_SUBCMD${cmdn}=${subcmdn}"
}

xb_project_dlgcreate() {
    local n=0
    local subn=0
    local perc=0
    local ofile="$1"
    : "${ofile:=/dev/null}"

    local cmd_redir="2>&1"
    local cmd_out=">> \"$ofile\""

    while [ $n -lt $__PRJ_CREATE_CMD ] ; do
        subn=0

        local CMD=$(eval echo "$`echo "__PRJ_CREATE_CMD${n}"`")
        local MSG=$(eval echo "$`echo "__PRJ_CREATE_DESC${n}"`")
        : ${MSG:="Creating Project ..."}
        echo "[${xbuild_gauge_min_percent}] $MSG" >> "$ofile"
        perc=$(xbuild_calc_perc $__PRJ_CREATE_CMD $n)
        cat << __EOF__
XXX
${perc}
${MSG}
XXX
__EOF__
        eval "`echo $CMD` ${cmd_redir} ${cmd_out}"

        nsubcmd=$(eval echo "$`echo "__PRJ_CREATE_SUBCMD${n}"`")
            while [ $subn -lt $nsubcmd ] ; do
                perc=$(xb_calc_step_perc $__PRJ_CREATE_CMD $n $nsubcmd $subn)
                local SCMD=$(eval echo "$`echo "__PRJ_CREATE_CMD${n}_${subn}"`")
                local SMSG=$(eval echo "$`echo "__PRJ_CREATE_DESC${n}_${subn}"`")
                if [ -z "SMSG" ] ; then
                    SMSG=${MSG}
                fi
                cat << __EOF__
XXX
${perc}
${SMSG}
XXX
__EOF__
            eval "`echo $SCMD` ${cmd_redir} ${cmd_out}"
            subn=$(( $subn + 1 ))
        done
        $n=$(( $n + 1 ))
    done
    cat << __EOF__
XXX
100
DONE
XXX
__EOF__
}

#prj_name=""
#prj_dir=""
#prj_os=""
xb_project_create() {
    _args="`getopt "" $*`"
    if [ $? -ne 0 ] ; then
        return 1
    fi
    set -- $_args
    local _args


    #if [ -z "$1" ] ; then
    #    error "No Project name set!"
    #    exit 2
    #fi

#    local prj="$1"
#    if [ -d "${XBUILD_ROOT}/$prj" ] ; then
#        error "Project \"${prj}\" exists!"
#        exit 1
#    fi
#
#    echo "[MKDIR] `mkdir -vp "${XBUILD_ROOT}/${prj}"`"
#    cp -vRf "${XBUID_BASEDIR}/skel/" "${XBUILD_ROOT}/prj/"
}


