--	Universidade Federal do Vale do São Francisco (Univasf).
--	Projeto da disciplina de Banco de Dados II: Book Lending System (BLSys).
--	Script: Projeto BD II - Teste do sistema
--	Discente: Elayne Lemos, elayne.l.lemos@gmail.com
--	Docente: Prof. Dr. Mario Godoy.

-- Base de dados
insert into Users values(11255509903,'Elayne R L Lemos','oioioi',11,123456789,null);
insert into Users values(19216804035,'Albert Einstein', '1234321',22,987654321,null);
insert into Users values(05296512374,'Ada Lovelace', '15963ola',33,988776655,null);
insert into Users values(11576512310,'Marie Curie', 'tururuggysp',33,988157355,null);

insert into Genres values('8691', 'poesia em lingua portuguesa');
insert into Genres values('292', 'mitologia');
insert into Genres values('004', 'processamento de dados e ciencia da computacao');
insert into Genres values('5231', 'cosmologia em astronomia');

insert into Authors values(123123123,'Vinicius de Moraes');
insert into Authors values(111222333,'Neil Gaiman');
insert into Authors values(159159159,'Stephen Hawking');
insert into Authors values(444555666,'Allen B. Downey');

insert into Publishers values(123456, 'Companhia de Bolso');
insert into Publishers values(741222, 'Intrinseca');
insert into Publishers values(858585, 'O Reilly');

insert into Books values(9788535914085,'ANTOLOGIA POETICA',null,6,123123123,123456,'8691',2009);
insert into Books values(9788551001288,'MITOLOGIA NORDICA',null,12,111222333,741222,'292',2017);
insert into Books values(9788580576467,'UMA BREVE HISTORIA DO TEMPO',null,3,159159159,741222,'5231',2015);
insert into Books values(9781491939369, 'THINK PYTHON','HOW TO THINK LIKE A COMPUTER SCIENTIST',3,444555666,858585,'004',2015);


-- Lending
begin
	insertUsersBooks(11255509903,9788535914085);
	insertUsersBooks(11255509903,9788551001288);
	insertUsersBooks(05296512374,9788551001288);
	insertUsersBooks(19216804035,9781491939369);
end;