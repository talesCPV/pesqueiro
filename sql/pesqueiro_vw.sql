  DROP VIEW IF EXISTS vw_cardapio;
 CREATE VIEW vw_cardapio AS 
    SELECT 
        id,descricao,und,tipo,
        ROUND(((markup/100 + 1)*custo),2) AS preco
    FROM tb_produto
    WHERE disp = 1
	ORDER BY CASE WHEN tipo = "BEBIDAS" THEN 1
				  WHEN tipo = "COMIDAS" THEN 2
                  WHEN tipo = "PORÇÕES" THEN 3
				  ELSE 4 END,descricao;

SELECT * FROM vw_cardapio ;

 DROP VIEW IF EXISTS vw_prod;
 CREATE VIEW vw_prod AS 
    SELECT 
        PROD.*,
        RES.reserva AS reserva,
        (PROD.estoque - RES.reserva) AS disponivel,
        ROUND(((PROD.markup/100 + 1)*PROD.custo),2) AS preco
    FROM
        tb_produto AS PROD
        JOIN vw_prod_forn AS FORN
        JOIN vw_prod_reserva AS RES
        ON RES.id = PROD.id
		AND FORN.id = PROD.id;

SELECT * FROM vw_prod;        

 DROP VIEW IF EXISTS vw_prod_forn;
 CREATE VIEW vw_prod_forn AS 
    SELECT 
        PROD.id AS id,
        COALESCE(EMP.fantasia, '') AS fornecedor
    FROM
        tb_produto AS PROD
        LEFT JOIN tb_empresa AS EMP
        ON PROD.id_emp = EMP.id;
        
 DROP VIEW IF EXISTS vw_prod_reserva;
 CREATE VIEW vw_prod_reserva AS 
    SELECT 
        PROD.id AS id,
        (PROD.custo * (PROD.markup/100 + 1)) AS preco,
        SUM(COALESCE(RES.qtd, 0)) AS reserva
    FROM
        tb_produto AS PROD
        LEFT JOIN tb_prod_reserva AS RES
        ON RES.id_prod = PROD.id
		AND RES.pago = 0
    GROUP BY PROD.id;        

SELECT * FROM vw_prod_reserva;

/* CAIXA */

 DROP VIEW IF EXISTS vw_item_comanda;
 CREATE VIEW vw_item_comanda AS  
	SELECT ITN.*, PROD.preco, ROUND((ITN.qtd * PROD.preco),2) AS sub_total, PROD.descricao, PROD.und 
    FROM tb_item_comanda AS ITN
    INNER JOIN vw_prod AS PROD
    ON ITN.id_produto = PROD.id;

	SELECT * FROM vw_item_comanda;

 DROP VIEW IF EXISTS vw_comanda_valor;
 CREATE VIEW vw_comanda_valor AS
	SELECT COM.*, IFNULL(SUM(ITN.sub_total),0) AS total 
    FROM tb_comanda AS COM
    LEFT JOIN vw_item_comanda AS ITN
    ON ITN.id_comanda = COM.id
    GROUP BY COM.id;

SELECT * FROM vw_comanda_valor;

 DROP VIEW IF EXISTS vw_cmd_pgto;
 CREATE VIEW vw_cmd_pgto AS  
	SELECT CMD.id AS id_comanda, COALESCE(ROUND(SUM(LNC.valor),2), 0) AS pago FROM tb_comanda AS CMD
	LEFT JOIN tb_lancamento AS LNC
	ON LNC.id_comanda = CMD.id
	GROUP BY CMD.id;

SELECT * FROM vw_cmd_pgto;

 DROP VIEW IF EXISTS vw_comanda;
 CREATE VIEW vw_comanda AS     
	SELECT COM.id,COM.aberta,COM.entrada,DATE_FORMAT(COM.entrada,"%d/%m/%Y") AS data,DATE_FORMAT(COM.entrada,"%H:%i:%S") AS hora,
		COM.obs AS obs_comanda, ROUND(COM.total,2) AS total, ROUND((COM.total - PGTO.pago),2) AS saldo_dev,
		CLI.id AS id_cliente, CLI.nome,CLI.cpf, CLI.cel, CLI.saldo, CLI.obs AS obs_cliente,
        SHA2(COM.id, 256) AS token, PGTO.pago
		FROM vw_comanda_valor AS COM
        INNER JOIN tb_cliente AS CLI
        INNER JOIN vw_cmd_pgto AS PGTO
        ON COM.id_cliente = CLI.id
        AND COM.id =  PGTO.id_comanda
		ORDER BY entrada DESC;
        
SELECT * FROM vw_comanda;        

 DROP VIEW IF EXISTS vw_cardapio;
 CREATE VIEW  vw_cardapio AS
    SELECT 
		id,descricao,und,tipo,
        ROUND((((markup / 100) + 1) * custo),2) AS preco
    FROM
        tb_produto
    WHERE
        disp = 1
    ORDER BY 
		CASE
			WHEN tipo = "BEBIDAS" THEN 1
			WHEN tipo = "COMIDAS" THEN 2
			WHEN tipo = "PORÇÕES" THEN 3
			ELSE 4
		END ;