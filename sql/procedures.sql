 DROP PROCEDURE sp_getHash;
DELIMITER $$
	CREATE PROCEDURE sp_getHash(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SELECT SHA2(CONCAT(Iemail, Isenha), 256) AS HASH;
	END $$
DELIMITER ;

CALL sp_getHash("admin@pesqueirodourado.com.br","123456");


 DROP PROCEDURE sp_allow;
DELIMITER $$
	CREATE PROCEDURE sp_allow(
		IN Iallow varchar(80),
		IN Ihash varchar(64)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SET @quer =CONCAT('SET @allow = (SELECT ',@access,' IN ',Iallow,');');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
	END $$
DELIMITER ;

/* LOGIN */

 DROP PROCEDURE sp_login;
DELIMITER $$
	CREATE PROCEDURE sp_login(
		IN Iemail varchar(80),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @hash = (SELECT SHA2(CONCAT(Iemail, Isenha), 256));
		SELECT *, SUBSTRING_INDEX(email,"@",1) AS nome FROM tb_usuario WHERE hash=@hash;
	END $$
DELIMITER ;

CALL sp_login("admin@pesqueirodourado.com.br", "123456");

/* USER */

 DROP PROCEDURE sp_setUser;
DELIMITER $$
	CREATE PROCEDURE sp_setUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iemail varchar(80),
		IN Isenha varchar(30),
        IN Iaccess int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iemail="")THEN
				DELETE FROM tb_mail WHERE de=Iid OR para=Iid;
				DELETE FROM tb_usuario WHERE id=Iid;
            ELSE			
				IF(Iid=0)THEN
					INSERT INTO tb_usuario (email,hash,access)VALUES(Iemail,SHA2(CONCAT(Iemail, Isenha), 256),Iaccess);            
                ELSE
					IF(Isenha="")THEN
						UPDATE tb_usuario SET email=Iemail, access=Iaccess WHERE id=Iid;
                    ELSE
						UPDATE tb_usuario SET email=Iemail, hash=SHA2(CONCAT(Iemail, Isenha), 256), access=Iaccess WHERE id=Iid;
                    END IF;
                END IF;
            END IF;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_viewUser;
DELIMITER $$
	CREATE PROCEDURE sp_viewUser(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT id,email,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_usuario AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS email, 0 AS id_func, 0 AS access;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_updatePass;
DELIMITER $$
	CREATE PROCEDURE sp_updatePass(	
		IN Ihash varchar(64),
		IN Isenha varchar(30)
    )
	BEGIN    
		SET @call_id = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@call_id > 0)THEN
			UPDATE tb_usuario SET hash = SHA2(CONCAT(email, Isenha), 256) WHERE id=@call_id;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_check_usr_mail;
DELIMITER $$
	CREATE PROCEDURE sp_check_usr_mail(
		IN Ihash varchar(64)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call>0)THEN
			SELECT COUNT(*) AS new_mail FROM tb_mail WHERE id_to = @id_call AND looked=0;
		ELSE
			SELECT 0 AS new_mail ;
        END IF;
	END $$
DELIMITER ;

CALL sp_check_usr_mail("ebf62be8158ce26e56a2a1714a7ad7564efac3f61dd1c604d43c270b8ab5e1b4");

/* PERMISSÂO */

 DROP PROCEDURE sp_set_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_set_usr_perm_perf(	
		IN Iaccess varchar(50),
		IN Ihash varchar(64),
        In Iid int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@access IN(0))THEN
			IF(Iid = 0 AND Inome != "")THEN
				INSERT INTO tb_usr_perm_perfil (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_usr_perm_perfil WHERE id=Iid;
				ELSE
					UPDATE tb_usr_perm_perfil SET nome = Inome WHERE id=Iid;
                END IF;
            END IF;			
			SELECT * FROM tb_usr_perm_perfil;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_usr_perm_perf;
DELIMITER $$
	CREATE PROCEDURE sp_view_usr_perm_perf(	
		IN Iaccess varchar(50),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		SET @access = (SELECT IFNULL(access,-1) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@access IN (0))THEN
			SET @quer = CONCAT('SELECT * FROM tb_usr_perm_perfil WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

/* CALENDAR */

 DROP PROCEDURE sp_view_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_view_calendar(	
		IN Ihash varchar(64),
		IN IdataIni date,
		IN IdataFin date
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT * FROM tb_calendario WHERE id_user=@id_call AND data_agd>=IdataIni AND data_agd<=IdataFin;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_calendar;
DELIMITER $$
	CREATE PROCEDURE sp_set_calendar(	
		IN Ihash varchar(64),
		IN Idata date,
		IN Iobs varchar(255)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			SET @exist = (SELECT COUNT(*) FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata);
			IF(@exist AND Iobs = "")THEN
				DELETE FROM tb_calendario WHERE id_user=@id_call AND data_agd = Idata; 
			ELSE
				INSERT INTO tb_calendario (id_user, data_agd, obs) VALUES(@id_call, Idata, Iobs)
                ON DUPLICATE KEY UPDATE obs=Iobs;
			END IF;
        END IF;
	END $$
DELIMITER ;

/* MAIL */

 DROP PROCEDURE sp_set_mail;
DELIMITER $$
	CREATE PROCEDURE sp_set_mail(	
		IN Ihash varchar(64),
        IN Iid_to int(11),
		IN Imessage varchar(512)
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
        IF(@id_call >0)THEN
			INSERT INTO tb_mail (id_from,id_to,message) VALUES (@id_call,Iid_to,Imessage);
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_mail;
DELIMITER $$
	CREATE PROCEDURE sp_view_mail(	
		IN Ihash varchar(64),
        IN Isend boolean
    )
	BEGIN    
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call > 0)THEN
			IF(Isend)THEN
				SELECT MAIL.*, USR.email AS mail_from
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_from = USR.id AND id_to = @id_call;            
            ELSE
				SELECT MAIL.*, USR.email AS mail_to
					FROM tb_mail AS MAIL 
					INNER JOIN tb_usuario AS USR
					ON MAIL.id_to = USR.id AND id_from = @id_call;            
            END IF;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_mail;
DELIMITER $$
	CREATE PROCEDURE sp_del_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			DELETE FROM tb_mail WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_mark_mail;
DELIMITER $$
	CREATE PROCEDURE sp_mark_mail(	
		IN Ihash varchar(64),
        IN Idata datetime,
        IN Iid_from int(11),
        IN Iid_to int(11)
    )
	BEGIN        
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		IF(@id_call = Iid_to OR @id_call = Iid_from)THEN
			UPDATE tb_mail SET nao_lida=0 WHERE data = Idata AND de = Iid_from AND para = Iid_to;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_all_mail_adress;
DELIMITER $$
	CREATE PROCEDURE sp_all_mail_adress(	
		IN Ihash varchar(64)
    )
	BEGIN
		SET @id_call = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
		SELECT id,email FROM tb_usuario WHERE id != @id_call ORDER BY email ASC;
	END $$
DELIMITER ; 

/* PRODUTO */

 DROP PROCEDURE sp_set_und;
DELIMITER $$
	CREATE PROCEDURE sp_set_und(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_und int(11),
		IN Inome varchar(30),
		IN Isigla varchar(8)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_und = 0)THEN
				INSERT INTO tb_und (nome,sigla) VALUES (Inome,Isigla);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_und WHERE id=Iid_und;
				ELSE
					UPDATE tb_und SET nome=Inome, sigla=Isigla WHERE id=Iid_und;
				END IF;
            END IF;			
			SELECT * FROM tb_und;
        END IF;
	END $$
DELIMITER ; 

 DROP PROCEDURE sp_view_und;
DELIMITER $$
	CREATE PROCEDURE sp_view_und(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_und WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ; 

 DROP PROCEDURE sp_view_prod;
DELIMITER $$
	CREATE PROCEDURE sp_view_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_prod WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ; 

 DROP PROCEDURE sp_set_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_emp int(11),
		IN Idescricao varchar(80),
		IN Iestoque double,
		IN Iestq_min double,
		IN Iund varchar(10),
		IN Incm varchar(8),
		IN Icod_int int(11),
		IN Icod_bar varchar(15),
		IN Icod_forn varchar(20),
		IN Iconsumo BOOLEAN,
        IN Icusto double,
		IN Imarkup double,
        IN Ilocal varchar(20)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_produto (id,id_emp,descricao,estoque,estq_min,und,ncm,cod_int,cod_bar,cod_forn,consumo,custo,markup,local)
				VALUES (Iid,Iid_emp,Idescricao,Iestoque,Iestq_min,Iund,Incm,Icod_int,Icod_bar,Icod_forn,Iconsumo,Icusto,Imarkup,Ilocal)
				ON DUPLICATE KEY UPDATE
				id_emp=Iid_emp,descricao=Idescricao,estoque=Iestoque,estq_min=Iestq_min,und=Iund,ncm=Incm,cod_int=Icod_int,
                cod_bar=Icod_bar,cod_forn=Icod_forn,consumo=Iconsumo,custo=Icusto,markup=Imarkup,local=Ilocal;
        END IF;
	END $$
DELIMITER ;

/* EMPRESA */

 DROP PROCEDURE sp_set_emp;
DELIMITER $$
	CREATE PROCEDURE sp_set_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Irazao_social varchar(80),    
		IN Ifant varchar(40),
		IN Icnpj varchar(14),
		IN Iie varchar(14),
		IN Iim varchar(14),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icomp varchar(50),
		IN Ibairro varchar(60),
		IN Icidade varchar(30),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Icliente BOOLEAN,
		IN Iramo varchar(80),
		IN Itel varchar(15),
		IN Iemail varchar(80)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_empresa (id,razao_social,fantasia,cnpj,ie,im,end,num,comp,bairro,cidade,uf,cep,cliente,ramo,tel,email) 
				VALUES (Iid,Irazao_social,Ifant,Icnpj,Iie,Iim,Iend,Inum,Icomp,Ibairro,Icidade,Iuf,Icep,Icliente,Iramo,Itel,Iemail) 
				ON DUPLICATE KEY UPDATE
				razao_social=Irazao_social,fantasia=Ifant,cnpj=Icnpj,ie=Iie,im=Iim,end=Iend,num=Inum,comp=Icomp,bairro=Ibairro,
                cidade=Icidade,uf=Iuf,cep=Icep,cliente=Icliente,ramo=Iramo,tel=Itel,email=Iemail ;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_emp;
DELIMITER $$
	CREATE PROCEDURE sp_view_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_empresa WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 /* CAIXA */
 DROP PROCEDURE sp_view_comandas;
DELIMITER $$
	CREATE PROCEDURE sp_view_comandas(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50),
        IN Idt_ini date,
        IN Idt_fin date,
        IN Iaberta boolean
    )
BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			
            IF(Iaberta)THEN
				SET @quer =CONCAT('SELECT *
					FROM vw_comanda
					WHERE ',Ifield,' ',Isignal,' ',Ivalue,'
					AND entrada BETWEEN "',Idt_ini,'"
					AND "',Idt_fin,'"
					AND aberta = ',Iaberta,'
					ORDER BY entrada DESC;');
            ELSE
				SET @quer =CONCAT('SELECT *
					FROM vw_comanda
					WHERE ',Ifield,' ',Isignal,' ',Ivalue,'
					AND entrada BETWEEN "',Idt_ini,'"
					AND "',Idt_fin,'"
					ORDER BY entrada DESC;');            
            END IF;
            
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;    

 DROP PROCEDURE sp_view_item_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_view_item_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_comanda varchar(30)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SELECT * FROM vw_item_comanda WHERE id_comanda=Iid_comanda;
        END IF;
	END $$
	DELIMITER ;   

 DROP PROCEDURE sp_view_cliente;
DELIMITER $$
	CREATE PROCEDURE sp_view_cliente(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_cliente WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY nome;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
        END IF;
	END $$
	DELIMITER ;        
    
	DROP PROCEDURE sp_set_cliente;
	DELIMITER $$
	CREATE PROCEDURE sp_set_cliente(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(50),
		IN Icpf varchar(12),
		IN Icel varchar(15),
		IN Isaldo double,
		IN Iobs varchar(255)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id = (SELECT IF(COUNT(id)=0,"DEFAULT",id) FROM tb_cliente WHERE id=Iid);
			SET @cpf = (SELECT COUNT(*) FROM tb_cliente WHERE cpf COLLATE utf8_general_ci = Icpf COLLATE utf8_general_ci);

            IF((@id=0 AND @cpf=0) OR (@id>0 AND @cpf>0 ) )THEN
				INSERT INTO tb_cliente (id,nome,cpf,cel,saldo,obs)
					VALUES (@id,Inome,Icpf,Icel,Isaldo,Iobs)
					ON DUPLICATE KEY UPDATE
					nome=Inome, cpf=Icpf, cel=Icel, saldo=Isaldo, obs=Iobs;
                    
                    IF(@id="DEFAULT")THEN
						SET @id = (SELECT MAX(id) FROM tb_cliente);
                    END IF;
                    
				SELECT "Cliente cadastrado com sucesso!" AS MESSAGE, @id AS id_cliente;
			ELSE
				SELECT "Cliente já cadastrado!, verificar o CPF" AS MESSAGE,0 AS id_cliente;
            END IF;
        END IF;
	END $$
	DELIMITER ;     
    
     DROP PROCEDURE sp_set_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_set_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_cliente INT(11),
		IN Iobs varchar(255)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_comanda (id,id_cliente,obs) 
            VALUES(Iid,Iid_cliente,Iobs)
            ON DUPLICATE KEY UPDATE obs=Iobs;
        END IF;
	END $$
	DELIMITER ;        
    
     DROP PROCEDURE sp_set_item_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_set_item_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_comanda INT(11),
		IN Iid_produto INT(11),
		IN Iqtd double,
		IN Ipago boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @aberta = (SELECT aberta FROM tb_comanda WHERE id=Iid_comanda);
            IF(@aberta)THEN
				SET @id = (SELECT IF(COUNT(id)=0,"DEFAULT",id) FROM tb_item_comanda WHERE id=Iid);
				SET @call_id = (SELECT IFNULL(id,0) FROM tb_usuario WHERE hash COLLATE utf8_general_ci = Ihash COLLATE utf8_general_ci LIMIT 1);
				INSERT INTO tb_item_comanda (id,id_comanda,id_garcom,id_produto,qtd,pago)
					VALUES (@id,Iid_comanda,@call_id,Iid_produto,Iqtd,Ipago)
					ON DUPLICATE KEY UPDATE id_garcom=@call_id, qtd=Iqtd, pago=Ipago;
			END IF;
        END IF;
	END $$
	DELIMITER ;    
    
     DROP PROCEDURE sp_del_item_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_del_item_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_comanda INT(11)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @aberta = (SELECT aberta FROM tb_comanda WHERE id=Iid_comanda);
            IF(@aberta)THEN
				DELETE FROM tb_item_comanda WHERE id=Iid AND id_comanda=Iid_comanda;
				SELECT 1 AS ok;
            ELSE
				SELECT 0 AS ok;
			END IF;
        END IF;
	END $$
	DELIMITER ;
    

	   
     DROP PROCEDURE sp_fecha_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_fecha_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid_comanda INT(11),
        IN Imodo_pgto varchar(30),
        IN Ivalor double
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @aberta = 0;
			SET @id_cliente = 0;
			SET @total = 0;
			SELECT aberta,id_cliente,total INTO @aberta,@id_cliente, @total FROM vw_comanda WHERE id=Iid_comanda;
            IF(@aberta)THEN
				UPDATE tb_comanda SET aberta = 0 WHERE id=Iid_comanda;
				UPDATE tb_cliente SET saldo = saldo + (Ivalor - @total) WHERE id = @id_cliente;
                CALL sp_set_lancamento(Iallow,Ihash,0,Ivalor,CONCAT("Venda: comanda ",Iid_comanda),Imodo_pgto,1);
			END IF;
        END IF;
	END $$
	DELIMITER ;      
    
/* Financeiro */

     DROP PROCEDURE sp_set_lancamento;
DELIMITER $$
	CREATE PROCEDURE sp_set_lancamento(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Ivalor double,
		IN Idescricao varchar(60),
		IN Imodo varchar(30),
		IN Ientrada boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @id = (SELECT IF(COUNT(id)=0,"DEFAULT",id) FROM tb_lancamento WHERE id=Iid);
			INSERT INTO tb_lancamento (id,valor,descricao,modo,entrada)
            VALUES (@id,Ivalor,Idescricao,Imodo,Ientrada)
            ON DUPLICATE KEY UPDATE descricao=Idescricao, modo=Imodo, entrada=Ientrada;
        END IF;
	END $$
	DELIMITER ;    