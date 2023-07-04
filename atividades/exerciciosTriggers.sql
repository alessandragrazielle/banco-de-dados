create table funcionarios
(mat int not null primary key,
nome varchar(50) not null,
cod_setor int not null,
salario numeric(10,2) not null);

drop table funcionarios cascade;
select * from funcionarios

insert into funcionarios values
	(45178, 'Paloma', 1, 4500),
	(51265, 'Fabio', 1, 5400),
	(63248, 'Pedro', 2, 6100),
	(84521, 'Renato', 3, 7500),
	(15423, 'Eduarda', 2, 4100);

create table atualizacao_func
(cod serial not null primary key,
mat int not null references funcionarios(mat),
salario numeric(10,2) not null,
data_alteracao date not null);

drop table atualizacao_func cascade

-- criar um trigger que insira na tabela de atualizacao quando algo for mudado na tabela funcionario
create function alteracao_func()
returns trigger as $$
begin
	insert into atualizacao_func (mat, salario, data_alteracao) values (new.mat, new.salario, current_date);
	
	return null;
end;
$$
language 'plpgsql';

create trigger tg_alteracao_func
after
insert or update
on funcionarios
for each row
execute function alteracao_func();

drop trigger tg_alteracao_func on funcionarios
drop function alteracao_func

-- testando 
select * from atualizacao_func

update funcionarios set salario = 7800 where mat = 84521;
insert into funcionarios values (12547, 'Alessandra', 3, 1000)


-- agora, a tabela atualizacao_func só será atualizada se o salario for mudado
create function alteracao_func()
returns trigger as $$
begin
	if new.salario <> old.salario then
		insert into atualizacao_func (mat, salario, data_alteracao) values (new.mat, new.salario, current_date);
	
	end if;
	
	return null;
end;
$$
language 'plpgsql';

create trigger tg_alteracao_func
after
insert or update
on funcionarios
for each row
execute function alteracao_func();

drop trigger tg_alteracao_func on funcionarios
drop function alteracao_func

-- testando
select * from atualizacao_func

update funcionarios set salario = 4700 where mat = 45178;


-- agora, uma outra tabela que contenha o salario antigo e o novo
create table atualizacao_func_completa
(cod serial not null primary key,
mat int not null references funcionarios(mat),
salarioAntigo numeric(10,2) not null,
salarioNovo numeric(10,2) not null,
data_alteracao date not null);

create function alteracao_func()
returns trigger as $$
begin
	if new.salario <> old.salario then
		insert into atualizacao_func_completa (mat, salarioAntigo, salarioNovo, data_alteracao) 
		values (new.mat, old.salario, new.salario, current_date);
	
	end if;
	
	return null;
end;
$$
language 'plpgsql';

create trigger tg_alteracao_func
after
insert or update
on funcionarios
for each row
execute function alteracao_func();

drop trigger tg_alteracao_func on funcionarios
drop function alteracao_func

-- testando
select * from atualizacao_func_completa

update funcionarios set salario = 6500 where mat = 63248;


/* Crie uma tabela aluno com as colunas matrícula e nome. Depois crie um trigger
que não permita o cadastro de alunos cujo nome começa com a letra “a”.*/
create table aluno
(matricula int not null primary key,
nome varchar(50) not null);

create function cadastroAluno()
returns trigger as $$
begin
	if new.nome ilike 'a%' then
		raise exception 'Alunos com nome de letra A não são aceitos';
		
	end if;
	return null;
end;
$$
language 'plpgsql';

create trigger tg_cadastroAluno
after
insert or update
on aluno
for each row
execute function cadastroAluno();

-- drop
drop trigger tg_cadastroAluno on aluno
drop function cadastroAluno
-- testando
select * from aluno
insert into aluno values (243, 'Vanessa');
insert into aluno values (478, 'vAl');
update aluno set nome = 'Alessandra' where matricula = 478


/*Primeiro crie uma tabela chamada Funcionário com os seguintes 
campos: código (int), nome (varchar(30)), salário (int), data_última_atualização(timestamp), 
usuário_que_atualizou(varchar(30)).  Na inserção desta tabela, você deve 
informar apenas o código, nome e salário do funcionário. Agora crie um Trigger
que não permita o nome nulo, a salário nulo e nem negativo. Faça testes que comprovem 
o funcionamento do Trigger. 
Obs: RaiseException, „now‟ e current_user*/
create table colaborador
(cod int not null primary key,
nome varchar(50),
salario numeric(10,2),
data_ultima_atualizacao timestamp,
usuario_que_atualizou varchar(30));

create or replace function verificaColaborador()
returns trigger as $$
begin
	if new.nome is null then
		raise exception 'O nome do colaborador não pode ser nulo!';
	end if;
	
	if new.salario is null or new.salario < 0 then
		raise exception 'O salário não pode ser nulo e deve ser maior que zero!';
	end if;
	
	new.data_ultima_atualizacao := current_timestamp;
	new.usuario_que_atualizou := current_user;
	
	return new; -- retornar o novo registro (ou nova versão do registro) que foi modificado ou inserido na tabela
end;
$$
language 'plpgsql';

create trigger tg_verificaColaborador
after insert or update on colaborador
for each row
execute function verificaColaborador();

-- drop 
drop trigger tg_verificaColaborador on colaborador
drop function verificaColaborador
drop table colaborador cascade

-- testando
select * from colaborador
insert into colaborador (cod, nome, salario) values (174, 'Gabriela', 7900)
insert into colaborador (cod, nome, salario) values (658, 'Antonio', null)


/*Agora crie uma tabela chamada Empregado com os atributos nome e salário. 
Crie também outra tabela chamada Empregado_auditoria com os atributos: operação (char(1)), 
usuário (varchar), data (timestamp), nome (varchar), salário (integer). 
Agora crie um trigger que registre na tabela Empregado_auditoria a modificação 
que foi feita na tabela empregado (E,A,I), quem fez a modificação, a data da 
modificação, o nome do empregado que foi alterado e o salário atual dele.
Obs: variável especial TG_OP*/

create table empregado
(nome varchar(50) not null,
salario numeric(10,2) not null);

create table empregado_auditoria
(operacao char(1) not null,
usuario varchar(50),
data timestamp,
nome varchar(50),
salario numeric(10,2));

create or replace function auditoria()
returns trigger as $$
begin
	if (tg_op = 'INSERT') then 
		insert into empregado_auditoria (operacao, usuario, data, nome, salario) 
		values ('I', current_user, current_timestamp, new.nome, new.salario);
	end if;
	
	if (tg_op = 'DELETE') then
		insert into empregado_auditoria (operacao, usuario, data, nome, salario) 
		values ('D', current_user, current_timestamp, old.nome, old.salario);
	end if;
	
	if (tg_op = 'UPDATE') then
		insert into empregado_auditoria (operacao, usuario, data, nome, salario) 
		values ('U', current_user, current_timestamp, new.nome, new.salario);
	end if;
	
	return new;
end;
$$
language 'plpgsql';

create trigger tg_auditoria
after insert or delete or update on empregado
for each row
execute function auditoria();

-- drop 
drop trigger tg_auditoria on empregado
drop function auditoria
-- testando
select * from empregado
select * from empregado_auditoria
insert into empregado values ('Paulo Renato', 5600)
insert into empregado values ('Robson Gomes', 2900)
insert into empregado values ('Rita da Silva', 4800)
insert into empregado values ('Camila Loures', 4800)
update empregado set salario = 5000 where nome ilike 'Camila Loures'
delete from empregado where nome = 'Robson Gomes'


/*Crie a tabela Empregado2 com os atributos código (serial e chave primária), 
nome (varchar) e salário (integer). Crie também a tabela Empregado2_audit 
com os seguintes atributos: usuário (varchar), data (timestamp), id (integer),
coluna (text), valor_antigo(text), valor_novo(text). Agora crie um trigger que 
não permita a alteração da chave primária e insira registros na tabela Empregado2_audit
para refletir as alterações realizadas na tabela Empregado2.*/
create table empregado2
(cod serial primary key,
nome varchar(50),
salario int);

create table empregado2_audit
(usuario varchar(50),
data timestamp,
id int,
coluna text,
valor_antigo text,
valor_novo text);

create or replace function empregado_auditoria()
returns trigger as $$
begin
	if (tg_op = 'UPDATE') then
		if new.cod <> old.cod then -- se for tentar fazer alteracao no cod
			raise exception 'O código não pode ser alterado!';
		end if;
		
		if new.nome <> old.nome then -- se a alteracao for feita em nome
			insert into empregado2_audit (usuario, data, id, coluna, valor_antigo, valor_novo) 
			values (current_user, current_timestamp, new.cod, 'nome', old.nome, new.nome);
		end if;
		
		if new.salario <> old.salario then -- se a alteracao for feita em salario
			insert into empregado2_audit (usuario, data, id, coluna, valor_antigo, valor_novo) 
			values (current_user, current_timestamp, new.cod, 'salario', old.salario, new.salario);
		end if;
	end if;
	
	return new;
end;
$$
language 'plpgsql';
	
create trigger tg_empregado_auditoria
after insert or update on empregado2
for each row
execute function empregado_auditoria();

-- drop 
drop trigger tg_empregado_auditoria on empregado2
drop function empregado_auditoria
-- testando
select * from empregado2
select * from empregado2_audit
insert into empregado2 values (1, 'Monica', 2500)
insert into empregado2 values (2, 'Monica', 2500)
update empregado2 set nome = 'Piedade' where cod = 2
update empregado2 set salario = 2900 where cod = 2
update empregado2 set cod = 5 where cod = 2