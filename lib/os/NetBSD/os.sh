#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/NetBSD/os.sh
# Description: NetBSD functions
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

netbsd_is_host() {
    if [ "`uname -o`" == "NetBSD" ] ; then
        echo "yes"
    else
        echo "no"
    fi
}

netbsd_have_system_sources() {
    if ([ "`netbsd_is_host`" == "yes" ] && [ -r "/usr/src/Makefile" ]) ; then
        echo "yes"
    else
        echo "no"
    fi
}

#netbsd_have_system_x11_sources() {
#    if ([ "`netbsd_is_host`" == "yes" ] && [ -r "/usr/X11/Makefile" ]) ; then
#        echo "yes"
#    else
#        echo "no"
#    fi
#}

netbsd_have_system_doc() {
    if ([ "`netbsd_is_host`" == "yes" ] && [ -r "/usr/doc/Makefile" ]) ; then
        echo "yes"
    else
        echo "no"
    fi
}


netbsd_have_system_pkgsrc() {
    if ([ "`netbsd_is_host`" == "yes" ] && [ -r "/usr/pkgsrc/Makefile" ]) ; then
        echo "yes"
    else
        echo "no"
    fi
}

netbsd_lookup_sources() {
    tmpfile="${xbuild_tmp_dir}/netbsd.dir"; local tmpfile

    ftp -n "${netbsd_ftp_root}/" << __EOF__
dir . $tmpfile
bye
__EOF__

    netbsd_sources=""; local items
    for i in `cat $tmpfile | grep "NetBSD-" | cut -f 9 -w -`; do
        case $i in
            NetBSD-archive|NetBSD-daily)
                ;;
            *)
                netbsd_sources="${netbsd_sources} $i"
                ;;
        esac
    done
    clear
    rm $tmpfile
}



