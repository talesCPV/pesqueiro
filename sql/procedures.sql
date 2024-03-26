/* FUNCTIONS */

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
        SET @id_func = (SELECT id_func FROM tb_usuario WHERE hash=@hash);
        IF(@id_func)THEN
			SELECT USR.id, USR.email,USR.hash,USR.access,FNC.nome
            FROM tb_usuario AS USR
            INNER JOIN tb_funcionario AS FNC
            ON USR.id_func = FNC.id;
        ELSE
			SELECT *, SUBSTRING_INDEX(email,"@",1) AS nome FROM tb_usuario WHERE hash=@hash;
        END IF;
	END $$
DELIMITER ;

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
			SET @quer =CONCAT('SELECT id,email,id_func,access, IF(access=0,"ROOT",IFNULL((SELECT nome FROM tb_usr_perm_perfil WHERE USR.access = id),"DESCONHECIDO")) AS perfil FROM tb_usuario AS USR WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
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
			UPDATE tb_mail SET looked=1 WHERE data = Idata AND id_from = Iid_from AND id_to = Iid_to;
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

/* ADMIN */
 DROP PROCEDURE sp_set_setor;
DELIMITER $$
	CREATE PROCEDURE sp_set_setor(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_setor int(11),
		IN Inome varchar(30)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_setor = 0)THEN
				INSERT INTO tb_setores (nome) VALUES (Inome);
            ELSE
				IF(Inome = "")THEN
					DELETE FROM tb_setores WHERE id=Iid_setor;
				ELSE
					UPDATE tb_setores SET nome = Inome WHERE id=Iid_setor;
                END IF;
            END IF;			
			SELECT * FROM tb_setores;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_setor;
DELIMITER $$
	CREATE PROCEDURE sp_view_setor(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM tb_setores WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_cargo;
DELIMITER $$
	CREATE PROCEDURE sp_set_cargo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        In Iid_cargo int(11),
		IN Icargo varchar(30),
        IN Isalario double,
        IN Imensal boolean,
        IN Icbo varchar(8)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			IF(Iid_cargo = 0)THEN
				INSERT INTO tb_cargos (cargo,salario,mensal,cbo) VALUES (Icargo, Isalario, Imensal, Icbo);
            ELSE
				IF(Icargo = "")THEN
					DELETE FROM tb_cargos WHERE id=Iid_cargo;
				ELSE
					UPDATE tb_cargos SET cargo = Icargo, salario=Isalario, mensal=Imensal, cbo=Icbo WHERE id=Iid_cargo;
                END IF;
            END IF;			
			SELECT * FROM tb_cargos;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_cargo;
DELIMITER $$
	CREATE PROCEDURE sp_view_cargo(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer = CONCAT('SELECT * FROM tb_cargos WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS cargo, 0.00 AS salario, 0 AS mensal, NULL as cbo;
        END IF;
	END $$
DELIMITER ;

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

/* FUNCIONÁRIO */

 DROP PROCEDURE sp_set_funcionario;
DELIMITER $$
	CREATE PROCEDURE sp_set_funcionario(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Inome varchar(30),
        IN Inasc date,
		IN Irg varchar(15),
		IN Icpf varchar(15),
		IN Ipis varchar(15),
		IN Iend varchar(60),
		IN Inum varchar(6),
		IN Icidade varchar(30),
		IN Ibairro varchar(40),
		IN Iuf varchar(2),
		IN Icep varchar(10),
		IN Idata_adm datetime,
		IN Idata_dem datetime,
		IN Iid_cargo int(11),
		IN Iid_setor int(11),
		IN Itel varchar(15),
		IN Icel varchar(15),
		IN Iativo boolean,
		IN Iobs varchar(200)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_funcionario (id,nome,nasc,rg,cpf,pis,end,num,cidade,bairro,uf,cep,data_adm,id_cargo,id_setor,tel,cel,obs) 
				VALUES (Iid,Inome,Inasc,Irg,Icpf,Ipis,Iend,Inum,Icidade,Ibairro,Iuf,Icep,Idata_adm,Iid_cargo,Iid_setor,Itel,Icel,Iobs)
				ON DUPLICATE KEY UPDATE
				nome=Inome,nasc=Inasc,rg=Irg,pis=Ipis,end=Iend,num=Inum,cidade=Icidade,bairro=Ibairro,uf=Iuf,cep=Icep,data_adm=Idata_adm,
				data_dem=Idata_dem,id_cargo=Iid_cargo,id_setor=Iid_setor,tel=Itel,cel=Icel,ativo=Iativo,obs=Iobs;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_view_func;
DELIMITER $$
	CREATE PROCEDURE sp_view_func(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Ifield varchar(30),
        IN Isignal varchar(4),
		IN Ivalue varchar(50)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT * FROM vw_func WHERE ',Ifield,' ',Isignal,' ',Ivalue,' ORDER BY ',Ifield,';');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
		ELSE 
			SELECT 0 AS id, "" AS nome;
        END IF;
	END $$
DELIMITER ;

 DROP PROCEDURE sp_del_func;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_func(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_funcionario WHERE id=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_func_ponto;
DELIMITER $$ 
	CREATE PROCEDURE sp_set_func_ponto(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid int(11),
		IN Iid_func int(11),
        IN Ientrada datetime,
        IN Isaida datetime
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_relogio_ponto(id,id_func,entrada,saida) VALUES (Iid,Iid_func,Ientrada,Isaida)
			ON DUPLICATE KEY UPDATE entrada=Ientrada, saida=Isaida;			
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

/* EMPRESAS */

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

 DROP PROCEDURE sp_del_emp;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_emp(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_empresa WHERE id=Iid;
            UPDATE tb_produto SET id_emp=NULL WHERE id_emp=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

/* PRODUTO */

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

 DROP PROCEDURE sp_del_prod;
DELIMITER $$ 
	CREATE PROCEDURE sp_del_prod(	
		IN Iallow varchar(80),
		IN Ihash varchar(64),
		IN Iid int(11)
    )
	BEGIN    
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			DELETE FROM tb_prod_reserva WHERE id_prod = Iid;
			DELETE FROM tb_produto WHERE id=Iid;
            SELECT 1 AS ok;
		ELSE 
			SELECT 0 AS ok;
        END IF;	
	END $$
DELIMITER ;

 DROP PROCEDURE sp_set_reserv_prod;
DELIMITER $$
	CREATE PROCEDURE sp_set_reserv_prod(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iid_prod int(11),
		IN Iid_proj int(11),
		IN Iid_user int(11),
		IN Iqtd double,
		IN Ipago BOOLEAN
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_prod_reserva (id_prod,id_proj,id_user,qtd,pago)
				VALUES (Iid_prod,Iid_proj,Iid_user,Iqtd,Ipago)
				ON DUPLICATE KEY UPDATE
				qtd=Iqtd, pago=Ipago;
			IF(Ipago = 1)THEN
				UPDATE tb_produto SET estoque = estoque-Iqtd WHERE id=Iid_prod;
            END IF;
        END IF;
	END $$
DELIMITER ;


/* RELOGIO DE PONTO */

 DROP PROCEDURE sp_view_relogio_ponto;
DELIMITER $$
	CREATE PROCEDURE sp_view_relogio_ponto(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Iinicio date,
        IN Ifinal date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN							   
			SET @quer =CONCAT('SELECT * FROM vw_relogio_ponto WHERE date BETWEEN "',Iinicio,'" AND "',Ifinal,'";');        
            PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;          
		ELSE
			SELECT 0 AS ok;
        END IF;
	END $$
DELIMITER ;