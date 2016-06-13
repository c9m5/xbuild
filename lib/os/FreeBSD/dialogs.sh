#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/FreeBSD/config.sh
# Description: Freebsd dialogs
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

xb_freebsd_install_sources_dialog() {
    for i in `xb_freebsd_lookup_sources`; do
        local listitems="${listitems} `echo $i | cut -f 1 -d : -` `echo $i | cut -f 2 -d : -` off"
    done
    x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
        --title "FreeBSD Sources" \
        --checklist "Please select FreeBSD-sources to install:"  20 50 15 `builtin echo ${listitems}`)
    rv=$?
    local x
    echo x
    ofile="${xbuild_tempdir}/freebsd.install.log"

    if [ $rv -eq 0 ] ; then
        local mh=`dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -`
        local mw=`dialog --stdout --print-maxsize | cut -f 3 -w -`
        w=$(( $mw - 6 ))
        local cnt=0
        for i in $x ; do
            cnt=$(( cnt + 1 ))
        done

        local n=0
        for i in $x ; do
            n=$(( $n + 1 ))
            local perc=$(( (100 * $n) / $cnt ))
            if [ $perc -gt 100 ] ; then
                perc=100
            fi
            case $i in
                head)
                    local str="FreeBSD-CURRENT"
                    ;;
                release/*)
                    local str="FreeBSD-${i##release/}-RELEASE"
                    ;;
                stable/*)
                    local str="FreeBSD-${i##stable/}-STABLE"
                    ;;
                releng/*)
                    local str="FreeBSD-${i##releng/}-RELENG"
                    ;;
            esac
            cat << EOF
XXX
${perc}
Installing ${str} ...
XXX
EOF
            xb_freebsd_install_sources $i >> $ofile
        done | dialog --backtitle "${xbuild_dialog_backtitle}" \
            --begin 3 $(( ($mw - $w) / 2 )) \
            --title "Installing FreeBSD Sources" \
            --tailboxbg "$ofile"  $(( $mh - 12 ))  $w \
            --and-widget --keep-window --begin $(( $mh - 9 )) $(( ($mw - $w) / 2 )) \
            --title "Progress" --gauge "Installing FreeBSD Sources" 6 $w 0
    fi
}

xb_freebsd_install_ports_dialog() {
    x=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
        --title "FreeBSD Ports" \
        --radiolist "Please select the installation source"  12 40 2 \
            "portsnap"  "Install with portsnap" on \
            "svn"       "Subversion"    off)
    rv=$?
    if [ $rv -eq 0 ] ; then
        local h=$(( `dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -` - 8 ))
        local w=$(( `dialog --stdout --print-maxsize | cut -f 3 -w -` - 6 ))

        xb_freebsd_install_ports $x 2>&1 | dialog --backtitle "$xbuild_dialog_backtitle" \
            --title "Installing FreeBSD Ports" --programbox $h $w
    fi
}

xb_freebsd_install_doc() {
    local h=$(( `dialog --stdout --print-maxsize | cut -f 2 -w - | cut -f 1 -d ',' -` - 8 ))
    local w=$(( `dialog --stdout --print-maxsize | cut -f 3 -w -` - 6 ))

    xb_freebsd_install_doc 2>&1 | dialog --backtitle "$xbuild_dialog_backtitle" \
        --title "Installing FreeBSD Documentation" --programbox $h $w
}

xb_freebsd_install_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        x=$(dialog --stdout --backtitle "$xbuild_dialog_backtitle" \
            --title "FreeBSD Install" \
            --menu "FreeBSD Install Menu" 12 30 5 \
                "X" "Exit" \
                "1" "Install Sources" \
                "2" "Install Ports" \
                "3" "Install Documentation")
        rv=$?
        local x
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    break;;
                1)
                    xb_freebsd_install_sources_dialog
                    ;;
                2)
                    xb_freebsd_install_ports_dialog
                    ;;
                3)
                    xb_freebsd_install_doc
                    ;;
            esac
        fi
    done
    return $rv
}


