#1
show tables;
#2
select title from film where length>120;
#3
select f.title, l.name as film_language from film f join language l on l.language_id=f.language_id where description like "%documentary%";
#4
select f.title from film f join film_category fc on f.film_id=fc.film_id join category c on c.category_id=fc.category_id where c.name like "%Documentary%" and f.description not like "%documentary%";
#5
select distinct a.first_name, a.last_name from film f join film_actor fa on f.film_id=fa.film_id join actor a on fa.actor_id=a.actor_id where f.special_features like "%deleted scenes%";
#6
select rating, count(*) from film group by rating;
#7
select distinct f.title from film f join inventory i on i.film_id=f.film_id join rental r on r.inventory_id=i.inventory_id where r.rental_date between '2005-05-25' and '2005-05-30' order by f.title;
#8
select f.title from film f where rating like "R" order by length desc limit 5;
#9
create view p1 as select staff_id, customer_id from rental where staff_id=1;
create view p2 as select staff_id, customer_id from rental where staff_id=2;

select distinct c.first_name, c.last_name from p1 join p2 on p1.customer_id=p2.customer_id join customer c on c.customer_id=p2.customer_id;

drop view p1;
drop view p2;
#10
select co.country from country co join city c on co.country_id=c.country_id group by country having count(*)>=(select count(*) from country join city on country.country_id=city.country_id where country.country like "canada");
#11
select c.first_name, c.last_name from customer c join rental r on c.customer_id=r.customer_id group by r.customer_id having count(*)>(select count(*) from customer c join rental r on c.customer_id=r.customer_id where email like "PETER.MENARD@sakilacustomer.org");
#12 
create view Pair as select a1.actor_id as actor_1, a2.actor_id as actor_2 from film_actor a1 join film_actor a2 on a1.film_id=a2.film_id where a1.actor_id<a2.actor_id group by actor_1, actor_2 having count(*)>1;

select a1.first_name as a1_Fname, a1.last_name as a1_Lname, a2.first_name as a2_Fname, a2.last_name as a2_Lname from Pair join actor a1 on Pair.actor_1=a1.actor_id join actor a2 on Pair.actor_2=a2.actor_id;

drop view Pair;
#13
select a.last_name from actor a where a.actor_id not in (select distinct a.actor_id from actor a join film_actor fa on a.actor_id=fa.actor_id join film f on fa.film_id=f.film_id where f.title like "b%");
#14
create view view1 as select count(*) as count1, a.actor_id  from actor a join film_actor fa on a.actor_id=fa.actor_id join film_category fc on fa.film_id=fc.film_id join category on fc.category_id=category.category_id where name like "horror" group by a.actor_id;
create view view2 as select count(*) as count2, a.actor_id from actor a join film_actor fa on a.actor_id=fa.actor_id join film_category fc on fa.film_id=fc.film_id join category on fc.category_id=category.category_id where name like "action" group by a.actor_id;

select a.first_name, a.last_name from actor a join view1 on a.actor_id = view1.actor_id join view2 on a.actor_id = view2.actor_id where view1.count1>view2.count2;

drop view view1;
drop view view2;
#15
select c.first_name, c.last_name from customer c join payment p on c.customer_id=p.customer_id group by c.customer_id having avg(amount)>(select avg(payment.amount) from payment where payment_date like "2005-07-07%");
#16
alter table language add column films_no int not null;

create view v3 as select l.language_id, count(*) as NewCol from film f join language l on f.language_id=l.language_id group by l.language_id;

update language l join film f on l.language_id=f.language_id join v3 on v3.language_id=l.language_id set films_no=(v3.NewCol);

drop view v3;

update language l join (select l.language_id, count(*) as NewCol from film f join language l on f.language_id=l.language_id group by l.language_id) t on l.language_id = t.language_id set film_no=t.NewCol;
#17
update film set language_id=4 where film.title like "WON DARES";
update film f join film_actor fa on f.film_id=fa.film_id join actor a on fa.actor_id=a.actor_id set language_id=6 where first_name like "NICK" and last_name like "WAHLBERG";
#18
alter table film drop column release_year;