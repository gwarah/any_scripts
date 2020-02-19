#!/bin/bash
# File       : lux_echodate.sh
# Goal       : echo <date>;[<tags>;]<text>
# Requisites :
#     1. SHELL=bash
# Syntax     : lux_echopad.sh [-m <datemask>] [-t <tag>] text
# History    :
#   #version;date;description
#   0.1.0b; __/02/2020; first beta
#   0.0.1dr; 18/02/2020; first draft
#

########
# Access Luxes channel for support and updates
# https://github.com/gwarah/luxes
########

#
# use these snippet to modify the datemask and tags default
#
# export LXV_ECHODATE_MASK='%d/%m/%Y %H:%M:%S'
# export LXV_ECHODATE_TAG='ALERT'
#
function lxf_echodate {
    #
    # default values: datemask and tag
    #
    local p_datemask=${LXV_ECHODATE_MASK:='%d/%m/%Y %H:%M:%S'}
    local p_tag=${LXV_ECHODATE_TAG:=""}
        
    # others vars
    local v_aux
        
    #
    # getopts 
    #
    local OPTIND=1
    local list_opt=""
    local opt_found=0
    while getopts ":m:t:" pkey; do
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
        m)  # datemask
            v_aux="${OPTARG}"
            if [ ${#v_aux} -eq 0 -o "${v_aux:0:1}" = "-" ]; then
                echo "datemask cannot be empty" ; exit 1
            fi
            p_datemask="${v_aux}"
            
            # update the mask default
            # LXV_ECHODATE_MASK="${p_datemask}"
            ;;
        t)  # tag
            v_aux="${OPTARG}"
            if [ ${#v_aux} -eq 0 -o "${v_aux:0:1}" = "-" ]; then
                echo "tag cannot be empty" ; exit 1
            fi
            p_tag="${v_aux}"
            
            # update the tag default
            # LXV_ECHODATE_TAG="${p_tag}"
            ;;
        \?)
            echo "Opção inválida -${OPTARG}"; exit 1
            ;;
        esac
    done
    
    # shift positional parameters
    [ $OPTIND -gt 1 ] && shift `expr $OPTIND - 1`
    p_text="$@"
    
    # echo
    echo "$(date "+${p_datemask}")${p_tag:+;${p_tag}};${p_text}"
}

#
# tests without exported variables
#
lxf_echodate one 
lxf_echodate -t WARNING two
lxf_echodate -m '%d/%m/%Y' -t ALERT three
lxf_echodate back to one 

#
# outputs
#
# 18/02/2020 14:19:43;one
# 18/02/2020 14:19:43;WARNING;two
# 18/02/2020;ALERT;three
# 18/02/2020 14:19:44;back to one


#
# tests with exported variables
#
export LXV_ECHODATE_MASK='%d/%m/%Y'
export LXV_ECHODATE_TAG='RED_ALERT'
lxf_echodate one 
lxf_echodate -t WARNING two
lxf_echodate -m '%d/%m/%Y' -t ALERT three
lxf_echodate back to one 

#
# outputs
#
# 18/02/2020;RED_ALERT;one
# 18/02/2020;WARNING;two
# 18/02/2020;ALERT;three
# 18/02/2020;RED_ALERT;back to one