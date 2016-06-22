#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/dialogs.sh
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
# Misc Dialogs
################################################################################

xb_dialog_sudo_passwd() {
    : ${__xbuild_sudo_passwd_set:="no"}
    : ${SUDO_TRIES:=3}
    __xbuild_sudo_passwd=""

    if [ "$__xbuild_sudo_passwd_set" == "no" ] ; then
        local tries=0
        local rv=0
        local ret=0

        while ([ $rv -eq 0 ] && [ "$__xbuild_sudo_passwd_set" == "no" ] && [ $tries -lt $SUDO_TRIES ]); do

            tries=$(( $tries + 1 ))
            __xbuild_sudo_passwd=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
                --title "Password" --insecure --passwordbox "Please enter your password." 6 40)
            ret=$(echo "$__xbuild_sudo_passwd" | sudo  -S sh -s << EOF
echo "yes"
EOF
)
            [ $? -eq 0 ] && [ "$ret" = "yes" ] && __xbuild_sudo_passwd_set="yes"
        done
    fi
    [ "$__xbuild_sudo_passwd_set" == "yes" ] && echo "$__xbuild_sudo_passwd"
}

################################################################################
# Board Dialogs
################################################################################

xb_dialog_select_board() {
    local default="$1"
    ifs0="$IFS"
    IFS=""\\n
    boarditems=
    IFS="$ifs0"

    board=$(eval dialog --clear --stdout "--backtitle \"${xbuild_dialog_backtitle}\"" \
        "--title \"Select Board\"" \
        "--radiolist \"Please selet a Board.\" 12 50 6" \
            $(for i in `cat ${xbuild_boardlist_file}`; do
                local bid="`echo -n "$i" | cut -f${BOARDLISTID_ID} -d:`"
                local bname="`echo -n "$i" | cut -f${BOARDLISTID_NAME} -d:`"
                local bstatus="off"
                [ "$default" == "$bid" ] && bstatus="on"
                [ -n "$bid" ] && [ -n "$bname" ] && echo -n "\"${bid}\" \"${bname}\" \"$bstatus\" "
            done) )
    rv=$?
    local board

    [ $rv -eq 0 ] && [ -n "$board" ] && echo "$board"

    return $rv
}

################################################################################
# OS-Dialogs
################################################################################

xb_dialog_select_os() {
    _args="`getopt "b:" $*`"
    [ $? - ne 0 ] && return 2
    local _args
    set -- $_args

    local _oslist=""

    while [ $# -gt 0 ] ; do
        case $1 in
            -b)
                local bid="`cat ${xbuild_boardlist_file} | grep "$2" | cut -f$BOARDLISTID_ID -d:`"
                local bname="`cat ${xbuild_boardlist_file} | grep "$2" | cut -f$BOARDLISTID_NAME -d:`"
                local bos="`cat ${xbuild_boardlist_file} | grep "$2" | cut -f$BOARDLISTID_OSLIST -d:`"
                local n=1;
                while [ -n "`echo -n $bos | cut -f$n -d$BOARD_OSLIST_SEPARATOR`" ] ; do
                    _oslist="${_oslist} `echo $bos | cut -f$n -d$BOARD_OSLIST_SEPARATOR`"
                    n=$(( $n + 1 ))
                done
                shift; shift
                ;;
            --)
                shift; break
                ;;
        esac
    done
    [ -z "$_oslist" ] && _oslist="`xb_list_os`"

    local rlmsg="Please select an Operating System."
    local dlg_args="--stdout --backtitle \"${xbuild_dialog_backtitle}\" --title \"Operating System\" --no-items --radiolist \"${rlmsg}\" 9 30 4"
    local ositems=$(for i in $_oslist; do
            local st="off"
            [ "$i" == "$1" ] && st="on"
            echo -n "\"${i}\" ${st} "
        done)
    os=$(eval dialog ${dlg_args} ${dlg_args} ${ositems})
    rv=$?
    local os rv
    [ $rv -eq 0 ] && echo "$os"
    return $rv
}

################################################################################
# Installer
################################################################################

xb_install_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
            --title "Install Components" \
            --menu "Install additional components:" 12 30 5 \
                "X" "Exit" \
                "F" "FreeBSD" \
                "N" "NetBSD")
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    return 0
                    ;;
                F)
                    xb_freebsd_install_menu
                    ;;
                N)
                    xb_netbsd_install_menu
                    ;;
            esac
        fi
    done
}

################################################################################
# Project Management
################################################################################

xb_projects_list_dialog() {
    prjlist=$(for i in `ls "$XBUILD_ROOT"`; do
        if [ -e "${XBUILD_ROOT}/${i}/XBUILD_PROJECT" ] ; then
            echo "'$i'"
        fi
    done)

    echo $prjlist

    local rv=0
    x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "XBuild Projects" \
        --radiolist "Please select a Project." 20 50 12 \
            $(for i in `ls ${XBUILD_ROOT}`; do
                local prjdir="${XBUILD_ROOT}/$i"
                if ([ -e ${prjdir}/XBUILD_PROJECT ] && [ -r "${prjdir}/config/project.rc" ]) ; then
                    . "${prjdir}/config/project.rc"
                    echo -n "'$i' '${PROJECT_NAME:=$i}' off "
                fi
            done) )
    rv=$?
    local x

    return rv
}



xb_dialog_project_new() {
    prj_name=""
    prj_dir=""
    prj_os=""
    prj_board=""
    prj_desc=""

    local restart_dialog="yes"

    while [ "$restart_dialog" == "yes" ] ; do
        x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
            --title "New Project" --output-separator '|'\
            --form "Project Data:" 10 50 4 \
                "Title:" 1 1 "$prj_name" 1 14 40 0 \
                "Directory:" 2 1 "$prj_dir" 2 14 40 0 \
                "Board:" 3 1 "$prj_board" 3 14 40 0 \
                "Description:" 4 1 "$prj_desc" 4 14 40 0)
        rv=$?

        local rv x
        if [ $rv -ne 0 ] ; then
            restart_dialog="no"
            return $rv;
        fi

        prj_name="`echo $x | cut -f 1 -d '|' -`"
        prj_dir="`echo $x | cut -f 2 -d '|' -`"
        prj_board="`echo $x | cut -f 3 -d '|' -`"
        prj_desc="`echo $x | cut -f 4 -d '|' -`"

        clear
        debug "prj_name=$prj_name"
        debug "prj_dir=$prj_dir"
        debug "prj_board=$prj_board"
        debug "prj_desc=$prj_desc"
        sleep 2

        if [ -z "$prj_dir" ] ; then
            dialog --backtitle "$xbuild_dialog_backtitle" \
                --title "ERROR: Directory" \
                --msgbox "Directory must not be an emtpy string!" 6 40
            continue
        fi
        [ -z "$prj_name" ] && prj_name="$prj_dir"


        prj_board=$(xb_dialog_select_board "${prj_board}")
        ([ $? -ne 0 ] || [ -z "$prj_board" ]) && continue


        # Select an OS for building.
        prj_os=$(xb_dialog_select_os -b "${prj_board}" "${prj_os}")
        if ([ $? -eq 0 ] && [ -n "$prj_os" ]) ; then
            local osfuncprefix="`xb_os_get_funcprefix $prj_os`"
            local osvarprefix="`xb_os_get_varprefix "$prj_os"`"
        else
            continue
        fi


        xb_project_new_add_cmd -m "Creating Project Base..." \
            "xb_project_new_base -B \"${prj_board}\" -O \"${prj_os}\" -d \"${prj_dir}\" -D \"${prj_desc}\""

        local prj_enable=$(eval echo -n "$`echo -n "${osvarprefix}"`_dialog_project_new_enable")
        if ([ "`xb_is_true $prj_enable`" == "yes" ]); then
            eval "$`echo -n "${osfuncprefix}"`_dialog_project_new"
        fi
    done
}

xb_project_management_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "$xbuild_Dialog_backtitle" \
            --title "Project Management" \
            --menu "Project Management" 12 40 5\
                "X" "Exit" \
                "N" "Create New Project" \
                "O" "Open an existing project" \
                "D" "Delete a project"
        )
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    break;;
                N)
                    xb_dialog_project_new
                    ;;
                O)
                    ;;
                D)
                    ;;
            esac
        fi
    done
}

################################################################################
# Main menu
################################################################################

xb_main_menu() {
    rv=0; local rv
    x=""; local x

    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
                --title "XBuild" \
                --menu "XBuild Main Menu" 12 30 5\
                    "X" "Exit" \
                    "P" "Projects" \
                    "C" "Configure XBuild" \
                    "I" "Install Components")
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    break
                    ;;
                1)
                    #xb_create_project_dialog
                    ;;
                C)
                    #configure_menu
                    ;;
                I)
                    xb_install_menu
                    ;;
                P)
                    xb_project_management_menu
                    ;;
            esac
        fi
    done
}



