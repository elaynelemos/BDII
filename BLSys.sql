--	Universidade Federal do Vale do São Francisco (Univasf).
--	Projeto da disciplina de Banco de Dados II: Book Lending System (BLSys).
--	Script: Projeto BD II - BLSys
--	Discente: Elayne Lemos, elayne.l.lemos@gmail.com
--	Docente: Prof. Dr. Mario Godoy.

create table Users(  
	CPF number(11,0) primary key,  
	uName varchar(255) not null,  
	uPassword varchar(255) not null,  
	ddd number(2,0) not null,  
	uNumber number(9,0) not null,  
	blockedUntil date null  
);

create table Authors(  
	AUTHORID number(9,0) primary key,  
	aName varchar(255) not null  
);

create table Publishers(  
	PUBLISHERID number(6,0) primary key,  
	pName varchar(255) not null  
);

create table Genres( 
	SubjectCDD varchar(4) primary key, 
	gName varchar(255) not null 
);

create table Books(  
	ISBN number(13,0) primary key,  
	title varchar(255) not null,  
	subtitle varchar(255) null,  
	bYear number(4,0) not null,  
	qtd number(4,0) not null, 
	AUTHORID number(9,0) not null,  
	PUBLISHERID number(6,0) not null,  
	SubjectCDD varchar(4) not null,  
	constraint boo_aut_fk foreign key(AUTHORID)  
	references Authors(AUTHORID) on delete cascade,  
	constraint boo_pub_fk foreign key(PUBLISHERID)  
	references Publishers(PUBLISHERID) on delete cascade,  
	constraint boo_gen_fk foreign key(SubjectCDD)  
	references Genres(SubjectCDD) on delete cascade,  
	check(qtd>=1)   
);

create table UsersBooks(  
	CPF number(11,0) not null,  
	ISBN number(13,0) not null,  
	dtLending date not null,  
	dtDevolutionPrevision date not null,  
	dtDevolution date null,  
	constraint usbo_usr_fk foreign key(CPF)  
	references Users(CPF) on delete cascade,  
	constraint usbo_boo_fk foreign key(ISBN)  
	references Books(ISBN) on delete cascade,  
	constraint usbo_pk primary key(CPF, ISBN, dtLending)  
);

-- procedure: insertUsersBooks
create or replace procedure insertUsersBooks(
    varCPF in UsersBooks.CPF%type,
    varISBN in UsersBooks.ISBN%type
)
as
    varBlocked Users.blockedUntil%type;
    varBook number(1,0);
    varLendedBooks number(4,0);
    blockedUserException exception;
    lendingLimitException exception;
    bookLendedException exception;
begin
    select blockedUntil into varBlocked from Users where CPF=varCPF;
    select count(ISBN) into varLendedBooks from UsersBooks where CPF=varCPF and dtDevolution is null;
    select count(ISBN) into varBook from UsersBooks where CPF=varCPF and ISBN=varISBN and dtDevolution is null;
    if varBlocked>=sysdate then
        raise blockedUserException;
    end if;
    if varLendedBooks > 2 then
		raise lendingLimitException;
    end if;
    if varBook > 0 then
		raise bookLendedException;
    end if;
    insert into UsersBooks values(varCPF, varISBN, sysdate, sysdate + 7, null);
exception 
    when blockedUserException then 
        dbms_output.put_line(concat('Action blocked! This user is blocked until: ', to_char(varBlocked, 'dd/mm/yyyy')));
    when lendingLimitException then 
        dbms_output.put_line('Action blocked! This user already achieved the lending limit.');
    when bookLendedException then
        dbms_output.put_line('Action blocked! This user already has this book.');
end insertUsersBooks;


-- procedure: updateDevolution
create or replace procedure updateDevolution(
    varCPF in UsersBooks.CPF%type,
    varISBN in UsersBooks.ISBN%type
)
as
    varDevolution UsersBooks.dtDevolution%type;
    alreadyReturnedException exception;
begin
    select dtDevolution into varDevolution from UsersBooks where CPF=varCPF and ISBN=varISBN;
    if to_char(varDevolution) is not null then
        raise alreadyReturnedException;
    end if;
    update UsersBooks
    set dtDevolution=sysdate
    where CPF=varCPF and ISBN=varISBN and dtDevolution is null;
    update Books
    set qtd = qtd + 1
    where ISBN=varISBN;
exception
    when alreadyReturnedException then
        dbms_output.put_line('Action blocked! Book already returned.');
end updateDevolution;


-- trigger: lendedBook
create or replace trigger lendedBook
after insert on UsersBooks
declare
	varISBN UsersBooks.ISBN%type;
begin
	select ISBN into varISBN from UsersBooks where rowid=(select max(rowid) from UsersBooks);
	update Books
	set qtd = qtd - 1
	where Books.ISBN = varISBN;
end;


-- trigger: blockingUser
create or replace trigger blockingUser
after update of dtDevolution on UsersBooks
declare
	varDevolutionPrevision date;
	varBlocked date;
	varCPF UsersBooks.CPF%type;
begin
	select dtDevolutionPrevision into varDevolutionPrevision from UsersBooks where dtDevolution=(select max(dtDevolution) from UsersBooks);
	select CPF into varCPF from UsersBooks where dtDevolution=(select max(dtDevolution) from UsersBooks);
	select blockedUntil into varBlocked from Users where CPF=varCPF;
	if sysdate - varDevolutionPrevision > 0 then
	    if to_char(varBlocked) is not null and sysdate - varBlocked <= 0 then
    	    update Users
    		set blockedUntil = varBlocked + (sysdate - varDevolutionPrevision)
    		where Users.CPF = varCPF;
		else
    		update Users
    		set blockedUntil = sysdate + (sysdate - varDevolutionPrevision)
    		where Users.CPF = varCPF;
    	end if;
    	select blockedUntil into varBlocked from Users where CPF=varCPF;
    	dbms_output.put_line(concat('This user is blocked until: ',to_char(varBlocked, 'dd/mm/yyyy')));
	end if;
end;
