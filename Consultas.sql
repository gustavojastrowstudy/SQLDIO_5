SET autocommit = 0;

START TRANSACTION;

-- Remover um produto
DELETE FROM Produtos WHERE produto_id = 10;

-- Atualizar o estoque
UPDATE Estoque SET quantidade = quantidade - 5 WHERE produto_id = 10;

-- Se tudo ocorrer bem, commit
COMMIT;

ROLLBACK;




DELIMITER //

CREATE PROCEDURE AtualizarEstoqueEProdutos(IN prod_id INT, IN qtd INT)
BEGIN
    DECLARE exit HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; -- Rola tudo de volta se houver erro
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao atualizar o estoque';
    END;

    START TRANSACTION;
    
    -- Savepoint para uma possível reversão parcial
    SAVEPOINT antes_estoque;

    -- Atualizando a tabela de estoque
    UPDATE Estoque SET quantidade = quantidade - qtd WHERE produto_id = prod_id;

    -- Verificando se o estoque foi atualizado corretamente
    IF ROW_COUNT() = 0 THEN
        ROLLBACK TO antes_estoque; -- Reverte apenas a parte de estoque
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao atualizar estoque';
    END IF;

    -- Atualizando a tabela de produtos
    UPDATE Produtos SET data_atualizacao = NOW() WHERE produto_id = prod_id;

    -- Confirma as alterações
    COMMIT;
END//

DELIMITER ;


-- Backup
mysqldump -u root -p --databases ecommerce > ecommerce_backup.sql

-- Restaurar o Banco de Dados a partir do Backup:
mysql -u root -p ecommerce < ecommerce_backup.sql

-- Backup de vários bancos
mysqldump -u root -p --databases ecommerce financeiro clientes > backup_multidb.sql


--Incluindo procedures
mysqldump -u root -p --routines --events --databases ecommerce > ecommerce_full_backup.sql

