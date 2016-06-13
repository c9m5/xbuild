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

xb_install_menu() {
    local rv=0
    while [ $rv -eq 0 ] ; do
        local x=$(dialog --stdout --backtitle "${xbuild_dialog_backtitle}" \
            --title "Install Components" \
            --menu "Install additional components:" 12 30 5 \
                "X" "Exit" \
                "F" "FreeBSD")
        rv=$?
        if [ $rv -eq 0 ] ; then
            case $x in
                X)
                    return 0
                    break;;
                F)
                    xb_freebsd_install_menu
                    ;;
            esac
        fi
    done
}

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
                    break;;
                C)
                    #configure_menu
                    ;;
                I)
                    xb_install_menu
                    ;;
                P)
                    #projects_menu
                    ;;
            esac
        fi
    done
}


