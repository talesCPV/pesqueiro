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
        IN Idt_fin date
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			SET @quer =CONCAT('SELECT COT.*
								FROM tb_comanda AS COT
                                WHERE ',Ifield,' ',Isignal,' ',Ivalue,'
                                AND entrada BETWEEN "',Idt_ini,'"
                                AND "',Idt_fin,'"
                                ORDER BY entrada DESC;');
			PREPARE stmt1 FROM @quer;
			EXECUTE stmt1;
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
				SELECT "Cliente cadastrado com sucesso!" AS MESSAGE;
			ELSE
				SELECT "Cliente já cadastrado!, verificar o CPF" AS MESSAGE;
            END IF;
        END IF;
	END $$
	DELIMITER ;     
    
     DROP PROCEDURE sp_set_comanda;
DELIMITER $$
	CREATE PROCEDURE sp_set_comanda(
		IN Iallow varchar(80),
		IN Ihash varchar(64),
        IN Ientrada datetime,
		IN Iaberta boolean,
		IN Iid_cliente INT(11),
		IN Iobs varchar(300)
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			
        
			INSERT INTO tb_comanda (entrada,aberta,id_cliente,obs) 
            VALUES(Ientrada,Iaberta,Iid_cliente,Iobs)
            ON DUPLICATE KEY UPDATE
            entrada=Ientrada,aberta=Iaberta,id_cliente=Iid_cliente,obs=Iobs;
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
		IN Iregistro datetime,
		IN Iid_garcom INT(11),
		IN Iid_produto INT(11),
		IN Iqtd double,
		IN Ipago boolean
    )
	BEGIN
		CALL sp_allow(Iallow,Ihash);
		IF(@allow)THEN
			INSERT INTO tb_comanda (id,)
        END IF;
	END $$
	DELIMITER ;    