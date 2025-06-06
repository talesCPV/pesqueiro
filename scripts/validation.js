function getEnter(e, button = '',screen=''){
    var keynum;

    if(window.event) { // IE                  
      keynum = e.keyCode;
    } else if(e.which){ // Netscape/Firefox/Opera                 
      keynum = e.which;
    }

    if(keynum == 13){
        if(screen==''){
            document.querySelector('#'+button).click()
        }else{
            screen.querySelector('#'+button).click()
        }
    }
}

function checkField(fields){
    
    for(let i=0; i< fields.length; i++){
        if(document.getElementById(fields[i]).value.trim() == ''){
            alert('Favor preencher todos os campos obrigatórios.')
            document.getElementById(fields[i]).focus()
            return false
        }
    }
    return true
}

function checkRepass(fields){
    const check = document.getElementById(fields[0]).value
    for(let i=1; i<fields.length; i++){
        if(document.getElementById(fields[i]).value != check){
            alert('Por favor, repita a senha digitada.')
            document.getElementById(fields[i]).focus()
            return false
        }
    }
    return true
}

function valInt(edt){
    edt.value = getNum(edt.value)
}

function valFloat(edt,dec=2){
    edt.value = getFloat(edt.value,dec)
}

function valCPF(edt){
    edt.value = getCPF(getNum(edt.value))
}

function valCEP(edt){
    edt.value = getCEP(getNum(edt.value))
}

function valPIS(edt){
    edt.value = getPIS(getNum(edt.value))
}

function valRG(edt){
    edt.value = getRG(getNum(edt.value))
}

function valCNPJ(edt){
    edt.value = getCNPJ(getNum(edt.value))
}

function valIE(edt){
    edt.value = getIE(getNum(edt.value))
}

function valTime(edt){
    edt.value = getTime(getNum(edt.value))
}

function fillTime(edt){
    edt.value = getTime(getNum(edt.value)+'0000')
}

function valPlaca(edt){
    edt.value = getPlaca(edt.value)
}

function valTel(edt){ 
    edt.value = getFone(edt.value)
}

function valMoney(edt){
    const num = getNum(edt.value).toString().padStart(3,0) 
    edt.value = 'R$'+Number(num.substr(0,num.length-2)+'.'+num.substr(-2)).toFixed(2)
}


function getFloat(text,dec=2){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0']
    let before_dot = '0';
    let after_dot = '';
    let dot =  '';
    let signal = 1
    for(var i = 0; i<text.length; i++){
        if(dot.length == 0){
            if(['.',','].includes(text[i])){
                dot = '.'
            }else{
                if((before_dot=='' || before_dot=='0') && text[i]=='-'){
                  signal = -1
                }
                before_dot +=  ok_chr.includes(text[i]) ? text[i] : ''
            }
        }else{
            if(after_dot.length < dec){
                after_dot +=  ok_chr.includes(text[i]) ? text[i] : ''
            }
        }
    }     
    return (parseInt(before_dot) * signal).toString() +dot+after_dot;
}

function getNum(V){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    let out = ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            out+=V[i]
        }
    }
    return out
}

function getNumComa(V,dec=2){
    V = parseFloat(V).toFixed(dec)
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0','.',','];
    let out = ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            out+= V[i]=='.' ? ',' : V[i]
        }
    }
    return out
}

function getPIS(V){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    let out = ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            if(i==3 || i==8){
                out+='.'
            }else if(i==10){
                out+='-'
            }
            out+=V[i]            
        }
    }
    return out
}

function getCPF(V){
    V = getNum(V)
    let out = ''
    for(let i=0; i< V.length; i++){
        if(i==3 || i==6){
            out+='.'
        }else if(i==9){
            out+='-'
        }
        out+=V[i]            
    }
    return out
}

function getRG(V){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    let out = ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            if(i==2 || i==5){
                out+='.'
            }else if(i==8){
                out+='-'
            }
            out+=V[i]            
        }
    }
    return out
}

function getCNPJ(V){
    V = getNum(V)
    let out = ''
    for(let i=0; i< V.length; i++){
        if(i==2 || i==5){
            out+='.'
        }else if(i==8){
            out+='/'
        }else if(i==12){
            out+='-'
        }
        out+=V[i]            
    }
    return out
}

function getIE(V){
    V = getNum(V)
    let out = ''
    for(let i=0; i< V.length; i++){
        if(i==3 || i==6 || i==9){
            out+='.'
        }
        out+=V[i]
    }    
    return out
}

function getCEP(V){
    const ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    let out = ''
    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i])){
            if(i==2){
                out+='.'
            }else if(i==5){
                out+='-'
            }
            out+=V[i]            
        }
    }
    return out
}

function getTime(V){
    let out = ''
    for(let i=0; i< V.length; i++){
        let print = true
        if(i == 0){
            if(!['0','1','2'].includes(V[i])){
               print = false
            }
        }else if(i==1){
            if(V[0] == 2 && !['0','1','2','3'].includes(V[i])){
                print = false
            }
        }else if(i==2){
            out+=':'
            if(!['0','1','2','3','4','5'].includes(V[i])){
                print = false
            }
        }

        print ? out+=V[i] : 0        
        out.length>=5 ?  i = V.length : 0

    }
    return out
}

function getFone(V){
    let num = getNum(V)
    let out = '';
    for(i=0;i<num.length;i++){
        chr = num.substring(i,i+1);
        if(i == 0){
            out = '(' + out ;
        }
        if(i == 2){
            out = out + ')';
        }
        if(i == 6){
            out = out + '-';
        }
        if(i == 10){
            out = out.substring(0,5) +" "+out.substring(5,8)+out.substring(9,10)+"-"+out.substring(10,13)
        }		
        out = out + chr;			
    }
    return out
}

function getPlaca(V){
    const ok_num = ['1','2','3','4','5','6','7','8','9','0'];
    const ok_chr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','X','Y','W','Z',
                    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','x','y','w','z'];
    let out = ''
    let into = ''

    for(let i=0; i< V.length; i++){
        if(ok_chr.includes(V[i]) || ok_num.includes(V[i])){
            into += V[i].toUpperCase()
        }
    }

    for(let i=0; i< into.length; i++){
            if(i==3){
                out+='-'
            }

            if(i<3 && ok_chr.includes(into[i])){
                out+=into[i]                
            }else if( i>=3 && ok_num.includes(into[i]) || i==4 ){
                out+=into[i]                
            }
    }
    return out
}


function dataBR(V){
    return V.substring(8,10)+'/'+V.substring(5,7)+'/'+V.substring(0,4)
}

function horaBR(V){
    return V.substring(11,16)
}

function viewMoneyBR(V){
    const num = getNum(V)
    let out = ''
    for(let i=num.length-1; i>=0; i--){        
        out = num[i] + out        
        out = i==num.length-2 ? ','+out : (i-num.length-1)%3==0 && i!=0 && i< num.length-3 ? '.'+out : out
    }
    return 'R$'+out
}

function horario(edt){
    let ok_chr = ['1','2','3','4','5','6','7','8','9','0'];
    var num = edt.value;
    var count = 0;
    var out = '';

    for(i=0;i<num.length;i++){
        chr = num[i]
        if(ok_chr.includes(chr)){

            count++;
            if(count == 3 ){
                out += ':' ;
            }
            out += chr;	
        }
		
    }

    if(out.length == 1){
        out = parseInt(out)<3 ? out : ''
    }else if(out.length == 2){
        out = parseInt(out)<24 ? out : out.substring(0,1)
    }else if(out.length == 4){
        out = parseInt(out.substring(3,4))< 6 ? out : out.substring(0,3)
    }

    edt.value = out;
}

function hideOrig(){
    if(document.querySelector('#cmbEntSai').value == 'ENTRADA'){
        document.querySelector('#cmbOrigem').disabled = true
    }else{
        document.querySelector('#cmbOrigem').disabled = false
    }
}


function checkEmail (email){
    return email.match(
      /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    );
};

function validaEmail(edt){
    edt.value = edt.value.trim()
    if(checkEmail(edt.value)){
        edt.style.color = 'green'
        return true
    } else{
        edt.style.color = 'red'
        return false
    }

}

function troco(id_tot,edtRec,id_troco){
    total = Number(getNum(document.getElementById(id_tot).value))
    recebido = Number(getNum(edtRec.value))
    const trc = (recebido-total)/100
    document.getElementById(id_troco).value = 'R$'+( trc<0 ? 0 : trc ).toFixed(2)
}