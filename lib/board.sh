#!/bin/sh
#
# Author(s): c9m5
# File: lib/xbuild/board.sh
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

: ${xbuild_boardlist_file="${xbuild_tempdir}/boardlist"}
: ${BOARDLISTID_FILE:=1}
: ${BOARDLISTID_ID:=2}
: ${BOARDLISTID_NAME:=3}
: ${BOARDLISTID_TITLE:=4}
: ${BOARDLISTID_OSLIST:=5}
: ${BOARDLIST_OSLIST_SEPARATOR:=";"}

if [ ! -r "${xbuild_boardlist_file}" ] ; then
    for i in `ls ${xbuild_libdir}/board/*.board"` ; do
        if  ([ -r "$i" ] && [ ! -L "$i$" ]); then
            . "$i"
            _oslist=""
            for i in BOARD_OSLIST; do
                if [ -n "$_oslist" ] ; then
                    $_oslist="${_oslist}${BOARDLIST_OSLIST_SEPARATOR}${i}"
                else
                    $_oslist="${i}"
                fi
            done
            _boardfile="${i##${xbuild_libdir}/board/"
            echo "${_boardfile}:${BOARD_ID}:${BOARD_NAME}:${BOARD_TITLE}:${_oslist}"
        fi
    done
fi



