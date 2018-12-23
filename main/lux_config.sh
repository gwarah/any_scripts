#!/bin/bash
# =======================================================================
# Project      : Luxes
# Author       : gwarah    
# File         : lux_config.sh
# Description  : main configuration
#
# Versions
#   0.0.1dr;;gwarah; 22/12/2018; first draf
# ======================================================================
#

##########
#  Warning: under construction!!!
##########

####
#
# Module actve => set to 1  
#
####
export LXV_FLAG_ENV=0

####
#
# general use variables
#
####
export LXV_CR="\n"                  # CR char
export LXV_RETURN=0                 # Return value of a function or script
export LXV_ECHO_RETURN=1            # 1, echoes the function return; 0, not
export LXV_DELIM_DATE="/"           # date delimiter
export LXV_DELIM_TIME=":"           # time delimiter
export LXV_MASK_DATE="%d/%m/%Y"     # default date mask
export LXV_MASK_TIME="%H:%M:%S"     # default time mask

####
#
# paths utilizados pelos scripts
#  obs: ver função para redefinição dos paths de log e tmp
####
export LXV_PATH_SCR=~/.lux                # path default de trabalho
export LXV_PATH_LOG=${LXV_PATH_SCR}/log   # path default de logs de execuçãos dos scripts
export LXV_PATH_TMP=${LXV_PATH_SCR}/tmp   # path default de arquivos temporários

####
#
# variáveis relacionadas a função lxf_line
#
####
export LXV_LINE_CHAR_PAD='='    # caracter de preenchimento  (*)
export LXV_LINE_CHAR_OPEN='<'   # caracter de início de linha (*)
export LXV_LINE_CHAR_CLOSE='>'  # caracter de fechamento de linha (*)
export LXV_LINE_LENGTH=50       # tamanho default da linha

# (*) Alguns caracteres especiais podem ter problemas

####
#
# variáveis relacionadas ao uso de logs
#
####
export LXV_LOG_OUTPUT=0                      # 0, saída em tela (default); 1, arquivo; 2, ambos
export LXV_LOG_FILE_TITILE='log'             # nome do arquivo de log
export LXV_LOG_FILE_MASK='%Y%m'              # máscara de data o registro do log

# obs: ver função lxf_get_logfile
export LXV_LOG_FILE_NAME="${LXV_PATH_LOG}/${LXV_LOG_FILE_TITILE}_$(date +${LXV_LOG_FILE_MASK}).txt"

# formato do registro de log
# <data hora>;<categoria>;<urgencia>;<tags>;<msg>
#
#    Campos:
#
# <data hora> : formato definido pela variável LXV_LOG_REG_MASK
# <categoria> : 0-INFORMATIVO (default);1-ATENÇÃO;2-ERRO;3-FALHA
# <urgencia>  : 0-9; 0,pouco urgente (default); 9, máxima urgência
# <tags>      : tags, separadas por vírgulas. Sequência de espaços e/ou ponto-e-vírgulas são substituídos por vírgulas
# <msg>       : msg, a mensagem
export LXV_LOG_REG_MASK='%d/%m/%Y %H:%M:%S'  # máscara de data default para o registro do log
export LXV_LOG_REG_CATEGORY=0                # categoria default do registro do log
export LXV_LOG_REG_SEVERITY=0                # severidade default do registro do log

# array com grupos de logs (não implementad ainda)
export LXV_LOG_GROUP=( )

####
#
# variáveis necessárias para o envio de e-mails
#
####
export LXV_SMTP_ENABLE=1                            # 0, dont send e-mail; 1, do (Default)
export LXV_SMTP_PERFIL=0                            # 0, CYGWIN (default, desenvolvimento); 1, linux (produção)
export LXV_SMTP_MSG=1                               # 0, indica que funções de mensagens de erros e warnings, não serão replicadas via e-mail
export LXV_SMTP_FROM_ADDR="email_from@myprovider.com"
export LXV_SMTP_FROM_NAME="Luxes Notification System"
export LXV_SMTP_TO="email_to@myprovider.com"
export LXV_SMTP_SUBJECT="[Luxes Notify System] "
export LXV_SMTP_SERVER="mysmtp.com"
export LXV_SMTP_PORT=25
export LXV_SMTP_BODY="\
Warning: Authomatic messge. Please don't reply it.${LXV_CR}\
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #${LXV_CR}\
${LXV_CR}\
%s${LXV_CR}\
${LXV_CR}\
-------------------------------------------------------------${LXV_CR}\
Support information ${LXV_CR}\
"

####
#
# variáveis relacionadas ao módulo lux_dialogs.sh
#   0 shell basic commands (default);
#   1 dialog functions; 
#   2 zenity functions; 
#   3 whiptail functions;
#   4 windows script functions;
#
####
export LXV_DIALOG_TYPE=0                            

####
#
# Se chegou até aqui, esta variável é setada para 1
#
####
export LXV_FLAG_ENV=1
