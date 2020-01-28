/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Arquivo      : cnpj_cpf.js
 * Tipo         : classe javascript
 * Objetivo     : validação de CPF/CNPJ
 * Observações  :
 *   #version;user;(bug id's);date;description
 *   0.1.0;lhmp;(#);20/12/2019; versão beta1
 *   0.0.1dr;lhmp;(#);17/12/2019; versão draft
 */

/**
 * Class: Cpf
 * version: 0.1.0;lhmp;(#);18/12/2019
 */
 
class Cpf {
    /* constructor */
    constructor(p_cpf) {
        
        // validações iniciais
        if ( typeof p_cpf !== 'string' ) {
            throw "Parâmetro p_cpf " + p_cpf + " deve ser do tipo string!";
        }
        
        // retira não numéricos
        p_cpf = p_cpf.replace(/\D/g,'');
               
        /* attributes */
        this._cpf = p_cpf;   // retira não numéricos
        this._er = /^[0-9]{11}$/;
        this._er_mask = /^[0-9]{3}\.?[0-9]{3}\.?[0-9]{3}\-?[0-9]{2}$/;
        this._status = 0;   // 0-não testado;1-válido;2-inválido
    }


    /* getters and setters */
    get cpf() {
        return this._cpf;
    }
    
    set cpf(p_cpf) {
        // validações iniciais
        if ( typeof p_cpf !== 'string' ) {
            throw "Parâmetro p_cpf " + p_cpf + " deve ser do tipo string!";
        }
        
        // retira não numéricos
        p_cpf = p_cpf.replace(/\D/g,'');   // retira não numéricos
        
        // atribuição
        this._cpf = p_cpf;
        this._status = 0;
    }

    get status() {
        return this._status;
    }

    /* others methods */
    validar() {
       this._status = ( this._validarCpf(this._cpf) ? 1 : 2);
       return ( this._status == 1 ) ? true : false;
    }

    show_status() {
        let str_out='CPF: ' + this._cpf + ' - status: ' + this._status;
        console.log(str_out);
        return str_out;
    }

    /* functions */
        
    //
    // validação de CPF
    //
    _validarCpf(p_cpf) {

        //
        // testes iniciais: descarta nulos, não strings e string que não é numérica de 11 dígitos
        //

        if ( typeof p_cpf !== 'string' ) { return false; }

        if ( ! ( this._er.test(p_cpf)) ) { return false; }

        //
        //  regra de validação do CPF
        //

        // quebra o CPF em 2 partes
        let cpf9digs=p_cpf.substring(0,9);
        let cpf2digs=p_cpf.substring(9,11);

        let soma=0;
        let digv="";
        let digv1=0;
        let digv2=0;
        let p=0;
        let dig=0;
        let mod11soma=0;

        // obtenção do primeiro dígito
        for(p=10;p>=2;p--) {
            dig=parseInt(cpf9digs.charAt(10-p));
            soma+=p*dig;
        }
        mod11soma = soma % 11;
        digv1=(mod11soma<2) ? 0 : (11-mod11soma);

        // obtenção do segundo dígito
        let cpf10digs= "" + cpf9digs + digv1;
        soma=0;
        digv2=0;
        for(p=11;p>=2;p--) {
            dig=parseInt(cpf10digs.charAt(11-p));
            soma+=p*dig;
        }
        mod11soma = soma % 11;
        digv2 = (mod11soma<2) ? 0 : (11-mod11soma);

        // dígito verificador completo
        digv= "" + digv1 + digv2;

        return (( digv === cpf2digs ) ? true : false);
    }
}

/**
* Class: Cnpj
* version: 0.1.0;lhmp;(#);18/12/2019
*/
class Cnpj {

    /* getters and setters */
    constructor(p_cnpj) {
        
        // validações iniciais
        if ( typeof p_cnpj !== 'string' ) {
            throw "Parâmetro p_cnpj " + p_cnpj + " deve ser do tipo string!";
        }
        
        // retira não numéricos
        p_cnpj = p_cnpj.replace(/\D/g,'');

        /* attributes */
        this._cnpj = p_cnpj;
        this._er = /^[0-9]{14}$/;
        this._er_mask = /^[0-9]{2}\.?[0-9]{3}\.?[0-9]{3}\/?[0-9]{4}\-?[0-9]{2}$/;
        this._status = 0;   // 0-não testado;1-válido;2-inválido
    }

    /* getters and setters */
    get cnpj() {
        return this._cnpj;
    }

    set cnpj(p_cnpj) {
        // validações iniciais
        if ( typeof p_cnpj !== 'string' ) {
            throw "Parâmetro p_cnpj " + p_cnpj + " deve ser do tipo string!";
        }
        
        // retira não numéricos
        p_cnpj = p_cnpj.replace(/\D/g,'');
        this._cnpj = p_cnpj;
    }

    /* others methods */
    get status() {
        return this._status;
    }

    /* others methods */
    validar() {
       this._status = ( this._validarCnpj(this._cnpj) ? 1 : 2);
       return ( this._status == 1 ) ? true : false;
    }

    show_status() {
        let str_out='CNPJ: ' + this._cnpj + ' - status: ' + this._status;
        console.log(str_out);
        return str_out;
    }

    /* functions */
        
    //
    // validação de CPF
    //
    _validarCnpj(p_cnpj) {
        //
        // testes iniciais: descarta nulos, não strings e string que não é numérica de 11 dígitos
        //
        
        if ( typeof p_cnpj !== "string" ) { return false; }
    
        let ereg = new RegExp('^\\d{14}$');
        if ( ! ( ereg.test(p_cnpj)) ) { return false; }
    
        //
        //  regra de validação do CNPJ
        //
        
        // quebra o CPF em 2 partes
        let cnpj12digs=p_cnpj.substring(0,12);
        let cnpj2digs=p_cnpj.substring(12,14);
        
        let soma=0;
        let digv1=0;
        let digv2=0;
        let dig=0;
        let p=0,i=0;
        let digv="";
        let mod11soma=0;     
    
        //
        // regra de validação do CNPJ
        //
        
        // obtenção do primeiro dígito
        soma=0;
        digv1=0;
        p=2; // peso inicial
        for(i=12;i>=1;i--) {
            dig = parseInt(cnpj12digs.charAt(i-1));
            soma += p * dig;
            p= (p==9) ? 2 : (p+1);
        }
        mod11soma = soma%11;
        digv1= (mod11soma<2) ? 0 : (11-mod11soma);
    
        // obtenção do segundo dígito
        let cnpj13digs="" + cnpj12digs + digv1;
        soma=0;
        digv2=0;
        p=2; // peso inicial
        for(i=13;i>=1;i--) {
            dig=parseInt(cnpj13digs.charAt(i-1));
            soma += p * dig;
            p=(p==9) ? 2 : (p+1);
        }
        mod11soma=soma%11;
        digv2=(mod11soma<2)?0:(11-mod11soma);
        
        // dígito verificador completo
        digv="" + digv1 + digv2;
        
        return (( digv == cnpj2digs ) ? true : false);
    }
}


