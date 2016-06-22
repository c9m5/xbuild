#!/bin/sh
#
# Author(s): c9m5
# File: xbuild/os/NetBSD/dialogs.sh
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
#

################################################################################
# Installers
################################################################################

xb_netbsd_install_sources_dialog() {
    # lookup sources by ftp

    if [ -z "$xbuild_netbsd_ftp_sources" ] ; then
        clear
        xb_netbsd_lookup_sources
    fi
    debug "xbuild_netbsd_ftp_sources=$xbuild_netbsd_ftp_sources"

    instsrc=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
        --title "NetBSD Sources" --no-items \
        --checklist "Select Sources to install:" 20 30 10 \
            $(for i in $xbuild_netbsd_ftp_sources; do
                echo -n "${i} off "
            done) )
    rv=$?
    local instsrc
    if [ $rv -eq 0 ] ; then
        local ofile="${xbuild_tempdir}/netbsd.install.src.log"
        local mw="`dialog --stdout --print-maxsize | cut -f3 -w -`"
        local mh="`dialog --stdout --print-maxsize | cut -f2 -w - | cut -f 1 -d , -`"
        local w=$(( mw - 6 ))


        for i in $instsrc; do
            echo "instsrc=\"$instsrc\"" >> "$ofile"
            echo "Installing: $i" >> "$ofile"
            xb_netbsd_install_sources "$i" "${ofile}" | dialog --backtitle "${xbuild_dialog_backtitle}" \
                --begin 3 $(( ($mw - $w) / 2 )) --title "Installing NetBSD Sources" \
                --tailboxbg "${ofile}" $(( $mh - 12 )) $w \
                --and-widget --keep-window --title "Progress" \
                --begin $(( $mh - 9 )) $(( ($mw - $w) / 2 )) \
                --gauge "Installing NetBSD Sources ..." 6 $w 0
        done
    else
        return $rv
    fi
}

xb_netbsd_install_pkgsrc_dialog() {
    local mw="`dialog --stdout --print-maxsize | cut -f3 -w -`"
    local mh="`dialog --stdout --print-maxsize | cut -f2 -w - | cut -f 1 -d , -`"
    local w=$(( mw - 6 ))

    clear
    xb_netbsd_lookup_pkgsrc

    for i in $xbuild_netbsd_ftp_pkgsrc; do
        local pkgsrc_latest="$i"
    done

    debug "$xbuild_netbsd_ftp_pkgsrc"
    sleep 5
    x=$(dialog --stdout --backtitle "${xbuild_idalog_backtitle}" \
        --title "NetBSD pkgsrc" --no-items \
        --radiolist "Please select pkgsrc snapshot to install:" 13 40 5 \
            $(for i in $xbuild_netbsd_ftp_pkgsrc; do
                if [ "$i" != "$pkgsrc_latest" ] ; then
                    echo "$i off"
                else
                    echo "$i on"
                fi
            done) )
    rv=$?
    local rv x

    if [ $rv -eq 0 ] ; then
        : ${x:="$pkgsrc_latest"}
        local ofile="${xbuild_tempdir}/netbsd.install.pkgsrc.log"

        echo "Installing pkgsrc ..." > "$ofile"
        xb_netbsd_install_pkgsrc "$x" "${ofile}" | dialog --backtitle "${xbuild_dialog_backtitle}" \
            --begin 3 $(( ($mw - $w) / 2 )) --title "Installing NetBSD Sources" \
            --tailboxbg "${ofile}" $(( $mh - 12 )) $w \
            --and-widget --keep-window --title "Progress" \
            --begin $(( $mh - 9 )) $(( ($mw - $w) / 2 )) \
            --gauge "Installing NetBSD pkgsrc ..." 6 $w 0
        rv=$?
    fi
    return $rv
}

xb_netbsd_install_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
            --title "NetBSD Install" \
            --menu "Select items you want to install" 12 30 5 \
                "X" "Exit" \
                "1" "Install Sources" \
                "2" "Install PKGSRC")
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    break ;;
                1)
                    xb_netbsd_install_sources_dialog
                    ;;
                2)
                    xb_netbsd_install_pkgsrc_dialog
                    ;;
            esac
        fi
    done
}


################################################################################
# Project
################################################################################



