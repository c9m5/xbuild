#!/bin/sh

freebsd_have_system_sources() {
    if ([ "$freebsd_is_host" == "yes" ] && [ -r "${freebsd_syssrc_dir}/Makefile" ]); then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_have_system_doc() {
    if ([ "$freebsd_is_host" == "yes" ] && [ -r  "${freebsd_sysdoc_dir}/Makefile" ]); then
        echo "yes"
    else
        echo "no"
    fi
}

freebsd_have_system_ports() {
    if ([ "$freebsd_is_host" == "yes" ] && [ -r "${freebsd_sysports_dir}/Makefile" ]) ; then
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
    if [ "$freebsd_src_releng_enable" == "yes" ] ; then
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



