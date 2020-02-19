#!/bin/bash
# File       : lux_echopad.sh
# Goal       : echo a text "padded" with a char
# Requisites :
#     1. SHELL=bash
# Syntax     : lux_echopad.sh [-l <line_length>] [-c <char>]
# History    :
#   #version;date;description
#   0.1.0b; 18/02/2020; first beta
#   0.0.1dr; 03/02/2020; first draft
#

########
# Access Luxes channel for support and updates
# https://github.com/gwarah/luxes
########

#
# use these snippet to modify the datemask and tags default
#
# export LXV_ECHOPAD_LENGTH=60
# export LXV_ECHOPAD_PADCHAR='-'
#

function lxf_echopad {
    #
    # default values: line length and padding char 
    #
    local p_linelength=${LXV_ECHOPAD_LENGTH:=60}
    local p_padchar=${LXV_ECHOPAD_PADCHAR:='-'}
    local p_text=""
    
    # others vars
    local v_aux
    local vt_pad
    local v_mod
    local v2_pad
    local v_textpad
    
    #
    # getopts 
    #
    local OPTIND=1
    local list_opt=""
    local opt_found=0
    while getopts ":l:c:" pkey; do
        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${list_opt}" | grep -q $pkey
        if [ $? -eq 0 ]; then
            echo "Not allowed more than one parameter -${pkey} " ; exit 1
        fi
    
        # atualiza controle de chaves executadas
        (( opt_found++ ))
        list_opt="${list_opt};${pkey}"
    
        case $pkey in
        c)  # padding char
            v_aux="${OPTARG}"
            if [ ${#v_aux} -ne 1 ]; then
                echo "char parameter invalid: ${v_aux}" ; exit 1
            fi
            p_padchar="${v_aux}"
            ;;
        l)  # line length
            v_aux="${OPTARG}"
            if ! [[ ${v_aux} =~ ^[0-9]+$ ]]; then    
                echo "length parameter must be a integer: ${v_aux}" ; exit 1
            fi
            
            if [ ${v_aux} -lt 9 ]; then
                echo "length parameter must be greater than 10: ${v_aux}" ; exit 1
            fi
            p_linelength=${v_aux}
            ;;
        \?)
            echo "Opção inválida -${OPTARG}"; exit 1
            ;;
        esac
    done
    
    # shift positional parameters
    [ $OPTIND -gt 1 ] && shift `expr $OPTIND - 1`
    p_text=$1
    
    if [ ${#p_text} -ge ${p_linelength} ]; then
        echo "${p_text}"
    else
        let vt_pad=${p_linelength}-${#p_text}
        let v_mod=${vt_pad}%2
        let v2_pad=${vt_pad}/2
        
        # left pad
        let v_aux=$v2_pad+$v_mod
        v_stl=`for k in $(seq 1 $v_aux);do printf ${p_padchar};done`
        
        # right pad
        let v_aux=$v2_pad
        v_str=`for k in $(seq 1 $v_aux);do printf ${p_padchar};done`
        
        echo "${v_stl}${p_text}${v_str}"
    fi
}

#
# tests without exported variables
#
lxf_echopad " first "
lxf_echopad -l 40 " second "
lxf_echopad -c '=' -l 50 " third "
lxf_echopad " first again "

#
# tests with exported variables
#
export LXV_ECHOPAD_LENGTH=65
export LXV_ECHOPAD_PADCHAR='x'

lxf_echopad " first "
lxf_echopad -l 40 " second "
lxf_echopad -c '=' -l 50 " third "
lxf_echopad " first again "