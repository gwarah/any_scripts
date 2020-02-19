#!/bin/bash
# File       : lux_csv_view.sh
# Goal       : browse and view csv records on text interface
# Requisites :
#     1. SHELL=bash
#     2. First line of <file.csv> must be the head line
# Syntax     : lux_csv_view.sh [-h] [-d <delimiter>] <file.csv>
# History    :
#   #version;date;description
#   1.0.0; 13/02/2020; first release
#   0.3.0b; 17/02/2020; highlights of fields and messages under some conditions
#   0.2.1b; 13/02/2020; code improvement and bugs corretions
#   0.2.0b; 12/02/2020; second beta test
#   0.1.0b; 10/02/2020; first beta test
#   0.1.0dr; 03/02/2020; first draft
#

########
# Access Luxes channel for support and updates
# https://github.com/gwarah/luxes
########

# Todo next versions
# 1. search by a single field
# 2. files csv without header
# 3. searches for records with excess of fields or missing them

# filename e field delimiter char default
# edit PATH_APP=/path/to/app and delim_field=<delim>
export file_csv
export delim_field=';'
export PATH_APP=/cygdrive/f/aplicativos/cygwin/home/luis/projetos/scripts_avulsos/csv_view

# variables to privide a help
export var_manual
export var_version='1.0.0'
read -r -d '' var_manual <<'EOF'
---------------------- Lux Csv Viewer Vs. 1.0.0 - Help -------------------------
H        : Show this help;
B        : Begin of file;
E        : End of file;
G <N>    : Go to <N>th record;
<N>      : Same of G <N>;
+<N>     : Advances <N> records foward;
-<N>     : Rewind <N> records back;
<enter>  : Next register. Same of +1;
S <text> : Search a line containing <text> in any field. 
           S with no parameter, search <text> again;
Q        : Quit the program
EOF

# uso geral
export v_aux v_aux1 v_aux2

# head and status
export str_prg='------------------------ Lux Csv Viewer Vs. '"${var_version}"' ----------------------------'
export head_line
export status_line
export error_line

# command option e menu flag
export cmd_opt full_opt

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
export nr_fields nr_fields_record nr_last_line
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
clear
while [ "${cmd_opt}" != "Q" ]; do

    # browse commands
    status_line=""
    error_line=""
    nr_record_ant=$nr_record
    if [ "${cmd_opt}" = "H" ]; then # show help session
        clear
        echo "${var_manual}" | pg
    elif [ "${cmd_opt}" = "B" ]; then # begin of file
        nr_record=1
    elif [ "${cmd_opt}" = "E" ]; then # end of file
        nr_record=$nr_last_line
    elif [ "${cmd_opt}" = "G" ]; then  # Goto <N> record
        v_inc="${prm_opt}"

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line=" - record number must be an integer: ${v_inc}"
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
    elif [ "${cmd_opt}" = "+" ]; then # Increment of record number
        v_inc="${prm_opt}"

        # empty=next record
        [ -z ${v_inc} ] && v_inc=1

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line=" - increment of record number must be integer: ${v_inc}"
        else
            let nr_record+=$v_inc
            if [ $nr_record -gt $nr_last_line ]; then
                status_line=" - last line reached"
                nr_record=$nr_last_line
            fi
        fi
    elif [ "${cmd_opt}" = "-" ]; then # Decrecrement of register number
        v_inc="${prm_opt}"

        # empty=previous record
        [ -z ${v_inc} ] && v_inc=1

        if ! [[ "${v_inc}" =~ ^[0-9]+$ ]] ; then
            status_line=" - decrement of record number must be integer: ${v_inc}"
        else
            let nr_record-=$v_inc
            if [ $nr_record -lt 1 ]; then
                status_line=" - first line reached"
                nr_record=1
            fi
        fi
    elif [ "${cmd_opt}" = "S" ]; then  # Searching for a text
        # analizing the parameter
        if [ -z "${prm_opt}" ]; then
            if [ -z "${src_pattern}" ]; then
                # first search
                read -p "Text to search: " src_pattern
                src_pattern=`echo "${src_pattern}" | awk '{print toupper($0)}'`
                src_line=1
            else
                # empty and had last search?
                prm_opt="${src_pattern}"
            fi
        else
            src_pattern="${prm_opt}"
            src_line=1
        fi

        # search staring from $scr_line
        src_aux=`awk -v v_line_search=${src_line} -v v_text="${src_pattern}" -F "${delim_field}" -f ${PATH_APP}/lux_csv_search.awk "${file_csv}"`
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

    # get the record
    if [ -z "${line_record}" -o $nr_record -ne $nr_record_ant ]; then
        let nr_aux=nr_record+1
        line_record=`sed -n ${nr_aux},${nr_aux}p "${file_csv}"`
    fi
    status_line="Record #${nr_record} ${status_line}"
    
    # verify number os delimiters
    v_aux="${line_record//[^"${delim_field}"]}"
    let nr_fields_record=${#v_aux}+1
    if [ $nr_fields_record -ne $nr_fields ]; then
        error_line="${nr_fields} fields was expected but ${nr_fields_record} was found"
    fi 

    # output current record
    echo "${str_prg}"
    for ind in `seq 1 $nr_fields`; do
        field_name=$(echo ${arr_fields} | cut -d ' ' -f ${ind})
        field_val="$(echo ${line_record} | cut -d "${delim_field}" -f ${ind})"
        
        # in case of S option, highlights search text
        if [ "${cmd_opt}" = "S" ]; then 
            v_aux='\\e[41m'"${src_pattern}"'\\e[0m'
            field_val=`echo "${field_val}" | sed -e "s/${src_pattern}/${v_aux}/ig"`
        fi
        
        # other cases
        if [ $ind -gt $nr_fields_record ]; then # missing field
            echo -e "\e[7m\e[91m${ind}) ${field_name}=<empty>\e[0m"
        elif [ -z "${field_val}" ]; then # empty field 
            echo -e "${ind}) ${field_name}=\e[7m<empty>\e[0m"
        else
            echo -e "${ind}) ${field_name}=${field_val}"
        fi
        
        # check for remaining fields
        if [ $ind -eq $nr_fields -a $nr_fields -lt $nr_fields_record ]; then
           let v_aux=${ind}+1
           field_val="$(echo ${line_record} | cut -d "${delim_field}" -f ${v_aux}-)"
           if [ "${field_val}" ]; then
               echo -e "\e[7m\e[91m${v_aux}) Remaining Fields=${field_val}\e[0m"
           fi
        fi
    done

    # input options
    echo '------------------------------------------------------------------'
    echo "Results: ${status_line}"
    if [ "${error_line}" ]; then
        echo -e "\e[7m\e[91m${error_line}\e[0m"
    fi
    echo ""
    echo "Press <enter> to go to next record, [Q]uit or [H]elp to more options"
    read -p "Choose an option: " full_opt

    # get the command + parameters
    # conversion to uppercase e numeric option (assumes G option)
    full_opt=`echo ${full_opt} | awk '{print toupper($0)}'`
    cmd_opt=`echo ${full_opt:0:1}`
    prm_opt=`echo ${full_opt:1} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`

    # <number> --> [G]oto <number>
    # <enter>  --> (+1) Next register
    if [[ "${cmd_opt}" =~ ^[0-9]+$ ]]; then
        cmd_opt="G"
        prm_opt=`echo ${full_opt} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
    elif [ "${cmd_opt}" = "" ]; then
        cmd_opt="+"
    fi
done

