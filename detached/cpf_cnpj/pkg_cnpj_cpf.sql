--
-- Teste com um destes 3 comandos. 1: CPF/CNPJ válido; 2: inválido
--

-- Para testar um CPF
-- select pkg_cnpj_cpf.cpf_valido('&cpf') from dual;

-- Para testar um CNPJ
-- select pkg_cnpj_cpf.cnpj_valido('&cnpj') from dual;

-- Para testar um CPF ou CNPJ
-- select pkg_cnpj_cpf.cpf_cnpj_valido('&cpf_cnpj') from dual;



-- /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * Arquivo      : pkg_cnpj_cpf.sql
-- * Tipo         : pacote pl/sql (specification)
-- * Objetivo     : validação de CPF/CNPJ
-- * Observações  :
-- *   #version;user;(bug id's);date;description
-- *   0.0.2b;lhmp;(#);17/12/2019; versão beta
-- *   0.0.1dr;lhmp;(#);17/12/2019; versão draft
-- */

CREATE OR REPLACE PACKAGE pkg_cnpj_cpf AS
    subtype tp_validacao is number(1);

    /* valores para as situações do CPF válido ou inválido */
    VL_VALIDO   CONSTANT tp_validacao := 1;
    VL_INVALIDO CONSTANT tp_validacao := 2;

    /* testa se cpf é válido */
    FUNCTION cpf_valido (
      cpf  VARCHAR2
    ) RETURN tp_validacao;

    /* testa se cnpj é válido */
    FUNCTION cnpj_valido (
      cnpj  VARCHAR2
    ) RETURN tp_validacao;

    /* testa se cpf/cnpj é válido */
    FUNCTION cpf_cnpj_valido (
      cpf  VARCHAR2
    ) RETURN tp_validacao;
END pkg_cnpj_cpf;
/

-- /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * Arquivo      : pkg_cnpj_cpf.sql
-- * Tipo         : pacote pl/sql (body)
-- * Objetivo     : validação de CPF/CNPJ
-- * Observações  :
-- *   #version;user;(bug id's);date;description
-- *   0.0.2b;lhmp;(#);19/12/2019; versão beta
-- *   0.0.1dr;lhmp;(#);17/12/2019; versão draft
-- */
CREATE OR REPLACE PACKAGE BODY pkg_cnpj_cpf AS
    
    /* testa se cpf é válido */
    FUNCTION cpf_valido (
      cpf  VARCHAR2
    ) RETURN tp_validacao IS
        resultado tp_validacao := VL_VALIDO;
        num_aux   integer := 0;
        p         number(2) := 0;
        mod11soma number(2) := 0;
        dig       number(1) := 0;
        digv1     integer := 0;
        digv2     integer := 0;
        soma      integer := 0;
        cpf_aux   varchar2(255);
        cpf10digs  varchar2(10);
        cpf9digs  varchar2(9);
        cpf2digs  varchar2(2);
        digv_str  varchar2(2);
    BEGIN
        cpf_aux:=trim(cpf);

        -- testes iniciais
        num_aux := 0;
        SELECT count(1) into num_aux FROM DUAL WHERE REGEXP_LIKE(cpf_aux, '^\d{11}$', '');
        if num_aux = 0 then
            RETURN VL_INVALIDO;
        end if;
        
        --
        -- teste do CPF
        --

        -- quebra o CPF em 2 partes
        cpf9digs := substr(cpf_aux,1,9);
        cpf2digs := substr(cpf_aux,10,2);

        -- obtenção do primeiro dígito
        soma:=0;
        digv1:=0;

        FOR p IN REVERSE 2 .. 10 LOOP
            dig := to_number(substr(cpf9digs,(11-p),1));
            soma := soma + (p*dig);
        END LOOP;

        mod11soma:=mod(soma,11);
        if mod11soma < 2 then
            digv1:=0;
        else
            digv1:=11-mod11soma;
        end if;

        -- obtenção do segundo dígito
        cpf10digs:=cpf9digs || digv1;
        soma:=0;
        digv2:=0;

        FOR p IN REVERSE 2 .. 11 LOOP
            dig := to_number(substr(cpf10digs,(12-p),1));
            soma := soma + (p*dig);
        END LOOP;

        mod11soma:=mod(soma,11);
        if mod11soma < 2 then
            digv2:=0;
        else
            digv2:=11-mod11soma;
        end if;

        -- dígito verficador completo
        digv_str := '' || digv1 || digv2;

        -- comparação
        resultado := VL_INVALIDO;
        if digv_str = cpf2digs then 
            resultado := VL_VALIDO;
        end if;

        return resultado;
    END cpf_valido;

    /* testa se cnpj é válido */
    FUNCTION cnpj_valido (
      cnpj  VARCHAR2
    ) RETURN tp_validacao IS
        resultado   tp_validacao := VL_VALIDO;
        num_aux     integer := 0;
        p           number(2) := 0;
        q           number(2) := 0;
        mod11soma   number(2) := 0;
        dig         number(1) := 0;
        digv1       integer := 0;
        digv2       integer := 0;
        soma        integer := 0;
        cnpj_aux    varchar2(255);
        cnpj13digs  varchar2(13);
        cnpj12digs  varchar2(12);
        cnpj2digs   varchar2(2);
        digv_str    varchar2(2);
    BEGIN
        cnpj_aux:=trim(cnpj);

        -- testes iniciais
        num_aux := 0;
        SELECT count(1) into num_aux FROM DUAL WHERE REGEXP_LIKE(cnpj_aux, '^\d{14}$', '');
        
        if num_aux = 0 then
            RETURN VL_INVALIDO;
        end if;

        --
        -- teste do CNPJ
        --

        -- quebra o CNPJ em 2 partes
        cnpj12digs := substr(cnpj_aux,1,12);
        cnpj2digs := substr(cnpj_aux,13,2);

        -- obtenção do primeiro dígito
        soma:=0;
        digv1:=0;
        q:=2; -- peso inicial
        FOR p IN REVERSE 1 .. 12 LOOP
            dig := to_number(substr(cnpj12digs,p,1));
            soma := soma + (q*dig);
            
            if q = 9 then
                q:=2;
            else
                q:=q+1;
            end if;
        END LOOP;
        mod11soma := mod(soma,11);
        if mod11soma < 2 then
           digv1 := 0;
        else
           digv1 := 11-mod11soma;
        end if;

        -- obtenção do segundo dígito
        cnpj13digs:=cnpj12digs || digv1;
        soma:=0;
        digv2:=0;
        q:=2; -- peso inicial
        
        FOR p IN REVERSE 1 .. 13 LOOP
            dig := to_number(substr(cnpj13digs,p,1));
            soma := soma + (q*dig);
            
            if q = 9 then
                q:=2;
            else
                q:=q+1;
            end if;
        END LOOP;
        
        mod11soma := mod(soma,11);
        if mod11soma < 2 then
           digv2 := 0;
        else
           digv2 := 11-mod11soma;
        end if;
        
        -- dígito verficador completo
        digv_str := '' || digv1 || digv2;

        -- comparação
        -- dbms_output.put_line('digitos ' || digv_str);
        resultado := VL_INVALIDO;
        if digv_str = cnpj2digs then 
            resultado := VL_VALIDO;
        end if;
        
        return resultado;
    END cnpj_valido;

    /* testa se cpf/cnpj é válido */
    FUNCTION cpf_cnpj_valido (
      cpf  VARCHAR2
    ) RETURN tp_validacao IS
        resultado tp_validacao := VL_VALIDO;
    BEGIN
        resultado := cpf_valido(cpf);
        if resultado <> VL_INVALIDO then
            return resultado;
        end if;
        
        resultado := cnpj_valido(cpf);
        
        return resultado;
    END cpf_cnpj_valido;
END pkg_cnpj_cpf;
/