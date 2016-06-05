#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/os/freebsd/install.sh
# Description: install script for FreeBSD target
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

freebsd_install_base() {
    if [ ! -d "${xbuild_install_dir}/freebsd" ] ; then
        echo "[DIR] ${xbuild_install_dir}/freebsd"
        mkdir -p "${xbuild_install_dir}/freebsd"
    fi
}

freebsd_install_sources() {
    : ${xbuild_svn_retries:=10}

    upscript="${xbuild_script_dir}/freebsd.src-update.sh"; upscript

    if [ ! -e "$upscript" ] ; then
        echo "#!/bin/sh" > "$upscript"
    fi
    if [ ! -x $upscript ] ; then
         chmod +x "$upscript"
    fi

    echo "FREEBSD_SOURCES_UPDATE=\"{upscript}\"" >> "${xbuild_config_dir}/freebsd.conf"

    case $1 in
        stable/*)
            echo "\${XBUILD_SVN} up \"\${xbuild_base_dir}/FreeBSD/src.`echo "$i" | cut -f 1 -d / -`-`echo "$i" | cut -f 2 -d / -`\"" >> "$upscript"
            ;&
        */*)
            srcinstdir="${xbuild_base_dir}/FreeBSD/src.`echo "$i" | cut -f 1 -d / -`-`echo "$i" | cut -f 2 -d / -`"
            ;;
        current)
            echo "\${XBUILD_SVN} up \"\${xbuild_base_dir}/FreeBSD/src.${i}\"" >> "${upscript}"
            ;&
        *)
            srcinstdir="${xbuild_base_dir}/FreeBSD/src.${i}"
            ;;
    esac
    local srcinstdir

    if [ ! -d "$scrinstdir" ] ; then
        echo "[DIR] $srcinstdir"
        mkdir -p "$srcinstdir"
    fi

    if [ "$1" == "system" ] ; then
        case $2 in
            symlink)
                if [ -d "${srcinstdir}" ] ; then
                    echo "[RMDIR] $srcinstdir"
                    rmdir "${srcinstdir}"
                fi

                echo "[SYMLINK] /usr/src -> $scrinstdir"
                ln -s "/usr/src" "$srcinstdir"
                ;;

            nullfs)
                echo "[FILE] /etc/fstab"
                sudo_get_password | sudo -s sh -s << __EOF__
echo "/usr/src/ ${srcinstdir} nullfs ro,late 0 0" >> /etc/fstab
__EOF__
                ;;
        esac
    else
        rv=1; local rv
        retr=0; local retr

        while ([ $rv -ne 0 ] && [ $retr -le $xbuild_svn_retries ]); do
            "$XBUILD_SVN" checkout "${freebsd_svn_base}/$1" "$srcinstdir"
            rv=$?
            if [ $rv -ne 0 ] ; then
                "$XBUILD_SVN" cleanup "$srcinstdir"
                retr=$(( retr + 1 ))
                echo "RETRY  $retr ..."
                sleep 10
            fi
        done
    fi
}

freebsd_install_ports() {
    basedir="${xbuild_base_dir}/FreeBSD"
    portsdir="${basedir}/ports"
    portsdbdir="${basedir}/db.portsnap"
    distfilesdir="${basedir}/distfiles"
    local basedir portsdir portsdbdir distfilesdir

    for i in "$portsdir" "$distfilesdir"; do
        echo "[DIR] $i"
        mkdir -p "$i"
    done
    case $1 in
        system)
            case $2 in
                symlink)
                    if [ -d "${portsdir}" ] ; then
                        echo "[RMDIR] $portsdir"
                        rmdir "$portsdir"
                    fi
                    ln -s "/usr/ports" "$portsdir"
                    ;;
                nullfs)
                    get_sudo_password | sudo -s sh -s << __EOF__
echo "/usr/ports ${portsdir} nullfs ro,late 0 0" >> /etc/fstab
__EOF__
                ;;
            esac
            echo "FREEBSD_PORTS_UPDATE=\"\"" >> "${xbuild_config_dir}/freebsd.conf"
            ;;
        portsnap)
            echo "[DIR] $portsdbdir"
            mkdir -p "$portsdbdir"

            retr=0; local retr
            rv=1; local rv
            while ([ $rv -ne 0 ] && [ retr -le 10 ]) ; do
                retr=$(( $retr + 1 ))
                portsnap -d "$portsdbdir" -p "$portsdir" fetch
                rv=$?
                if [ $rv -ne 0 ] ; then
                    sleep 10
                fi
            done
            portsnap -d "$portsdbdir" -p "$portsdir" extract
            echo "FREEBSD_PORTS_UPDATE=\"portsnap -d \\\"$portsdbdir\\\" -p \\\"$portsdir\\\"  update\"" >> "$xbuild_config_dir/freebsd.conf"
            ;;
        svn)
            retr=0; local retr
            rv=1; local rv
            while ([ $rv -ne 0 ] && [ $retr -le 10 ]); do
                retr=$(( $retr + 1 ))
                "$XBUILD_SVN" checkout  "$freebsd_svn_ports" "$portsdir"
                rv=$?
                if [ $rv -ne 0 ]; do
                    "$XBUILD_SVN" cleanup "$portsdir"
                    sleep 10
                fi
            done
            echo "FREEBSD_PORTS_UPDATE=\"\${XBUILD_SVN} up \\\"$portsdir\\\"\"" >> "$xbuild_config_dir/freebsd.conf"
            ;;
    esac
}

freebsd_install_doc() {
    case $1 in
        svn)
            rv=1; local rv
            retr=0; local retr
            echo "[DIR] ${xbuild_base_dir}/FreeBSD/doc"
            mkdir -p "${xbuild_base_dir}/FreeBSD/doc"
            while ([ $rv -ne 0 ] && [ $retr -le 10 ]); do
                retr=$(( $retr + 1 ))
                "$XBUILD_SVN" checkout  "${freebsd_svn_doc}" "${xbuild_base_dir}/FreeBSD/doc"
                rv=$?
                if [ $rv -ne 0 ] ; then
                    "$XBUILD_SVN" cleanup "${xbuild_base_dir}/FreeBSD/doc"
                    sleep 10
                fi
            done
            echo "FREEBSD_DOC_UPDATE=\"\${XBUILD_SVN} up \\\"\${xbuild_base_dir}/FreeBSD/doc\\\"\""
            ;;
        system)
            echo "[SYMLINK] ${xbuild_base_dir}/FreeBSD/doc"
            ln -s "/usr/doc" "${xbuild_base_dir}/FreeBSD/doc"
            echo "FREEBSD_DOC_UPDATE=\"\""
            ;;
    esac
}


