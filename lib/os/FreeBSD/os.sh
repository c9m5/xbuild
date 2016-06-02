#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/FreeBSD/os.sh
# Description: FreeBSD specific functions
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

freebsd_is_host() {
    if [ "`uname -o`" == "FreeBSD" ] ; then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_have_system_sources() {
    if ([ "`freebsd_is_host`" == "yes" ] && [ -r "${freebsd_sys_src_dir}/Makefile" ]); then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_have_system_doc() {
    if ([ "`freebsd_is_host`" == "yes" ] && [ -r  "${freebsd_sys_doc_dir}/Makefile" ]); then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_have_system_ports() {
    if ([ "`freebsd_is_host`" == "yes" ] && [ -r "${freebsd_sys_ports_dir}/Makefile" ]) ; then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_lookup_src() {
    if [ "`svnlite ls $freebsd_svn_base | grep "head"`"  != "head/" ] ; then
        error "Lookup failed! Are you connected to the internet?"
        return 1
    fi
    src="head"; local base
    for i in `svnlite ls $freebsd_svn_base/release` ; do
        if [ `echo $i | cut -f 1 -d / - | cut -f 1 -d . -` -ge $freebsd_atleast_version ] ; then
            src="${src} release/`echo $i | cut -f 1 -d / -`"
        fi
    done
    for i in `svnlite ls $freebsd_svn_base/stable` ; do
        if [ `echo $i | cut -f 1 -d / - | cut -f 1 -d . -` -ge $freebsd_atleast_version ] ; then
            src="${src} stable/`echo $i | cut -f 1 -d / -`"
        fi
    done
    if [ "$freebsd_releng_enable" == "yes" ] ; then
        for i in `svnlite ls $freebsd_svn_base/releng` ; do
            case $i in
                ALBPHA*|BETA*)
                    ;;
                1*|2*|3*|4*|5*|6*|7*|8*|9*)
                    if [ `echo $i | cut -f 1 -d / - | cut -f 1 -d . -` -ge $freebsd_atleast_version ] ; then
                        src="${src} releng/`echo $i | cut -f 1 -d / -`"
                    fi
                ;;
            esac
        done
    fi
    echo $src
}



