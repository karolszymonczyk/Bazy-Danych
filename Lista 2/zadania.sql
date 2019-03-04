#ROUND((RAND() * (max-min))+min)

#1-------------------------------------------------------------------------------------------------------
create database `Laboratorium-Filmoteka`;
create user '243434'@'localhost' identified by 'karol434';
grant select, insert, update on  `laboratorium-filmoteka`. * to '243434'@'localhost';

show grants for '243434'@'localhost';

#2
/*
create table aktorzy(
	aktor_id int not null auto_increment,
    imie char(20) default '' not null,
    nazwisko char(30) default '' not null,
    primary key(aktor_id)
);

create table filmy(
	film_id int not null auto_increment,
    tytul char(30) default '' not null,
    gatunek char(20) default '' not null,
    czas_trwania double(2,2) default '0.00' not null,
    kategoria_wiekowa char(10) default '' not null,
    primary key(film_id)
);

create table zagrali(
	aktor_id int not null,
    film_id int not null
);

eksport import

in sakila
create table filmy(
	film_id int not null auto_increment,
    tytul char(30) default '' not null,
    gatunek char(20) default '' not null,
    czas_trwania int default '0.00' not null,
    kategoria_wiekowa char(10) default '' not null,
    primary key(film_id)
);

insert into filmy select * from v1;
*/

#2-------------------------------------------------------------------------------------------------------
create table aktorzy_pl(
	aktor_id int not null,
    imie char(20) default '' not null,
    nazwisko char(30) default '' not null
);

create view v2 as select actor_id, first_name, last_name from actor where first_name not like '%x%' and first_name not like '%v%' and first_name not like '%q%' and last_name not like '%x%' and last_name not like '%v%' and last_name not like '%q%';

insert into aktorzy_pl select * from v2;

drop view v2; 

alter table `aktorzy_pl` add `id` int not null auto_increment primary key;


create table filmy_pl(
	film_id int not null,
    tytul char(30) default '' not null,
    gatunek char(20) default '' not null,
    czas_trwania double(10,2) default '0.00' not null,
    kategoria_wiekowa char(10) default '' not null
);

create view v2 as select f.film_id, f.title, c.name, f.length, f.rating from film f join film_category fc on f.film_id=fc.film_id join category c on fc.category_id=c.category_id where f.title not like '%x%' and f.title not like '%v%' and f.title not like '%q%'; 

insert into filmy_pl select * from v2;

drop view v2; 

alter table `filmy_pl` add `id` int not null auto_increment primary key;

select * from filmy_pl;


create table zagrali_pl(
	aktor_id int not null,
    film_id int not null
);

create view v1 as select a.id as aktor_id, f.id as film_id from aktorzy_pl a join film_actor fa on a.id=fa.actor_id join filmy_pl f on f.id=fa.film_id order by aktor_id;

insert into zagrali_pl select * from v1;

drop view v1; 

select * from zagrali_pl;


#3-------------------------------------------------------------------------------------------------------
alter table aktorzy add column liczba_filmow int not null;

set sql_mode = '';
set sql_safe_updates = 0;

create view v1 as select z.aktor_id, count(*) as liczba_filmow from zagrali z group by aktor_id having liczba_filmow;

update aktorzy a join v1 on a.aktor_id=v1.aktor_id set a.liczba_filmow=(v1.liczba_filmow);

#update aktorzy set liczba_filmow=(select count(*) from zagrali where aktorzy.id=zagrali.aktor);

update aktorzy a join (select z.aktor_id, count(*) as liczba_filmow from zagrali z group by aktor_id) s on a.aktor_id=s.aktor_id set a.liczba_filmow=(s.liczba_filmow);

drop view v1;


#DODANIE LISTY FILMOW

alter table aktorzy add column filmy char(100) not null;

#SELECT a.aktor_id, GROUP_CONCAT(f.tytul SEPARATOR ', ') as filmy FROM filmy f join zagrali z on f.film_id=z.film_id join aktorzy a on a.aktor_id=z.aktor_id GROUP BY a.liczba_filmow having a.liczba_filmow < 4;

update aktorzy a join (SELECT a.aktor_id, GROUP_CONCAT(f.tytul SEPARATOR ', ') as filmy FROM filmy f join zagrali z on f.film_id=z.film_id join aktorzy a on a.aktor_id=z.aktor_id GROUP BY a.liczba_filmow having a.liczba_filmow < 4) fil on a.aktor_id=fil.aktor_id set a.filmy=fil.filmy where a.liczba_filmow < 4;


#4-------------------------------------------------------------------------------------------------------
CREATE TABLE `laboratorium-filmoteka`.`agenci` (
  `licencja` VARCHAR(30) NOT NULL,
  `nazwa` VARCHAR(90) NOT NULL,
  `wiek` INT NOT NULL,
   check (wiek > 21),
  `typ` ENUM('osoba indywidualna', 'agencja', 'inny') NOT NULL,
  PRIMARY KEY (`licencja`));
  
  CREATE TABLE `laboratorium-filmoteka`.`kontrakty` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `agent` VARCHAR(30) NOT NULL,
  `aktor` INT NOT NULL,
  `poczatek` DATETIME NOT NULL,
  `koniec` DATETIME NOT NULL,
  check (koniec>date_add(poczatek, interval 1 day)),
  `gaza` INT NOT NULL,
  check (gaza>0),
  PRIMARY KEY (`id`),
  INDEX `agent_idx` (`agent` ASC) VISIBLE,
  INDEX `aktor_idx` (`aktor` ASC) VISIBLE,
  CONSTRAINT `agent`
    FOREIGN KEY (`agent`)
    REFERENCES `laboratorium-filmoteka`.`agenci` (`licencja`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `aktor`
    FOREIGN KEY (`aktor`)
    REFERENCES `laboratorium-filmoteka`.`aktorzy` (`aktor_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

#5-------------------------------------------------------------------------------------------------------
#select a1.imie, round((RAND() * (178-1))+1) from aktorzy a1 where a1.aktor_id=round((RAND() * (178-1))+1) limit 1; CZEMU NIE DZIALA?

delimiter $$
create procedure createAgents ()
begin
	declare i int default 0;
	declare lic char(20);
    declare naz char(20);
    declare age int;
    declare ty char(20);
    myloop: loop
		set lic=conv(rand() * 999999, 10, 20);
		set naz=(select concat(a1.imie, " ", a2.nazwisko) from aktorzy a1, aktorzy a2 order by rand() limit 1);
		set age=round((rand() * (45-22))+22);
		set ty=(select elt(round(rand()*(3-1)+1),'osoba indywidualna','agencja','inny')); 
		insert into agenci (licencja, nazwa, wiek, typ) values (lic, naz, age, ty);
        set i = i + 1;
		if i = 1000 then
			leave myloop;
		end if;
    end loop myloop;
end$$
delimiter ;

call createAgents();

#select * from agenci;

drop procedure createAgents;

#select * from kontrakty;

delimiter $$
create procedure fillKontrakty ()
begin
	declare i int default 0;
    declare n int default 0;
    declare ag char(20);
    declare ak int;
    declare po date;
    declare ko date;
    declare ga int;
    set n=(select count(*) from aktorzy);
    while i<n do
		set ag=(select licencja from agenci order by rand() limit 1);
        set ak=(select aktor_id from aktorzy where aktor_id=i+1);
        set po=(select now() - interval floor(rand() * 100) day);
        set ko=(select now() + interval floor(rand() * 100) day);
        set ga=round(rand()*(3200-2100)+2100);
		insert into kontrakty (id, agent, aktor, poczatek, koniec, gaza) values (i+1, ag, ak, po, ko, ga);
        set i = i + 1;
	end while;
end$$
delimiter ;

call fillKontrakty();

#select * from kontrakty;

drop procedure fillkontrakty;

#6-------------------------------------------------------------------------------------------------------
insert into agenci (licencja, nazwa, wiek, typ) values ("AAAA", 'Test', 20, 'agencja');

delimiter $$  
create trigger sprwadzWiekInsert before insert on agenci for each row  
begin 
	declare msg varchar(20);
    if new.wiek < 21 then
		set msg = ('Niepoprawny wiek');
        signal sqlstate '45000' set message_text = msg;
    end if;  
end; $$  

delimiter $$  

delimiter $$  
create trigger sprwadzWiekUpdate before update on agenci for each row  
begin 
	declare msg varchar(20);
    if new.wiek < 21 then
		set msg = ('Niepoprawny wiek');
        signal sqlstate '45000' set message_text = msg;
    end if;  
end; $$  

delimiter $$  

insert into kontrakty (id, agent, aktor, poczatek, koniec, gaza) values (180, "56A6G", 178, "2018-11-11", "2018-11-12", 20);

delimiter $$  
create trigger sprwadzKontraktInsert before insert on kontrakty for each row  
begin 
	declare msg varchar(50);
    if new.gaza < 0 or new.koniec <= date_add(new.poczatek, interval 1 day) then
		set msg = ('Niepoprawna data zakonczenia lub gaza');
        signal sqlstate '45000' set message_text = msg;
    end if;  
end; $$  

delimiter $$  

delimiter $$  
create trigger sprwadzKontraktUpdate before update on kontrakty for each row  
begin 
	declare msg varchar(30);
    if new.gaza < 0 or new.koniec <= date_add(new.poczatek, interval 1 day) then
		set msg = ('Niepoprawna data zakonczenia lub gaza');
        signal sqlstate '45000' set message_text = msg;
    end if;  
end; $$  

delimiter $$ 

#drop trigger sprwadzKontraktInsert;
#drop trigger sprwadzKontraktUpdate; 


delimiter $$
create procedure Historia ()
begin
	declare i int;
    declare n int;
    declare ag char(20);
    declare ak int;
    declare po date;
    declare ko date;
    declare ga int;
    set i = (select count(*) from kontrakty);
    set n = i + 30;
    myloop: loop
		set ag=(select licencja from agenci order by rand() limit 1);
        set ak=(select aktor_id from aktorzy order by rand() limit 1);
        set po=(select poczatek - interval floor(rand() * (100-20)+20) day from kontrakty where aktor=ak);
        set ko=(select poczatek - interval floor(rand() * (19-2)+2) day from kontrakty where aktor=ak);
        set ga=round(rand()*(3200-2100)+2100);
		insert into kontrakty (id, agent, aktor, poczatek, koniec, gaza) values (i+1, ag, ak, po, ko, ga);
		if i = n then
			leave myloop;
		end if;
    end loop myloop;
end$$
delimiter ;

call Historia();

select * from kontrakty;

drop procedure Historia;

#7-------------------------------------------------------------------------------------------------------
/delimiter $$
create procedure Info(imie varchar(20), nazwisko varchar(20), out ag varchar(20), out dni int)
begin
    set ag=(select agent from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.imie=imie and a.nazwisko=nazwisko and k.koniec > now());
    #set dni=(select k.koniec-now() from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.imie=imie and a.nazwisko=nazwisko and k.koniec > now());
    set dni=(select datediff(k.koniec, now()) from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.imie=imie and a.nazwisko=nazwisko and k.koniec > now());
end; $$
delimiter ;

call Info('Penelope', 'Guiness', @ag, @dni);
select @ag as agent, @dni as dniDoKonca;

call Info('Camerons', 'Zellweger', @ag, @dni);
select @ag as agent, @dni as dniDoKonca;


delimiter $$
create function InfoF (imie varchar(20), nazwisko varchar(20))
returns varchar(40) deterministic
begin
set @f=(select agent from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.imie=imie and a.nazwisko=nazwisko and k.koniec > now());
set @l=(select datediff(k.koniec, now()) from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.imie=imie and a.nazwisko=nazwisko and k.koniec > now());
return concat(@f, '  ', @l);
end $$
delimiter ;

select infoF('Penelope', 'Guiness') as agent_i_data_wygasniecia;

#8-------------------------------------------------------------------------------------------------------
delimiter $$
create procedure WartoscKontraktu(nrlic varchar(20), out srWart int)
begin
declare msg varchar(50);
	if nrlic not in (select licencja from agenci) then
		set msg = ('Brak licencji');
        signal sqlstate '45000' set message_text = msg;
    else
	set srWart=(select avg(gaza) from kontrakty where agent=nrlic);
    end if;
end; $$
delimiter ;

call WartoscKontraktu('4EE3x', @srWart);
select @srWart as srednia_wartosc;

call WartoscKontraktu('4EE3H', @srWart);
select @srWart as srednia_wartosc;

#9-------------------------------------------------------------------------------------------------------
set @q='select count(*) as ilosc_klientow from kontrakty group by agent having agent=?';
prepare statement from @q;

set @a='103HB';
execute statement using @a;

deallocate prepare statement;

#10 !-------------------------------------------------------------------------------------------------------
delimiter $$
create procedure InfoAgent(out na varchar(40), out lic varchar(20))
begin
    set na=(select nazwa from kontrakty k join agenci a on k.agent=a.licencja group by licencja order by sum(datediff(koniec, poczatek)) limit 1);
    set lic=(select licencja from kontrakty k join agenci a on k.agent=a.licencja group by licencja order by sum(datediff(koniec, poczatek)) limit 1);
end; $$
delimiter ;

call InfoAgent(@na, @lic);
select @na as nazwa, @lic as licencja;

drop procedure InfoAgent;

#11-------------------------------------------------------------------------------------------------------
delimiter $$  
create trigger uaktualinijAktorzyI after insert on zagrali for each row  
begin 
    update aktorzy set liczba_filmow=liczba_filmow + 1 where aktor_id=new.aktor_id;
    update aktorzy a join (SELECT a.aktor_id, GROUP_CONCAT(f.tytul SEPARATOR ', ') as filmy FROM filmy f join zagrali z on f.film_id=z.film_id join aktorzy a on a.aktor_id=z.aktor_id GROUP BY a.liczba_filmow having a.liczba_filmow < 4) fil on a.aktor_id=fil.aktor_id set a.filmy=fil.filmy where a.liczba_filmow < 4;
end; $$  

delimiter ;  

delimiter $$  
create trigger uaktualinijAktorzyD after delete on zagrali for each row  
begin 
    update aktorzy set liczba_filmow=liczba_filmow - 1 where aktor_id=old.aktor_id;
    update aktorzy a join (SELECT a.aktor_id, GROUP_CONCAT(f.tytul SEPARATOR ', ') as filmy FROM filmy f join zagrali z on f.film_id=z.film_id join aktorzy a on a.aktor_id=z.aktor_id GROUP BY a.liczba_filmow having a.liczba_filmow < 4) fil on a.aktor_id=fil.aktor_id set a.filmy=fil.filmy where a.liczba_filmow < 4;
end; $$  

delimiter ;

delimiter $$  
create trigger uaktualinijAktorzyU after update on zagrali for each row  
begin 
	update aktorzy a join (select z.aktor_id, count(*) as liczba_filmow from zagrali z group by aktor_id) s on a.aktor_id=s.aktor_id set a.liczba_filmow=(s.liczba_filmow);
	update aktorzy a join (SELECT a.aktor_id, GROUP_CONCAT(f.tytul SEPARATOR ', ') as filmy FROM filmy f join zagrali z on f.film_id=z.film_id join aktorzy a on a.aktor_id=z.aktor_id GROUP BY a.liczba_filmow having a.liczba_filmow < 4) fil on a.aktor_id=fil.aktor_id set a.filmy=fil.filmy where a.liczba_filmow < 4;
end; $$  

delimiter ;

#12-------------------------------------------------------------------------------------------------------
delimiter $$

create trigger dodajKontrakt before insert on kontrakty for each row
begin
	declare msg varchar(50);

	if (select not exists (select * from agenci where licencja = new.agent)) then
		
        insert into agenci(licenja, nazwa, wiek, typ) values (new.agent, null, null, null);
        
    end if;
    
    if (select exists (select * from aktorzy a join kontrakty k on a.aktor_id=k.aktor where a.aktor_id = new.aktor and now() > k.poczatek and now()< k.koniec)) then
    
		set msg = ('Podany aktor ma obecnie niezakonczony kontrakt');
        signal sqlstate '45000' set message_text = msg;
        
		#update kontrakty set koniec = now() where aktor=new.aktor;
    
    end if;

end $$
delimiter ;

insert into kontrakty (id, agent, aktor, poczatek, koniec, gaza) values (3000, '100J0', 1, "2018-06-14", "2018-12-12", 5000);

#13-------------------------------------------------------------------------------------------------------
delimiter $$  
create trigger correctZagrali after delete on filmy for each row  
begin 
    delete from zagrali where film_id not in (select film_id from filmy);
end; $$  

delimiter ;

#trigger z zadania 11
#14-------------------------------------------------------------------------------------------------------
create view info as select a.imie, a.nazwisko, ag.nazwa as agent, datediff(k.koniec, k.poczatek) as do_konca from aktorzy a join kontrakty k on a.aktor_id=k.aktor join agenci ag on k.agent=ag.licencja where k.koniec > now();

select * from info;

#drop view info;

#nie może ale ma dostęp do select

#15-------------------------------------------------------------------------------------------------------
create view publicAgent as select nazwa, typ from agenci;

create view publicAktor as select imie, nazwisko, liczba_filmow from aktorzy;

create view publicFilmy as select tytul, gatunek, czas_trwania, kategoria_wiekowa from filmy;

select * from publicAgent;

select * from publicAktor;

select * from publicFilmy;

create user 'public'@'localhost';
grant select on `laboratorium-filmoteka`. publicAgent to 'public'@'localhost';
grant select on `laboratorium-filmoteka`. publicAktor to 'public'@'localhost';
grant select on `laboratorium-filmoteka`. publicFilmy to 'public'@'localhost';

grant show view on `laboratorium-filmoteka`.* to 'public'@'localhost';

show grants for 'public'@'localhost';

#grant execute on `laboratorium-filmoteka` . wartoscKontraktu to 'public'@'localhost';