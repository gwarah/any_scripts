#!/usr/bin/awk
# Arquivo    : cnpj_cpf.awk
# Objentivo  : funções para validação de CPF e CNPJ
# Requisites :
#     1. SHELL=bash
#     
# History    :
#   #version;date;description
#   0.1.1b; 23/12/2019; retorna 1 pelo menos um CPF da lista for inválido
#   0.1.0b; 23/12/2019; first release 
#

#
# Tested: cygwin environment
# 

# verificação de CPF
function check_cpf(p_cpf) {
  
    # comprimento deve ter onze posições
    if (! ( p_cpf ~ /^[[:digit:]]{11}$/ )) { return FALSE; }
    
    ###
    # regra de validação do CPF
    ###
    
    # quebra o CPF em 2 partes
    cpf9digs=substr(p_cpf,1,9);
    cpf2digs=substr(p_cpf,10,2);
    
    # obtenção do primeiro dígito
    soma=0;
    digv1=0;
    for(p=10;p>=2;p--) {
       dig=substr(cpf9digs,(11-p),1);
       soma+=p*dig;
    }
    mod11soma=soma%11;
    digv1=(mod11soma<2)?0:(11-mod11soma);
        
    # obtenção do segundo dígito
    cpf10digs=cpf9digs digv1;
    soma=0;
    digv2=0;
    for(p=11;p>=2;p--) {
       dig=substr(cpf10digs,(12-p),1);
       soma+=p*dig;
    }
    mod11soma=soma%11;
    digv2=(mod11soma<2)?0:(11-mod11soma);
    
    # dígito verificador completo
    digv=digv1 digv2;
    
    return (( digv == cpf2digs ) ? TRUE : FALSE);
}

# verificação de CNPJ
function check_cnpj(p_cnpj) {
       
    # comprimento deve ter onze posições
    if (! ( p_cnpj ~ /^[[:digit:]]{14}$/ )) { return FALSE; }
    
    ###
    # regra de validação do CNPJ
    ###
    
    # quebra o CNPJ em 2 partes
    cnpj12digs=substr(p_cnpj,1,12);
    cnpj2digs=substr(p_cnpj,13,2);
    
    # obtenção do primeiro dígito
    soma=0;
    digv1=0;
    p=2; # peso inicial
    for(i=12;i>=1;i--) {
       dig=substr(cnpj12digs,i,1);
       soma+=p*dig;
       p=(p==9)?2:(p+1);
    }
    mod11soma=soma%11;
    digv1=(mod11soma<2)?0:(11-mod11soma);
  
    # obtenção do segundo dígito
    cnpj13digs=cnpj12digs digv1;
    soma=0;
    digv2=0;
    p=2; # peso inicial
    for(i=13;i>=1;i--) {
       dig=substr(cnpj13digs,i,1);
       soma+=p*dig;
       p=(p==9)?2:(p+1);
    }
    mod11soma=soma%11;
    digv2=(mod11soma<2)?0:(11-mod11soma);
       
    # dígito verificador completo
    digv=digv1 digv2;
    
    return (( digv == cnpj2digs ) ? TRUE : FALSE);
}

#
# Variáveis devem ser declaradas neste bloco
#
BEGIN {
    # boolean values
    TRUE=1;
    FALSE=0;
    
    # retorna TRUE caso pelo menos um CPF/CNPJ da lista for inválido
    p_retorno=TRUE;
}
{
    p_valor=$0;
    p_flag=0;
    
    # se for CPF
    if ( p_valor ~ /^[[:digit:]]{11}$/ ) {
        p_flag=1;
        printf "CPF " p_valor " -  resultado: "; 
        if ( check_cpf(p_valor) == TRUE ) { print "válido";}
        else { 
            p_retorno=FALSE;
            print "inválido";
        }
    }
    
    # se for CNPJ
    if ( p_valor ~ /^[[:digit:]]{14}$/ ) {
        p_flag=1;
        printf "CNPJ " p_valor " -  resultado: "; 
        if ( check_cnpj(p_valor) == TRUE ) { print "válido";}
        else { 
            p_retorno=FALSE;
            print "inválido";
        }
    }
    
    # se não for CPF ou CNPJ
    if ( p_flag == 0 ) {
        p_retorno=FALSE;
        printf p_valor " não é nem CPF nem CNPJ "; 
    }
}
END {
    exit p_retorno;
}