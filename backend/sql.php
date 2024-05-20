<?php

    $query_db = array(
        /* LOGIN */
        "LOG-0"   => 'CALL sp_login("x00", "x01");', // USER, PASS

        /* USERS */
        "USR-0"   => 'CALL sp_viewUser(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "USR-1"   => 'CALL sp_setUser(@access,@hash,x00,"x01","x02","x03");', // ID, EMAIL, PASS, ACCESS
        "USR-2"   => 'CALL sp_updatePass(@hash,"x00");', // PASS
        "USR-3"   => 'CALL sp_check_usr_mail(@hash);', //

        /* CALENDAR */
        "CAL-0"   => 'CALL sp_view_calendar(@hash,"x00","x01");', // DT_INI, DT_FIN
        "CAL-1"   => 'CALL sp_set_calendar(@hash,"x00","x01");', // DT_AGD, OBS

        /* MAIL */
        "MAIL-0"  => 'CALL sp_set_mail(@hash,"x00","x01");', // ID_TO, MESSAGE
        "MAIL-1"  => 'CALL sp_view_mail(@hash,x00);', // I_SEND
        "MAIL-2"  => 'CALL sp_all_mail_adress(@hash);', //      
        "MAIL-3"  => 'CALL sp_del_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO
        "MAIL-4"  => 'CALL sp_mark_mail(@hash,"x00",x01,x02);', // DATA, ID_FROM, ID_TO

        /* EMPRESAS */
        "EMP-0"   => 'CALL sp_view_emp(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "EMP-1"   => 'CALL sp_set_emp(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15","x16");', // id,razao_social,fant,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email
        "EMP-2"   => 'CALL sp_del_emp(@access,@hash,x00);', // ID

        /* PRODUTOS */
        "PROD-0"  => 'CALL sp_view_prod(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE
        "PROD-1"  => 'CALL sp_set_prod(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09",x10,"x11","x12","x13","x14");',//ID,ID_EMP,DESCRIÇÃO,ESTOQUE,ESTQ_MIN,UND,NCM,COD_INT,COD_BAR,COD_FORN,CONSUMO,CUSTO,MARKUP,LOCAL,DISPONIVEL 
        "PROD-2"  => 'CALL sp_del_prod(@access,@hash,x00);', // ID
        "PROD-3"  => 'CALL sp_set_reserv_prod(@access,@hash,x00,x01,x02,"x03",x04);', // ID_PROD, ID_PROJ,ID_USER,QTD,PAGO      
        "PROD-4"  => 'CALL sp_inventario(@access,@hash,x00,"x01","x02")', // ID_PROD, QTD, OPERAÇÃO

        /* ADMIN */
        "ADM-0"   => 'CALL sp_set_und(@access,@hash,x00,"x01","x02");', // ID,NOME, SIGLA
        "ADM-1"   => 'CALL sp_view_und(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* SYSTEMA */
        "SYS-0"   => 'CALL sp_set_usr_perm_perf(@access,@hash,x00,"x01");', // ID, NOME
        "SYS-1"   => 'CALL sp_view_usr_perm_perf(@access,@hash,"x00","x01","x02");', // FIELD,SIGNAL, VALUE

        /* CAIXA */
        "CXA-0" => 'CALL sp_view_comandas(@access,@hash,"x00","x01","x02","x03","x04",x05);', // FIELD,SIGNAL, VALUE, DT_INI, DT_FIN, ABERTA
        "CXA-1" => 'CALL sp_view_cliente(@access,@hash,"x00","x01","x02");', // FIELD, SIGNAL, VALUE
        "CXA-2" => 'CALL sp_set_cliente(@access,@hash,"x00","x01","x02","x03","x04","x05");', //  ID,NOME,CPF,CEL.SALDO,OBS
        "CXA-3" => 'CALL sp_set_comanda(@access,@hash,x00,x01,"x02");', //  ID,ID_CLIENTE,OBS
        "CXA-4" => 'CALL sp_set_item_comanda(@access,@hash,x00,x01,x02,"x03","x04");', //ID,ID_COMANDA,ID_PRODUTO,QTD,PAGO
        "CXA-5" => 'CALL sp_view_item_comanda(@access,@hash,x00);', //ID_COMANDA
        "CXA-6" => 'CALL sp_del_item_comanda(@access,@hash,x00,x01);', // ID_ITEM, ID_COMANDA 
        "CXA-7" => 'CALL sp_fecha_comanda(@access,@hash,x00,"x01","x02");', // ID_COMANDA, MODO_PGTO, VALOR

        /* CLIENTE */
        "CLI-0" => 'CALL sp_comanda_cliente("x00");',

        /* FINANCEIRO */
        "FIN-0" => 'CALL sp_set_compra(@access,@hash,x00,x01,"x02","x03");', // ID, ID_PROD,QTD,CUSTO_UNIT
        "FIN-1" => 'CALL sp_view_fluxo_caixa(@access,@hash,"x00","x01");', // DT_INICIO, DT_FINAL
        "FIN-2" => 'CALL sp_set_lancamento(@access,@hash,x00,"x01","x02","x03",x04);',//ID,VALOR,DESCRICAO,MODO,ENTRADA

        /* FUNCIONÁRIO*/
        "FUN-0" => 'CALL sp_view_func(@access,@hash,"x00","x01","x02");', // FIELD, SIGNAL, VALUE',
        "FUN-1" => 'CALL sp_set_func(@access,@hash,x00,"x01","x02","x03","x04","x05","x06","x07","x08","x09","x10","x11","x12","x13","x14","x15","x16",x17,"x18");',// id,nome,nasc,rg,cpf,pis,end,num,cidade,bairro,uf,cep,data_adm,data_dem,cargo,tel,cel,ativo,obs
    );

?>