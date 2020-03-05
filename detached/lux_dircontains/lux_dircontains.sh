#!/bin/bash
# File       : lux_dircontains.sh
# Goal       : checks if <parent> direcory contains <file>
# Requisites :
#     1. SHELL=bash
# History    :
#   #version;date;description
#   0.2.0; 29/07/2018; now can check if any kind of file is in <parent>
#   0.1.0; 27/07/2018; first release (tested in bash environment)
# 

#
# Tested in: ubuntu 16.04/bash and cygwin
#

#
# How to use
#
# 1. put this script into a directory (Ex: ~/scripts)
#
# 2. insert this code in your ~/.bashrc:
# . ~/scripts/lux_dircontains.sh
#
# 3. open a new shell session and test it:
#
# lxf_dircontains <dir_parent> <file>
#
# 4. check the result in $? var
# $?=0, <file> is in <dir_parent>
# $?=1, <file> is not in <dir_parent>
# $?=2, error
#

function lxf_dircontains_syntax {
    local msg=$1
    echo "${msg}" >&2
    echo "syntax: lxf_dircontains <parent> <file>" >&2
    return 1
}

function lxf_dircontains {
    local result=1
    local parent=""
    local parent_pwd=""
    local child=""
    local child_dir=""
    local child_pwd=""
    local curdir="$(pwd)"
    local v_aux=""

    # parameters checking
    if [ $# -ne 2 ]; then
        lxf_dircontains_syntax "exactly 2 parameters required"
        return 2
    fi
    parent="${1}"
    child="${2}"

    # exchange to absolute path
    parent="$(readlink -f "${parent}")"
    child="$(readlink -f "${child}")"
    dir_child="${child}"

    # file/directory checking
    if [ ! -d "${parent}" ];  then
        lxf_dircontains_syntax "parent dir ${parent} not a directory or doesn't exist"
        return 2
    elif [ ! -e "${child}" ];  then
        lxf_dircontains_syntax "file ${child} not found"
        return 2
    elif [ ! -d "${child}" ];  then
        # not directory? get the path of file
        dir_child=`dirname "${child}"`
    fi

    # get directories from $(pwd)
    cd "${parent}"
    parent_pwd="$(pwd)"
    cd "${curdir}"  # to avoid errors due relative paths
    cd "${dir_child}"
    child_pwd="$(pwd)"

    # checking if is parent
    [ "${child_pwd:0:${#parent_pwd}}" = "${parent_pwd}" ] && result=0

    # return to current directory
    cd "${curdir}"
    return $result
}