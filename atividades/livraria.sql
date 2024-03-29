-- cliente
create table cliente
(cod_cli serial not null primary key,
nome_cli varchar(150) not null,
endereco_cli varchar (150));

insert into cliente values
	(default, 'Roberto', 'Vale Quem Tem'),
	(default, 'Maria Clara', 'Satelite'),
	(default, 'Ana Vanessa', 'Cidade Leste');

select * from cliente;

-- titulo
create table titulo
(cod_titulo serial not null primary key,
nome_titulo varchar(120));

insert into titulo values
	(default, 'Não confie em ninguém'),
	(default, 'E não sobrou nenhum'),
	(default, 'Os mentirosos')

select * from titulo

-- livro
create table livro
(cod_livro serial not null primary key,
cod_titulo int not null references titulo(cod_titulo),
quant_estoque int,
valor_unitario numeric);

insert into livro values
	(default, 1, 10, 80),
	(default, 2, 5, 50),
	(default, 3, 21, 39);

select * from livro

-- pedido
create table pedido
(cod_pedido int primary key, 
cod_cli int, 
data_pedido date,
valor_total_pedido numeric,
quant_itens_pedidos int);

insert into pedido values
	(1, 1, current_date, 400, 5),
	(2, 2, current_date, 100, 2),
	(3 , 3, current_date, 78, 2)

-- item pedido
create table item_pedido
(cod_livro int,
cod_pedido int,
quantidade_item int,
valor_total_item numeric,
constraint pri primary key(cod_livro, cod_pedido)
);

insert into item_pedido values
	(1, 1, 5, 400),
	(2, 2, 2, 100),
	(3, 3, 2, 78);
	
	
/*Crie uma função que realiza o pedido de um único livro que possui estoque suficiente. 
O ato de realizar pedido consiste em inserir registros nas tabelas Pedido e Item_pedido, 
além de decrementar a quantidade em estoque. Essa funcão deve receber apenas os seguintes
parâmetros: 
Código do pedido, código do livro, nome do CLIENTE (imagine que não 
existam dois CLIENTES com o mesmo nome) e quantidade vendida.*/
create or replace function fazerPedido(cod_pedido int, cod_li int, nome varchar(150), quant_vendida int)
returns void as $$ 
declare 
	cod_cliente int;
	valor_unidade int;
begin
	select cod_cli into cod_cliente from cliente where nome_cli ilike nome;
	select valor_unitario into valor_unidade from livro where cod_livro = cod_li;
	
	insert into pedido values(cod_pedido, cod_cliente, current_date, valor_unidade*quant_vendida, quant_vendida);
	insert into item_pedido values(cod_li, cod_pedido, quant_vendida, quant_vendida*valor_unidade);
	
	update livro set quant_estoque = quant_estoque - quant_vendida where cod_livro = cod_li;
end;
$$
language 'plpgsql';

-- usando a funcao
select fazerPedido(5, 2, 'Ana Vanessa', 4);
select * from livro
select * from pedido natural join item_pedido


/*Crie uma função que realiza o pedido como deve ser. Inserções nas tabelas PEdido e 
Item_pedido, além
da atualização da quantidade em estoque. 
No primeiro produto, deve haver inserções nas duas tabelas.
A partir do segundo, apenas na tebela Item_pedido. 
Não esqueça de decrementar a quantidade em estoque, 
de atualizar o valor total do pedido e a quantidade de itens da tabela pedido.
Os parâmetros passados para a função são os mesmos da questão anterior.*/
create or replace function realizarPedido(cod_ped int, cod_li int, nome varchar(150), quant_vend int)
returns void as $$ 
declare 
	cod_cliente int;
	valor_uni int;
begin
	select cod_cli into cod_cliente from cliente where nome_cli ilike nome;
	select valor_unitario into valor_uni from livro where cod_livro = cod_li;
	
	if not exists (select cod_pedido from pedido where cod_pedido = cod_ped) then
		insert into pedido values(cod_ped, cod_cliente, current_date, valor_uni*quant_vend, quant_vend);
		insert into item_pedido values(cod_li, cod_ped, quant_vend, quant_vend*valor_uni);
	
		update livro set quant_estoque = quant_estoque - quant_vend where cod_livro = cod_li;
		
	else
		insert into item_pedido values(cod_li, cod_ped, quant_vend, quant_vend*valor_uni);
		
		update livro set quant_estoque = quant_estoque - quant_vend where cod_livro = cod_li;
		update pedido set valor_total_pedido = valor_total_pedido + quant_vend*valor_uni where cod_pedido = cod_ped;
		update pedido set quant_itens_pedidos = quant_itens_pedidos + quant_vend where cod_pedido = cod_ped;
		
	end if;
end;
$$
language 'plpgsql';

-- drop
drop function realizarPedido
-- testando a funcao
select * from pedido
select * from livro
select realizarPedido(4, 2, 'Ana Vanessa', 3)