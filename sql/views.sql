
--  DROP VIEW vw_cardapio;
 CREATE VIEW vw_cardapio AS 
    SELECT 
        descricao,und,tipo,
        ROUND(((markup/100 + 1)*custo),2) AS preco
    FROM tb_produto
    WHERE disp = 1
	ORDER BY tipo,descricao;

SELECT * FROM vw_cardapio ;

-- DROP VIEW vw_prod;
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

-- DROP VIEW vw_prod_forn;
 CREATE VIEW vw_prod_forn AS 
    SELECT 
        PROD.id AS id,
        COALESCE(EMP.fantasia, '') AS fornecedor
    FROM
        tb_produto AS PROD
        LEFT JOIN tb_empresa AS EMP
        ON PROD.id_emp = EMP.id;
        
-- DROP VIEW vw_prod_reserva;
-- CREATE VIEW vw_prod_reserva AS 
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

-- DROP VIEW vw_item_comanda;
-- CREATE VIEW vw_item_comanda AS  
	SELECT ITN.*, PROD.preco, (ITN.qtd * PROD.preco) AS sub_total, PROD.descricao, PROD.und 
    FROM tb_item_comanda AS ITN
    INNER JOIN vw_prod AS PROD
    ON ITN.id_produto = PROD.id;

	SELECT * FROM vw_item_comanda;

 DROP VIEW vw_comanda_valor;
-- CREATE VIEW vw_comanda_valor AS
	SELECT COM.*, IFNULL(SUM(ITN.sub_total),0) AS total 
    FROM tb_comanda AS COM
    LEFT JOIN vw_item_comanda AS ITN
    ON ITN.id_comanda = COM.id
    GROUP BY COM.id;

SELECT * FROM vw_comanda_valor;

 DROP VIEW vw_comanda;
 CREATE VIEW vw_comanda AS     
	SELECT COM.id,COM.aberta,COM.entrada,DATE_FORMAT(COM.entrada,"%d/%m/%Y") AS data,DATE_FORMAT(COM.entrada,"%H:%i:%S") AS hora,COM.obs AS obs_comanda, COM.total,
		CLI.id AS id_cliente, CLI.nome,CLI.cpf, CLI.cel, CLI.saldo, CLI.obs AS obs_cliente,
        SHA2(COM.id, 256) AS hash_
		FROM vw_comanda_valor AS COM
        INNER JOIN tb_cliente AS CLI
        ON COM.id_cliente = CLI.id
		ORDER BY entrada DESC;
        
SELECT * FROM vw_comanda;        