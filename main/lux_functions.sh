#!/bin/bash
# =======================================================================
# Project      : Luxes
# Author       : gwarah
# File         : lux_functions.sh
# Description  : functions for general use 
# Dependences  : lux_config.sh loaded
#
# Versions
#   0.0.1dr;;gwarah; 01/06/2019; first draf
# ======================================================================
#

##########
#  Warning: under construction!!!
##########

####
#
# Module loaded ok => LXV_FLAG_FUN=1
#
####
export LXV_FLAG_FUN=0

# # # # # # # # # # #
# function    : lxf_syntax
# description : shows the lxf_function syntax, and optionally exit
# usage       : lxf_syntax -s <function_name> [-x] [-m <opc_msg>]
# parameters  :
#      -s: em extinção. Mostra a sintaxe da função <function_name>, que deve ser cadastrada,
#                       do contrário gera uma mensagem de erro
#      -y: opcional. Se informado, mostra uma sintaxe diferente das cadastradas
#      -t: opcional. Se informado, mostra a chamada de funções
#      -x: opcional. Se informado, termina o script e retorna o status 1 para o sistema operacional
#      -m: opcional. Se informado, imprime junto com a sintaxe, a mensagem gravada em <opc_msg>
# output      : outputs the <function_name> syntax
# obs         :
function lxf_syntax {
    # array de flags para indicar que as chaves foram invocadas na chamada da função
    local flags_opt=( 0 0 0 0 0 )

    local msg_aux=""
    local fun_syntax="${FUNCNAME[1]}"
    local msg_syntax=""

    local opt_found=0
    local list_opt=""

    OPTIND=1
    while getopts ":ts:m:y:x" pkey; do

        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${list_opt}" | grep -q $pkey
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "Opcao -$pkey chamada mais de uma vez."
        fi

        # atualiza controle de chaves executadas
        (( opt_found++ ))
        list_opt="${list_opt};${pkey}"

        if [ $opt_found -gt 5 ]; then
            lxf_syntax -x -m "chaves em excesso"
        fi

        case "${pkey}" in
            s)  # será extinta
                flags_opt[0]=1
                # fun_syntax=${OPTARG}
                ;;
            m)  # mensagem que acompanha a sintaxe
                flags_opt[1]=1
                msg_aux="${OPTARG}"
                if [ -z "${msg_aux}" -o "${msg_aux:0:1}" = "-" ]; then
                    lxf_syntax -x -m "mensagem não informada ou inválida: ${msg_aux}"
                fi
                ;;
            x)  # sai após emitir mensagens de sintaxe
                flags_opt[2]=1
                ;;
            t)  # mostra a lista de chamada de funções
                flags_opt[3]=1
                ;;
            y)  # mostra uma sintaxe que o usuário deseja exibir (diferente das cadastradas)
                flags_opt[4]=1
                msg_syntax="${OPTARG}"
                if [ -z "${msg_syntax}" -o "${msg_syntax:0:1}" = "-" ]; then
                    lxf_syntax -x -m "sintaxe não informada ou inválida: ${msg_syntax}"
                fi
                ;;        
            \?)
                lxf_syntax -x -m "Opção inválida: -$OPTARG"
                ;;
            :)
                lxf_syntax -x -m "Opção -$OPTARG requer um argumento."
                ;;
        esac
    done

    # seleciona a sintaxe de acordo com a função:
    if [ "${msg_syntax}" ]; then                   # chave -y: sintaxe fornecida
        msg_syntax="${msg_syntax}"
    elif [ "${fun_syntax}" = "lxf_syntax" ]; then  # a própria lxf_syntax chamada recursivamente
        msg_syntax="lxf_syntax [-x] [-m <msg>]"
    elif [ "${fun_syntax}" = "lxf_trim" ]; then
        msg_syntax="lxf_trim [-l|-r] <text>"
    elif [ "${fun_syntax}" = "lxf_echo" ]; then
        msg_syntax="lxf_echo [ -c <category> ] [ -s <severity> ] [ -t tag01,tag02,.. ] <text>"
    elif [ "${fun_syntax}" = "lxf_get_logfile" ]; then
        msg_syntax="lxf_get_logfile [ -s ]"
    elif [ "${fun_syntax}" = "lxf_message" ]; then
        msg_syntax="lxf_message ( -i | -w | -e | -f) [-m] [-s <code>] [-x <err_code>] <text>"
    elif [ "${fun_syntax}" = "lxf_line" ]; then
        msg_syntax="lxf_line [ -c <char> ] [ -l <lenght> ] [ -t <text> ]"
    elif [ "${fun_syntax}" = "lxf_read" ]; then
        msg_syntax="lxf_read -m <msg> [-d <value_default>] [-t <time_seconds>] [ -e <err_msg> ] [-k <mask01> [-k <mask02> ... [-k <maskNN> ] ] ]"    
    elif [ "${fun_syntax}" = "lxf_array_contains" ]; then
        msg_syntax="lxf_array_contains [-n] $array $element"
    elif [ "${fun_syntax}" = "lxf_menu" ]; then
        msg_syntax="lxf_menu [-m <msg>] [-d <default-item>] [-t <time_seconds>] [-l] -o \"<key01> <option01>\" -o \"<key02> <option02>\" [-o \"<key03> <option03>\" ... [-o \"<keyNN> <optionNN>\" ] ]"
    else
        msg_syntax="${fun_syntax} syntaxe não cadastrada!"
    fi

    echo ""
    [ ${flags_opt[1]} -eq 1 ] && echo "${msg_aux}" >&2   # mensagem
    echo "sintaxe: ${msg_syntax}" >&2                    # sintaxe
    if [ ${flags_opt[3]} -eq 1 ]; then                   # chamadas de funções
        echo "chamada(s): ${FUNCNAME[@]}" >&2
    fi
    [ ${flags_opt[2]} -eq 1 ] && lxf_exit 1              # saída do script

}

# # # # # # # # # # #
# function    : lxf_trim
# description : remove trailing (-r), leading (-l) or both cases whitespaces
# usage       : lxf_trim [-l|-r] $str
# return      : echoes (or returns) <$str_trimed>
# obs         :
function lxf_trim {
    # último argumento
    local FOO=$(for i in "$@"; do :; done ; echo "${i}")
    local TRIM_MASK="-e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'"
    local FOO_TRIM=""
    local opt_found=0

    OPTIND=1
    while getopts ":l:r:" pkey; do
        # atualiza controle de chaves executadas
        (( opt_found++ ))
        if [ $opt_found -gt 1 ]; then
            lxf_syntax -x -m "chaves em excesso"
        fi

        case "${pkey}" in
            l)
                FOO_TRIM="$(echo "${OPTARG}" | sed -e 's/^[[:space:]]*//')"
                ;;
            r)
                FOO_TRIM="$(echo "${OPTARG}" | sed -e 's/[[:space:]]*$//')"
                ;;
            \?)
                lxf_syntax -x -m "Opção inválida: -$OPTARG"
                ;;
            :)
                lxf_syntax -x -m "Opção -$OPTARG requer um argumento"
                ;;
        esac
    done
    # caso nenhuma chave tenha sido usada, faz o trim pela direita e esquerda
    [ $opt_found -eq 0 ] && FOO_TRIM="$(echo "${FOO}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    LXV_RETURN="${FOO_TRIM}"
    [ $LXV_ECHO_RETURN -eq 1 ] && echo "${LXV_RETURN}"
}

# # # # # # # # # # #
# function    : lxf_norm_path
# description : strip the last / of the path (if contains)
# usage       : lxf_norm_path $path
# obs         :
function lxf_norm_path {
    local FOO_PATH=$1

    # se tiver um / no final da variável, retira-o
    if [ "${FOO_PATH:(-1)}" = '/' ]; then
        LXV_RETURN="${FOO_PATH:0:(-1)}"
    fi

    [ $LXV_ECHO_RETURN -eq 1 ] && echo "${LXV_RETURN}"
}

# ToDo: put key parameters to set new logfile (-t $TITLE -m $DATEMASK -s): -s store
# ToDo: log pattern and log default

# # # # # # # # # # #
# function    : lxf_set_logfile
# description : set logfile parameters
# usage       : lxf_set_logfile -d
# output      : update $LXV_LOG_FILE_NAME var
# obs         :
function lxf_set_logfile {

    local a=0
#    while getopts ":t:m:" pkey; do
#        case "${pkey}" in
#            l)
#                FOO_TRIM="$(echo "${OPTARG}" | sed -e 's/^[[:space:]]*//')"
#                ;;
#            r)
#                FOO_TRIM="$(echo "${OPTARG}" | sed -e 's/[[:space:]]*$//')"
#                ;;
#            \?)
#                echo "lux_trim: Invalid option: -$OPTARG" >&2
#                lux_exit 1
#                ;;
#            :)
#                echo "Option -$OPTARG requires an argument." >&2
#                lux_exit 1
#                ;;
#        esac
#    done
#    # shift $((OPTIND-1))

}

# # # # # # # # # # #
# function    : lxf_get_logfile
# description : obtains logfile name
# usage       : lxf_get_logfile [-s]
# output      : update $LXV_LOG_FILE_NAME var and shows on default output if -s exists
# obs         :
function lxf_get_logfile {
    local p_ok=0

    [ $# -gt 1 ] && lxf_syntax -x -m "parâmetros em excesso $* "

    LXV_LOG_FILE_NAME="${LXV_PATH_LOG}/${LXV_LOG_FILE_TITILE}_$(date +${LXV_LOG_FILE_MASK}).txt"
    touch "${LXV_LOG_FILE_NAME}"
    if [ $? -ne 0 ]; then
        # lxf_erro "Erro na criação do arquivo de log ${LXV_LOG_FILE_NAME}" 1
        lxf_echo "Erro na criação do arquivo de log ${LXV_LOG_FILE_NAME}"
    fi

    # teste com as chaves
    OPTIND=1
    while getopts ":s" pkey; do
        case ${pkey} in
            s)
                [ $p_ok -ne 0 ] && lxf_syntax -x -m "chave em excesso:-${pkey}"
                p_ok=1
                ;;

            \?)
                lxf_syntax -x -m "chave inválida -$OPTARG "
                ;;
        esac
    done

    [ $p_ok -eq 1 ] && echo "${LXV_LOG_FILE_NAME}"
}

# # # # # # # # # # #
# function    : lxf_echo
# description : echo improved with more information
# usage       : lxf_echo [ -c <category> ] [ -s <severity> ] [ -t tag01,tag02,.. ] $msg
# output      : echo <date>;<category>;<severity>;<tags>;<msg> to screen and/or filelog
# obs         :
#   1 - if tags was separeted by spaces or ; will be replaced by ,
#   2 - if $LOG_OUTPUT not defined then LOG_OUTPUT=0
#   3 - if $LOG_FILE not defined then LOG_OUTPUT=0
function lxf_echo {
    # array de flags para indicar que as chaves foram invocadas na chamada da função
    local flags_opt=( 0 0 0 )
    local lux_echo_date="$(date +"${LXV_LOG_REG_MASK}")"
    local lux_echo_category=$LXV_LOG_REG_CATEGORY
    local lux_echo_severity=$LXV_LOG_REG_SEVERITY
    local lux_echo_tags=""
    local lux_echo_msg=""
    local lux_echo_line=""
    local flag_tags=0
    local flag_profile=0
    local log_profile=0

    local opt_found=0
    local list_opt=""
    OPTIND=1
    while getopts ":c:s:t:" pkey; do

        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${list_opt}" | grep -q $pkey
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "chave ${pkey} não pode ser duplicada"
        fi

        # atualiza controle de chaves executadas
        (( opt_found++ ))
        list_opt="${list_opt};${pkey}"

        case "${pkey}" in
            c)
                echo "${OPTARG}" | grep -q -e '^[0-3]$'
                [ $? -ne 0 ] && lxf_syntax -x -m "categoria deve ser entre 0 e 3"
                lux_echo_category=${OPTARG}
                ;;
            s)
                echo "${OPTARG}" | grep -q -e '^[0-9]$'
                [ $? -ne 0 ] && lxf_syntax -x -m "urgência deve ser entre 0 e 9"
                lux_echo_severity=${OPTARG}
                ;;
            t)
                flag_tags=1
                lux_echo_tags="${OPTARG}"
                [ -z "${lux_echo_tags}" -o "${lux_echo_tags:0:1}" = "-" ] && lxf_syntax -x -m "tags não informadas"
                # transforma sequência de [; ]+ em ,
                lux_echo_tags=`echo "${lux_echo_tags}" | sed -e "s/[ ;]\+/\,/g"`
                # deslocamento para poder pegar o argumento
                ;;
            \?)
                lxf_syntax -x -m "Chave inválida: -${pkey}"
                ;;
            :)
                lxf_syntax -x -m "Opção -${OPTARG} requer um argumento"
                ;;
        esac
    done

    # testa se mensagem não tomada como arguentos anteriores
    if [ $OPTIND -gt 1 ]; then
        shift $((OPTIND-1))
    fi

    lux_echo_msg="$1"
    [ -z "${lux_echo_msg}" ] && lxf_syntax -x -m "Mensagem não informada"

    # forma a linha do log
    lux_echo_line="${lux_echo_date};${lux_echo_category};${lux_echo_severity};${lux_echo_tags};${lux_echo_msg}"

    # impressão em tela e/ou arquivo
    [ $LXV_LOG_OUTPUT -eq 0 -o  $LXV_LOG_OUTPUT -eq 2 ] && echo "${lux_echo_line}"
    if [ $LXV_LOG_OUTPUT -eq 1 -o  $LXV_LOG_OUTPUT -eq 2 ]; then
        echo "${lux_echo_line}" >> "${LXV_LOG_FILE_NAME}"
    fi
}

# # # # # # # # # # #
# function    : lxf_line
# description : lxf_echo <line  [text] line>
# usage       : lxf_line [ -c <char> ] [ -l <lenght> ] [ -t <text> ]
# parameters  : default: <char>='-',<lenght>=80, text=""
# output      :
# obs         :
function lxf_line {

    # utilizadas para validar os parâmetros posicionais
    local lv_opt_found=0
    local lv_list_opt=""
    local lv_key=""
    # utilizadas para receber os argumentos dos parâmetros posicionais
    local lv_char_open="${LXV_LINE_CHAR_OPEN}"
    local lv_char_close="${LXV_LINE_CHAR_CLOSE}"
    local lv_char="${LXV_LINE_CHAR_PAD}"
    local lv_length=${LXV_LINE_LENGTH}
    local lv_text=""
    # utilizadas para compor a linha
    local lv_line=""
    local lv_rep=0
    local lv_repc=0
    local lv_aux=0

    # validação das chaves e argumentos
    OPTIND=1
    while getopts ":c:l:t:" lv_key; do
        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${lv_list_opt}" | grep -q $lv_key
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "chave ${lv_key} não pode ser duplicada"
        fi

        # atualiza controle de chaves executadas
        (( lv_opt_found++ ))
        lv_list_opt="${lv_list_opt};${lv_key}"

        case "${lv_key}" in
            c)
                # caracter de linha
                lv_char="${OPTARG}"
                [ ${#lv_char} -ne 1 ] && lxf_syntax -x -m "key:-${lv_key} ${OPTARG} - caractere de linha deve ter uma posição"
                ;;
            l)
                # extensão da linha
                lv_length="${OPTARG}"
                # checa se é numérico
                echo ${lv_length} | egrep -q -e '^[0-9]+$'
                [ $? -ne 0 ] && lxf_syntax -x -m "key:-${lv_key} ${OPTARG} - extensão deve ser numérica"
                [ ${lv_length} -lt 10 ] && lxf_syntax -x -m "key:-${lv_key} ${OPTARG} - extensão deve ser maior que 9"
                ;;
            t)
                lv_text="${OPTARG}"
                [ ${#lv_text} -eq 0 ] && lxf_syntax -x -m "key:-${lv_key} ${OPTARG} - texto não informado"
                [ "${lv_text:0:1}" = "-" ] && lxf_syntax -x -m "key:-${lv_key} ${OPTARG} - texto substituido por argumento"
                # trim no texto
                lv_text="$(lxf_trim "${lv_text}")"
                ;;
            \?)
                lxf_syntax -x -m "Chave inválida: -${lv_key}"
                ;;
            :)
                lxf_syntax -x -m "Opção -${OPTARG} requer um argumento"
                ;;
        esac
    done

    # validações posteriores
    if [ ${lv_length} -lt $(expr ${#lv_text} + 6) ]; then
       lxf_syntax -x -m "texto com extensão ${#lv_text} maior que a permitida $(expr ${lv_length} - 6)"
    fi

    #
    # construção da linha
    #

    if [ ${#lv_text} -eq 0 ]; then # sem texto
        lv_line+="${lv_char_open}"
        let lv_aux="${lv_length} - 2"
        lv_line+="$(eval "printf "${lv_char}%.0s" {1..${lv_aux}}")"
        lv_line+="${lv_char_close}"
    else
        # caracter inicial
        lv_line+="${lv_char_open}"
        # preenchimento à esquerda, se cálculo resultar em ímpar acrescenta 1
        # o -4 abaixo para compensar os caracteres extras inseridos além dos de preenchimentos
        let lv_rep="( ${lv_length} - ${#lv_text} -4 ) / 2"
        let lv_repc="( ${lv_length} - ${#lv_text} ) % 2"
        let lv_aux="${lv_rep} + ${lv_repc}"
        lv_line+="$(eval "printf "${lv_char}%.0s" {1..${lv_aux}}")"
        lv_line+=" ${lv_text} "

        lv_line+="$(eval "printf "${lv_char}%.0s" {1..${lv_rep}}")"
        lv_line+="${lv_char_close}"
    fi
    lxf_echo "${lv_line}"
}

# # # # # # # # # # #
# function    : lxf_message
# description : mensagem (info, warning, error, fail) com envio de e-mail e saída do script opcionais
# usage       : lxf_message ( -i | -w | -e | -f) [-m] [-s <code>] [-x <err_code>] <msg>
# parameters  :
#   ( -i | -w | -e | -f): apenas uma destas obrigatória indica o tipo de mensagem (info, warning, error ou fail);
#   -m              : se esta chave for informada, desabilita o envio de e-mail;
#   -s <code>       : se informada define o nível de urgência da mensagem (<code> entre 0 e 9); se não, <code>=0;
#   -x <err_code>   : se informado, sai do script  após a emissão da mensagem (<code> deve ser entre 0 e 9);
#   <msg>           : texto a ser emitido, é obrigatório
# output      : lxf_echo [-s <code>] <msg> 
function lxf_message {
    local lv_msg=""
    local lv_err_code=0
    local lv_severity=0
    local lv_flag_tipo=""
    local lv_flag_email=1
    local lv_list_opt=""
    local lv_opt_found=0
    local lv_key=""
    local lv_tipo_txt=""
    local lv_tipo_nr=0

    OPTIND=1
    while getopts ":iwefms:x:" lv_key; do

        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${lv_list_opt}" | grep -q $lv_key
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "chave ${lv_key} não pode ser duplicada"
        fi

        # atualiza controle de chaves executadas
        (( lv_opt_found++ ))
        lv_list_opt="${lv_list_opt};${lv_key}"

        case "${lv_key}" in
            i|w|e|f)
                [ -n "${lv_flag_tipo}" ] && lxf_syntax -x -m "apenas uma destas chaves ( -i | -w | -e | -f ) é necessária para definir o tipo de mensagem"
                lv_flag_tipo="${lv_key}"
                ;;
            m)
                # desabilita o envio de e-mail
                lv_flag_email=0
                ;;
            s)
                echo "${OPTARG}" | egrep -q -e '^[0-9]$'
                [ $? -ne 0 ] && lxf_syntax -x -m "urgência deve ser entre 0 e 9"
                lv_severity=${OPTARG}
                ;;
            x)
                echo "${OPTARG}" | egrep -q -e '^[0-9]{1,2}$'
                [ $? -ne 0 ] && lxf_syntax -x -m "código de erro deve ser entre 1 e 99"
                lv_err_code=${OPTARG}
                [ ${lv_err_code} -eq 0 ] && lv_err_code=1
                ;;
            \?)
                lxf_syntax -x -m "Chave inválida: -${lv_key}"
                ;;
            :)
                lxf_syntax -x -m "Opção -${OPTARG} requer um argumento"
                ;;
        esac
    done

    # identifica o tipo de mensagem
    if [ "${lv_flag_tipo}" = "i" -o "${lv_flag_tipo}" = "" ]; then
        lv_flag_tipo="i"
        lv_tipo_txt="Informativo"
        lv_tipo_nr=0
    elif [ "${lv_flag_tipo}" = "w" ]; then
        lv_tipo_txt="Atenção"
        lv_tipo_nr=1
    elif [ "${lv_flag_tipo}" = "e" ]; then
        lv_tipo_txt="Erro"
        lv_tipo_nr=2
    elif [ "${lv_flag_tipo}" = "f" ]; then
        lv_tipo_txt="Falha"
        lv_tipo_nr=3
    else
        lxf_syntax -x -m "tipo de mensagem ( -i | -w | -e | -f ) não informado"
    fi

    # testa se mensagem não tomada como arguentos anteriores
    if [ $OPTIND -gt 1 ]; then
        shift $((OPTIND-1))
        lv_msg="$1"
        [ -z "${lv_msg}" -o  ${lv_msg:0:1} = "-" ] && lxf_syntax -x -m "Mensagem não informada ou inválida ${lv_msg} "
    fi

    # se for o caso, envia e-mail
    # lxf_echo  "enviando email OPTIND $OPTIND lv_tipo_txt ${lv_tipo_txt} lv_err_code ${lv_err_code} msg ${lv_msg}"
    [ ${lv_flag_email} -gt 0 ] && lxf_email -s "$(printf '%s - err. code:%d' "${lv_tipo_txt}" "${lv_err_code}")" -b "${lv_msg}"

    # emissão da mensagem
    lxf_echo -c ${lv_tipo_nr} -s ${lv_severity} "${lv_msg}"

    # Se for o caso, encerra o script
    if [ $lv_err_code -gt 0 ]; then
        lxf_exit $lv_err_code
    fi

}

# # # # # # # # # # #
# function    : lxf_array_contains
# description : check if an array contains an element
# usage       : lxf_array_contains [-n] $array $element
# parameters  : -n: if if included, the comparison will be numerical
# returns     : 0, if element is in array
# obs         :
function lxf_array_contains {
    local flag_number=0
    local array
    local seeking
   
    # parser dos parâmetros posicionais   
    local lv_list_opt=""
    local lv_opt_found=0
    local lv_key=""
 
    # avaliação dos parâmetros posicionais
    OPTIND=1
    while getopts ":n" lv_key; do
        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${lv_list_opt}" | grep -q $lv_key
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "chave -${lv_key} não pode ser duplicada"
        fi

        # atualiza controle de chaves executadas
        lv_list_opt="${lv_list_opt};${lv_key}"
        
        case "${lv_key}" in
            n)
                # desabilita o envio de e-mail
                flag_number=1
                shift
                ;;
            \?)
                lxf_syntax -x -m "Chave inválida: -${lv_key}"
                ;;
        esac
    done

    array="$1[@]"
    seeking=$2
    
    for element in "${!array}"; do
        # string
        [ $flag_number -eq 0 ] && [ "${element}" = "${seeking}" ] && return 0
        # numérico
        [ $flag_number -eq 1 ] && [ ${element} -eq ${seeking} ] && return 0
    done
    return 1
}

# # # # # # # # # # #
# function    : lxf_last_arg
# description : return the last argument of the list of parameters $@
# usage       : lxf_last_arg "$@"
# returns     : the last element of $@
# error       :
# obs         :
function lxf_last_arg {
    local i=
    for i in "$@"; do :; done

    LXV_RETURN="${i}"
    [ $LXV_ECHO_RETURN -eq 1 ] && echo "${LXV_RETURN}"
}

# # # # # # # # # # #
# function    : lxf_email
# description : send an e-mail
# usage       : lxf_email -t <to e-mail> -s <subject> -b <body>
# returns     : 0, if e-mail was sent successfully
# obs         :
function lxf_email {

    local from_addr="${LXV_SMTP_FROM_ADDR}"
    local from_name="${LXV_SMTP_FROM_NAME}"
    local to="${LXV_SMTP_TO}"
    local subject="${LXV_SMTP_SUBJECT}"
    local server_smtp="${LXV_SMTP_SERVER}"
    local port_smtp=${LXV_SMTP_PORT}
    local body="${LXV_SMTP_BODY}"
    local lv_key=""
    local lv_list_opt=""
    local lv_opt_found=0

    OPTIND=1
    while getopts ":t:s:b:" lv_key; do

        # verifica se chave já foi chamada
        # excluir chaves que foram chamadas mais de uma vez
        echo "${lv_list_opt}" | grep -q $lv_key
        if [ $? -eq 0 ]; then
            lxf_syntax -x -m "chave ${lv_key} não pode ser duplicada"
        fi

        # atualiza controle de chaves executadas
        (( lv_opt_found++ ))
        lv_list_opt="${lv_list_opt};${lv_key}"

        case "${lv_key}" in
            t)
                to="${OPTARG}"
                ;;
            s)
                subject="${subject} ${OPTARG}"
                ;;
            b)
                body=`printf "${body}" "${OPTARG}"`
                ;;
            \?)
                lxf_syntax -x -m "Invalid option: -${pkey}"
                ;;
            :)
                lxf_syntax -x -m "Option -$OPTARG requires an argument"
                ;;
        esac
    done
    shift $((OPTIND-1))

    # checar as sintaxes de acordo com a plataforma
    # cygwin (pacote email deve ser instalado)
    [ -z "${LXV_SMTP_PERFIL}" ] && LXV_SMTP_PERFIL=0

    if [ $LXV_SMTP_PERFIL -eq 0 ]; then
        echo -e "${body}" | /usr/bin/email -s "${subject}" -r "${server_smtp}" -p ${port_smtp} \
-n "${from_name}" -f "${from_addr}" "${to}"
    elif [ $LXV_SMTP_PERFIL -eq 1 ]; then
        echo -e "${body}" | /usr/bin/mailx -s "${subject}" \
 -r "Siafi Script <${from_addr}>" "Suporte Siafi <${to}>" "Cristiano Leite <cristianocesar@mpf.mp.br>"
    fi
    return 0
}

# # # # # # # # # # #
# function    : lxf_func_exists
# description : verify if a function is defined
# usage       : lxf_func_exists <function_name>
# returns     : 0, if yes, 1 otherwise
# obs         :
function lxf_func_exists {
    declare -f -F $1 > /dev/null
    return $?
}

# # # # # # # # # # #
# function    : lxf_exit
# description : tratamentos finais e saída do programa
# usage       : lxf_exit <exit_code>
# obs         : vazio ou não numérico, implica exit_code=0
function lxf_exit {
    exit_code=$1

    # se não for uma sequência de dígitos, fica 0
    echo ${exit_code} | egrep -q "^[0-9]+$"
    [ $? -ne 0 ] && exit_code=0

    lxf_func_exists lxf_func_exit
    if [ $? -eq 0 ]; then
        lxf_func_exit $exit_code
    fi

    exit $exit_code
}


####
#
# Se chegou até aqui, esta variável é setada para 1
#
####
export LXV_FLAG_FUN=1
