#!/bin/bash
# =======================================================================
# Project      : Luxes
# Author       : gwarah
# File         : lux_config.sh
# Description  : main configuration
#
# Versions
#   0.0.1dr;;gwarah; 22/12/2018; first draf
#   0.0.1a;;gwarah; 01/06/2019; first alpha version
# ======================================================================
#

####
#
# Module loaded ok => LXV_FLAG_ENV=1
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
# Directories for the main tasks (Ex. logs and temp files)
#
####
export LXV_PATH_SCR=~/.lux                # main directory
export LXV_PATH_LOG=${LXV_PATH_SCR}/log   # log directory
export LXV_PATH_TMP=${LXV_PATH_SCR}/tmp   # temp files directory

####
#
# used by function lxf_line
#
####
export LXV_LINE_CHAR_PAD='='    # pad char  (*)
export LXV_LINE_CHAR_OPEN='<'   # begin of line char  (*)
export LXV_LINE_CHAR_CLOSE='>'  # end of line char (*)
export LXV_LINE_LENGTH=50       # line length

# (*) carefull with some special chars, ex. "-"

####
#
# used by function lxf_echo
#
####
export LXV_LOG_OUTPUT=0                      # set the output stream: 0, stdout (default); 1, file ${LXV_LOG_FILE_NAME}; 2, both
export LXV_LOG_FILE_PREFIX='log'             # prefix of the name of file log
export LXV_LOG_FILE_MASK='%Y%m'              # date mask
# file name
export LXV_LOG_FILE_NAME="${LXV_PATH_LOG}/${LXV_LOG_FILE_PREFIX}_$(date +${LXV_LOG_FILE_MASK}).txt"

# lxf_echo output register
# <date_time>;<category>;<level>;<tags>;<text>
#
#    fields:
#
# <date_time> : see variable LXV_LOG_REG_MASK
# <category>  : 0-INFORMATION (default);1-WARING;2-ERROR;3-FAIL
# <level>     : 0-9; 0,low severity (default); 9, max severity
# <tags>      : tags, delimited by commas. spaces and/or semicolons will be replaced by commas
# <text>      : text, a mensagem
export LXV_LOG_REG_MASK='%d/%m/%Y %H:%M:%S'  # default date mask
export LXV_LOG_REG_CATEGORY=0                # default category
export LXV_LOG_REG_SEVERITY=0                # default severity

####
#
# used by function lxf_email
#
####

# profile 0, CYGWIN (default); 1, linux
# each profile demands a program different to send the e-mail
# See function lxf_email to more details
export LXV_SMTP_PERFIL=0

export LXV_SMTP_ENABLE=1            # 0, don't send e-mail; 1, do (Default)
export LXV_SMTP_MSG=1               # 0, flag to function lxf_message doesn't send an e-mail


export LXV_SMTP_FROM_ADDR="email_from@myprovider.com"   # e-mail from 
export LXV_SMTP_FROM_NAME="Luxes Notification System"   # e-mail from name
export LXV_SMTP_TO="email_to@myprovider.com"            # e-mail to
export LXV_SMTP_SUBJECT="[Luxes Notify System] "        # e-mail to name
export LXV_SMTP_SERVER="mysmtp.com"                     # SMTP server
export LXV_SMTP_PORT=25                                 # SMTP port

# SMTP body. The %s mark will be replaced with text message
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
# variables related to dialog modules. See lux_dialogs.sh for more details
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
# Module Loaded! \o/
#
####
export LXV_FLAG_ENV=1
