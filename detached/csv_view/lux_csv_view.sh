#!/bin/bash
# File       : lux_csv_view.sh
# Goal       : browse and view csv records on text interface
# Requisites :
#     1. SHELL=bash
# Syntax     : lux_csv_view.sh [-h] [-d <delimiter>] <file.csv>
# History    :
#   #version;date;description
#   0.2.0b; 12/02/2020; second beta test
#   0.1.0b; 10/02/2020; first beta test
#   0.1.0dr; 03/02/2020; first draft
#

# Todo
# 1. search by a single field

# filename e field delimiter char default
# edit PATH_APP=/path/to/app
export file_csv
export delim_field=';'
export PATH_APP=/cygdrive/f/aplicativos/cygwin/home/luis/projetos/scripts_avulsos/csv_view

# uso geral
export v_aux

# head and status
export str_prg='------------------------ Lux Csv Viewer Vs. 0.2.0b ----------------------------'
export head_line
export status_line
export prompt_line

# command option e menu flag
export cmd_opt full_opt
export flag_menu=0

OPTIND=1
list_opt=""
opt_found=0
while getopts ":hd:" pkey; do
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
    d)
        v_aux="${OPTARG}"
        if [ ${#v_aux} -ne 1 ]; then
            echo "Delimiter must have only one character: ${v_aux}" ; exit 1
        fi
        delim_field="${v_aux}"
        ;;
    h)
        more "${PATH_APP}/help.txt"
        exit 0
        ;;    
    \?)
        echo "Opção inválida -${OPTARG}"; exit 1
        ;;
    esac
done
[ $OPTIND -gt 1 ] && shift `expr $OPTIND - 1`
file_csv=$1

if [ ${#file_csv} -eq 0 ]; then
    echo "File csv missing"; exit 1
elif [ ! -f ${file_csv} ]; then
    echo "File ${file_csv} is not a regular file or doesn't exist"; exit 1
fi 

# fields and record information
export arr_fields line_record=""
export nr_fields nr_last_line
export nr_record=1 nr_aux nr_record_ant
export field_name field_val

# if not a file, select it

# get field names and last line number
arr_fields=`head -n 1 "${file_csv}" | sed -e "s/[${delim_field}\"]/\ /g"`
nr_fields=`echo ${arr_fields} | wc -w`
nr_last_line=$(wc -l "${file_csv}" | cut -d ' ' -f 1)
let nr_last_line--

# search vars
export src_pattern
export src_aux
export src_line

# show the record
cmd_opt="G"
prm_opt=1
while [ "${cmd_opt}" != "Q" ]; do

    # browse commands
    status_line=""
    nr_record_ant=$nr_record
    if [ "${cmd_opt}" = "H" ]; then
        # show help session
        flag_menu=1
    elif [ "${cmd_opt}" = "B" ]; then
        # begin of file
        nr_record=1
    elif [ "${cmd_opt}" = "E" ]; then
        # end of file
        nr_record=$nr_last_line
    elif [ "${cmd_opt}" = "G" ]; then
        v_inc="${prm_opt}"

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line=" - register must be numeric ${v_inc}"
        else
            let nr_record=$v_inc
            if [ $nr_record -gt $nr_last_line ]; then
                status_line=" - last line reached"
                nr_record=$nr_last_line
            elif [ $nr_record -lt 1 ]; then
                status_line=" - first line reached"
                nr_record=1
            fi
        fi
    elif [ "${cmd_opt}" = "+" ]; then
        # increment register number
        v_inc="${prm_opt}"

        # tratamento do registro
        [ -z ${v_inc} ] && v_inc=1

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line=" - increment of register must be numeric ${v_inc}"
        else
            let nr_record+=$v_inc
            if [ $nr_record -gt $nr_last_line ]; then
                status_line=" - last line reached"
                nr_record=$nr_last_line
            fi
        fi
    elif [ "${cmd_opt}" = "-" ]; then
        # increment register number
        v_inc="${prm_opt}"

        # tratamento do registro
        [ -z ${v_inc} ] && v_inc=1

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line="decrement of register must be numeric"
        else
            let nr_record-=$v_inc
            if [ $nr_record -lt 1 ]; then
                status_line=" - first line reached"
                nr_record=1
            fi
        fi
    elif [ "${cmd_opt}" = "S" ]; then
        # tratamento do parâmetro de busca
        if [ -z "${prm_opt}" ]; then
            if [ -z "${src_pattern}" ]; then
                read -p "Entre com o texto de busca" src_pattern
                src_pattern=`echo "${src_pattern}" | awk '{print toupper($0)}'`
                src_line=1
            else
                # se não informado assume a última busca feita
                # busca continua da próxima ocorrência
                prm_opt="${src_pattern}"
            fi
        else
            src_pattern="${prm_opt}"
            src_line=1
        fi

        # busca a partir de scr_line, se não encontrar, volta ao começo
        src_aux=`awk -v v_line_search=${src_line} -v v_text="${src_pattern}" -F "${delim_field}" -f lux_csv_search.awk "${file_csv}"`
        if [ $src_aux -eq -1 ]; then # não achou
            status_line=" - end of file. No more results for ${src_pattern}"
            src_line=1
        else # matches!
            src_line=$src_aux
            nr_record=$src_aux
        fi
    else
        status_line=" - invalid option or not implemented yet - ${cmd_opt}"
    fi

    # browse vars
    if [ -z "${line_record}" -o $nr_record -ne $nr_record_ant ]; then
        let nr_aux=nr_record+1
        line_record=`sed -n ${nr_aux},${nr_aux}p "${file_csv}"`
    fi
    status_line="Record #${nr_record} ${status_line}"

    # browsing
    echo "${str_prg}"
    for ind in `seq 1 $nr_fields`; do
        field_name=$(echo ${arr_fields} | cut -d ' ' -f ${ind})
        field_val="$(echo ${line_record} | cut -d "${delim_field}" -f ${ind})"
        if [ "${cmd_opt}" = "S" ]; then
            v_aux='\\e[41m'"${src_pattern}"'\\e[0m'
            field_val=`echo "${field_val}" | sed -e "s/${src_pattern}/${v_aux}/ig"`
            echo -e "${ind}) ${field_name}=${field_val}"
        else
            echo "${ind}) ${field_name}=${field_val}"
        fi
    done

    # input options
    echo '------------------------------------------------------------------'
    echo "Results: ${status_line}"
    echo ""
    echo "press [H]elp to help session or [Q]uit"
    if [ $flag_menu -eq 1 ]; then
        flag_menu=0
        echo '----------------------------- Menu --------------------------------'
        echo "Browse commands: [B]egin,[E]nd,[[G]oto] <register>,(+|-) <register>"
        echo "Search commands: [S]earch <pattern>, [F]ield search <pattern>"
        echo '-------------------------------------------------------------------'
    fi
    read -p "Choose an option: " full_opt

    # get the command + parameters
    # conversion to uppercase e numeric option (assumes G option)
    full_opt=`echo ${full_opt} | awk '{print toupper($0)}'`
    cmd_opt=`echo ${full_opt:0:1}`
    prm_opt=`echo ${full_opt:1} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`

    # number  --> [G]oto Number
    # <enter> --> (+1) Next register
    if [[ "${cmd_opt}" =~ ^[0-9]+$ ]]; then
        cmd_opt="G"
        prm_opt=`echo ${full_opt} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
    elif [ "${cmd_opt}" = "" ]; then
        cmd_opt="+"
    fi
done

