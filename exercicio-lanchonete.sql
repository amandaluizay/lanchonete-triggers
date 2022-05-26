-- exercicio 1 --> Crie a query que exibe os dados dos pedidos para a cozinha 

select pro.nomeproduto, ped.quantidade, ped.mesa, ped.textoadcional, ped.status 
from pedido ped inner join produto pro
where ped.idproduto = pro.idproduto;

-- exercicio 2 --> Crie a query que exibe as informações no monitor do restaurante para mostrar aos clientes os pedidos. 

select ped.mesa, pro.nomeproduto, ped.textoadcional, ped.quantidade, ped.status 
from pedido ped inner join produto pro
on ped.idproduto = pro.idproduto
where mesa = 10;

-- 4A. Crie um trigger para atualizar a tabela movimento (criada na atividade anterior),
-- de modo que o contador seja incrementado cada vez que o produto seja pedido.

delimiter &&
create trigger atualizarMovimento after insert
on pedido
for each row
begin
	insert into movimento
    values(current_date(), new.idproduto, new.quantidade);
end
&&
delimiter ;


-- 4B. Teste sua trigger fazendo um insert na tabela pedido. values(1,12,100,2) e values(1,12,103,3);

insert into pedido (idpedido, mesa, idproduto, quantidade) values(1,12,100,2);
insert into pedido (idpedido, mesa, idproduto, quantidade) values(1,12,103,3);

select * from pedido;
select * from movimento;

-- 4C. Insira mais um pedido com o mesmo produto e verifique como é cadastrado na tabela movimento

insert into pedido (idpedido, mesa, idproduto, quantidade) values(1,13,103,1);

-- 5. Faça outra trigger onde toda vez que um produto for selecionado,
-- verifique se já existem dados para aquele dia e produto. Se existir atualizar
-- a quantidade dos produtos vendidos no dia, se não incluir. Testar.

DELIMITER $$
CREATE TRIGGER atualizaMovimentoA
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
IF (select count(*) from movimento 
	 where idproduto = NEW.idproduto
       and datamovimento = current_date()) > 0 THEN  -- se achar qualquer valor quer dizer que o produto já está cadastrado no dia corrente
    UPDATE movimento
       SET qtde = qtde + NEW.quantidade
	 where idproduto = NEW.idproduto
       and datamovimento = current_date();
ELSE
	INSERT INTO movimento
	VALUES(current_date(),NEW.idproduto,NEW.quantidade);
END IF;
END $$
DELIMITER ;

-- 6. Criar uma trigger para que toda vez que um produto for excluído da
-- tabela produtos, este mesmo produto seja copiado na tabela exProduto. A
-- tabela exProduto deve ter a mesma estrutura da tabela produto.

CREATE TABLE IF NOT EXISTS `exproduto` (
  `idexproduto` INT NOT NULL,
  `nomeexproduto` VARCHAR(45) NULL,
  `idcategoria` INT NOT NULL,
  PRIMARY KEY (`idexproduto`),
  INDEX `fk_exproduto_categoria_idx` (`idcategoria` ASC),
  CONSTRAINT `fk_exproduto_categoria`
    FOREIGN KEY (`idcategoria`)
    REFERENCES `categoria` (`idcategoria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

delimiter **
create trigger moverProduto 
after delete on produto 
for each row
begin
	insert into exproduto  
    values (old.idproduto, old.nomeproduto, old.idcategoria);
end
**
delimiter ;

drop trigger moverProduto;


delete from produto where idproduto = 110;

select * from exproduto;
select * from produto;



