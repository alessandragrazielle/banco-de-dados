-- 1
create table numeros
(cod int not null primary key,
 x int not null,
 y int not null
);

insert into numeros values (1, 20, 35);

-- funcao de soma
create or replace function soma(codigo int)
returns numeric as $$
declare
	resultado numeric;
begin
	if exists (select x, y from numeros where cod = codigo) then
		select x + y into resultado from numeros where cod = codigo;
	else 
		raise exception 'Código não existe!';
	end if; 
	
	return resultado;
end;
$$
language plpgsql;
	
-- drop
drop function soma
drop table numeros
-- usando a funcao
select soma(5);



-- 2
-- lanchonete
-- create tables
create table produto
(id_produto int not null primary key,
nome varchar(100) not null,
preco decimal(10,2) not null);

create table pedido
(id_pedido int not null primary key,
data date not null);

create table item_pedido
(cod int not null primary key,
id_produto int not null references produto(id_produto),
id_pedido int not null references pedido(id_pedido),
quantidade int not null);

-- inserts
insert into produto values 
	(1, 'Hamburguer', 21.50), 
	(2, 'Coca-Cola', 3.50), 
	(3, 'Batata Frita', 12.00);
	
insert into pedido values
	(1, '2023-06-30');
	
insert into item_pedido values
	(1, 1, 1, 2),
	(2, 2, 1, 2),
	(3, 3, 1, 1);

-- funcao para calcular o preco total do pedido
create or replace function precoTotalPedido(id_pedido_requerido int)
returns numeric(10,2) as $$
declare 
	valor_total int;
begin
	if exists (select id_pedido from pedido where id_pedido = id_pedido_requerido) then
		select sum(pr.preco * ip.quantidade) into valor_total from produto pr natural join pedido pe natural join item_pedido ip
															  where pe.id_pedido = id_pedido_requerido;
	else
		raise exception 'Código do pedido não encontrado!';
		
	end if;
	
	return valor_total;
end;
$$
language 'plpgsql';

-- drop
drop function precoTotalPedido;
-- usando a funcao
select precoTotalPedido(1);


-- funcao para atualizar o valor de um produto
create or replace function atualizarPrecoProduto(id_prod int, novoValor numeric(10, 2))
returns void as $$
begin 
	if exists (select id_produto from produto where id_produto = id_prod) then
		update produto set preco = novoValor where id_produto = id_prod;
	else
		raise exception 'Código do produto não encontrado!';
		
	end if;
	
end;
$$
language 'plpgsql';

-- drop
drop function atualizarPrecoProduto
-- usando a funcao
select atualizarPrecoProduto(1, 22.5)
select * from produto