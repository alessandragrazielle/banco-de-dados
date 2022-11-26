create table Hospede
(cod_hosp int not NULL primary key,
nome varchar(50) not NULL,
dt_nasc date not NULL);

create table Funcionario
(cod_func int not NULL primary key,
nome varchar(50) not NULL,
dt_nasc date not NULL);

create table Categoria
(cod_cat int not NULL primary key,
nome varchar(50) not NULL,
valor_dia float not NULL);

create table Apartamento
(num int not NULL primary key,
cod_cat int not NULL references Categoria (cod_cat),
tamanho int not NULL);

create table Hospedagem
(cod_hospeda int not NULL primary key,
cod_hosp int not NULL references Hospede(cod_hosp),
num int not NULL references Apartamento(num),
cod_func int not NULL references Funcionario(cod_func),
dt_ent date not NULL,
dt_sai date);
 

insert into Hospede values (001,'Alessandra', '2003-05-05');
insert into Hospede values (002,'Kaylanne', '2003-02-27');
insert into Funcionario values (035, 'Joao', '1989-06-30');
insert into Funcionario values (021, 'Maria', '1994-09-01');
insert into Categoria values (11, 'Simples', 400);
insert into Categoria values (12, 'Luxo', 1000);
insert into Apartamento values (101, 11, 10);
insert into Apartamento values (201, 12, 30);
insert into Hospedagem values (1, 001, 201, 021, '2022-10-20', '2022-10-24');
insert into Hospedagem values (2, 002, 101, 035, '2022-11-25');