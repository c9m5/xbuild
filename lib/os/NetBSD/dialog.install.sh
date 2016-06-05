#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/NetBSD/install.sh
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

netbsd_dialog_install_sources() {
    clear
    netbsd_lookup_sources

    tmpfile="${xbuild_tmp_dir}/netbsdsrcinstdlg.tmp"; local tmpfile

    listitems=""; local listitems

    if [ "`netbsd_have_system_sources`" == "yes" ] ; then
        listitens="\"system\" \"System Sources\" on"
    fi

    for i in $netbsd_sources; do
        case $i in
            *-release-*)
                listitems="${listitems} release-`echo "$i" | cut -f 3 -d '-' -` $i off"
                ;;
            *)
                listitems="${listitems} `echo "$i" | cut -f 2 -d '-' -` $i off"
                ;;
        esac
    done

    netbsd_sources=$(dialog --stdout \
        --backtitle "$xbuild_dialog_backtitle" \
        --title "NetBSD Sources" \
        --checklist "Please choose NetBSD sources to install." 18 40 12 \
            ${listitems})
    rv=$?;
    local rv netbsd_sources

    if ([ $rv -ne 0 ] || [ -z "$netbsd_sources" ]) ; then
        if [ $rv -ne 0 ] ; then
            msg="Installation of NetBSD sources was cnaceled.\n\n"
        else
            msg="No sources to install selected.\n\n"
        fi
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "NetBSD Sources Canceled" \
            --extra-button --extra-label "Sources" \
            --ok-label "Restart" --cancel-label "Exit" \
            --yesno "${msg}Do you want to <Restart> the installer, reslect <Sources>, or <Exit> the installer?" 10 50
        rv=$?
        case $rv in
            1)
                exit ;;
            3)
                return 1 ;;
            0|*)
                return 2 ;;
        esac
    fi

    for i in $netbsd_sources; do
        install_add_target netbsd_install_sources "NetBSD-${i} Sources" "$i"
    done
}

netbsd_dialog_install_pkgsrc() {
    dialog --backtitle "$xbuild_dialog_backtitle" \
        --title "NetBSD pkgsrc" \
        --yesno "Do you want to install pkgsrc?" 6 50
    case $? in
        0)
            install_pkgsrc="yes"; local install_pkgsrc
            ;;
        1)
            install_pkgsrc="no"; local install_pkgsrc
            ;;
        *)
            return 1
    esac

    if [ "$install_pkgsrc" == "yes" ] ; then
        install_add_target netbsd_install_pkgsrc "NetBSD pkgsrc"
    fi
}

netbsd_dialog_install_doc() {
    netbsd_doc=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "NetBSD documentation" \
        --checklist "Please select the NetBSD Documentation you want to install." 15 50 4 \
            "html" "HTML documentation" off \
            "html1" "Single html file" off \
            "pdf"   "Documentation in PDF-format." off \
            "ps"    "Documentation in postscript format" off)
    rv=$?; local rv
    if [ $rv -ne 0 ] ; then
        dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "NetBSD Documentation Installer aborted!" \
            --extra-button --extra-label "Documentation" \
            --ok-label "Restart" --cancel-label "Exit" \
            --yesno "Installation of NetBSD documenation was canceled!\n\nDo you want to <Restart> the installer, rerun the <Documentation> dialog or <Exit> the installer?" 10 50

        case $? in
            1)
                exit ;;
            3)
                return 1 ;;
            0|*)
                return 2 ;;
        esac
    fi

    if [ ! -z "$netbsd_doc" ] ; then
        for i in $netbsd_doc; do
            install_add_target netbsd_install_doc "NetBSD Documentation" "$i"
        done
    fi
}

netbsd_dialog_install() {
    rv=1; local rv
    while [ $rv -eq 1 ] ; do
        netbsd_dialog_install_sources
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi

    rv=1
    while [ $rv -eq 1 ] ; do
        netbsd_dialog_install_pkgsrc
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi

    rv=1
    while [ $rv -eq 1 ] ; do
        netbsd_dialog_install_doc
        rv=$?
    done
    if [ $rv -ne 0 ] ; then
        return 1
    fi
}

