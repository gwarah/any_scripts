#!/usr/bin/awk
# File       : lux_csv_search.awk
# Goal       : search a pattern in a csv file
# Requisites :
#     1. SHELL=bash
#     2. external variables: v_line_search and v_text
#     
# History    :
#   #version;date;description
#   0.1.0; 12/02/2020; first beta test
#   0.0.1; 11/02/2020; first draft
#
BEGIN {
    # line of start searching
    # must be included in the calling of program and must be numeric
    # =1, if these conditions not satisfied
    if ( length(v_line_search) == 0) { v_line_search=1; }
    if (! ( v_line_search ~ /^[[:digit:]]+$/ )) { v_line_search=1; }
    
    # line that v_text matches with $0 or $v_field
    # =-1, if  no match
    line_match=-1;
}
{
    # ignore line 1 e lines before v_line_search
    if ( NR == 1 || NR <= (v_line_search + 1) ) {
        next;
    }
    
    # if found end the process
    IGNORECASE = 1
    if ( $0 ~ v_text ) {
        # cabeçalho não conta
        line_match=NR-1;
        exit;
    }
}
END {
    # output the line match
    print line_match;
}