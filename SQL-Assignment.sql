# 1a. Display the first and last names of all actors from the table `actor`.
# Selecting all the columns in the table first.

Select * from actor;
Select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. 
#Name the column `Actor Name`.

Select upper(concat(first_name," ", last_name)) "Actor Name" from actor;


#2a. You need to find the ID number, first name, and last name of an actor, 
#of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

Select actor_id, first_name, last_name 
from actor
where first_name= "Joe"; 

#2b. Find all actors whose last name contain the letters `GEN`:

Select actor_id, first_name, last_name 
from actor
where last_name like "%GEN%";

# 2c. Find all actors whose last names contain the letters `LI`. 
# This time, order the rows by last name and first name, in that order:

Select actor_id, first_name, last_name 
from actor
where last_name like "%LI%" 
Order by last_name, first_name;


# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
#Afghanistan, Bangladesh, and China:

Select * from country;

Select country_id, country
from country
where country in ("Afghanistan", "Bangladesh", "China");


#  3a. You want to keep a description of each actor. You don't think you will be performing queries on a 
#description, so create a column in the table `actor` named `description` and use the data type `BLOB` 
#(Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table actor 
add description blob;

select * from actor;
describe actor;

# * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
# Delete the `description` column.

alter table actor
drop column description;

select * from actor;
describe actor;


# 4a. List the last names of actors, as well as how many actors have that last name.
select * from actor;

select last_name , count(last_name) last_name_counts 
from actor
group by last_name;


#* 4b. List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors

Select * from actor;
Select last_name , count(last_name) as count_actors
from actor
group by last_name
having count_actors >=2;


#* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
# Write a query to fix the record.

Select * from actor;
update actor 
set first_name = "Harpo", last_name ="Williams"
where actor_id= 172;

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
#It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = "GROUCHO" 
where actor_id= 172;


#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
#* Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

show create table address;

#OR

select * from information_schema.table_constraints
where table_name like "%address%";

#* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
# Use the tables `staff` and `address`:

Select * from staff;
select * from address;

select s.first_name, s.last_name, a.address,a.district, a.postal_code
from staff as s
inner join address as a 
on s.address_id=a.address_id;


#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
# Use tables `staff` and `payment`.

select * from staff;
select * from payment;
describe payment;

select s.first_name, s.last_name ,sum(p.amount)
from staff as s
join payment as p
on s.staff_id = p.staff_id
where p.payment_date like "2005-08-%"
group by s.staff_id;


#* 6c. List each film and the number of actors who are listed for that film. 
# Use tables `film_actor` and `film`. Use inner join.

select *  from film_actor;
select * from film;

select f.title,fa.actor_id
from film_actor as fa
inner join film as f
on fa.film_id = f.film_id
group by f.title;


#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select * from inventory;
select * from film;
select * from rental;
select * from store;

select a.title, b.film_id, count(b.film_id) as "count of inventory"
from film as a
inner join inventory as b on a.film_id= b.film_id
group by a.title
having a.title ="Hunchback Impossible";


#* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid 
#by each customer. List the customers alphabetically by last name:
#![Total amount paid](Images/total_payment.png)

select * from payment;
select * from customer;

select c.first_name, c.last_name, sum(p.amount)
from customer as c
join payment as p
on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name asc;


#* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
#Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language
# is English.

select * from film;
select * from language;

select f.title
from film as f
where language_id=(
	select l.language_id
	from language as l
    where l.language_id= 1)
having (f.title like "K%") OR (f.title like"Q%");


#* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select * from film;
select * from film_actor;
select * from actor;

select a.first_name, a.last_name
from actor as a
where a.actor_id IN(
	select b.actor_id
    from film_actor as b
    where b.film_id in(
    select c.film_id
    from film as c
    where title = "Alone Trip"));
    
#* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
# email addresses of all Canadian customers. Use joins to retrieve this information.

select * from customer;
select * from country;
select * from address;
select * from city;

select a.first_name, a.last_name, a.email
from customer as a
where a.address_id in(
	select b.address_id
    from address as b
    where b.city_id in(
    select c.city_id 
    from city as c
    where c.country_id in(
    select d.country_id
    from country as d
    where country = "Canada")));

select a.first_name, a.last_name, a.email
from customer as a
inner join address as b
on a.address_id = b.address_id
inner join city as c
on b.city_id = c.city_id
inner join country as d
on c.country_id = d.country_id
where d.country= "Canada";

#* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as family films.

select * from film;
select * from film_category;
select * from category;

Select a.film_id,a.title
from film as a
where film_id in(
	select b.film_id
    from film_category as b
    where b.category_id in (
	select c.category_id
    from category as c
    where c.name ="Family"));
    
    
    
#* 7e. Display the most frequently rented movies in descending order.

select * from rental;
select * from film;
select * from inventory;

  
select a.inventory_id, a.film_id,c.title, count(a.film_id)
from inventory as a
inner join rental as b
on a.inventory_id= b.inventory_id
	inner join film as c
	on a.film_id=c.film_id
    group by a.film_id
    order by a.film_id desc;
    
#* 7f. Write a query to display how much business, in dollars, each store brought in.

select * from store;
select * from customer;
select * from payment;

select sum(a.amount), c.store_id
from payment as a
inner join customer as b
on a.customer_id= b.customer_id
inner join store as c
on b.store_id = c.store_id
group by c.store_id;

#* 7g. Write a query to display for each store its store ID, city, and country.

select * from store;
select * from staff;
select * from rental;
select * from address;
select * from customer;
select * from inventory;
select * from country;
select * from city;

select a.store_id, c.city, d.country
from store as a 
inner join address as b
on a.address_id=b.address_id
inner join city as c
on b.city_id = c.city_id
inner join country as d
on c.country_id= d.country_id
group by a.store_id
order by a.store_id;

select a.store_id, e.city, f.country
from store as a 
inner join customer as b
on a.store_id= b.store_id
inner join staff as c
on b.store_id =c.store_id
inner join address as d
on c.address_id=d.address_id
inner join city as e
on d.city_id = e.city_id
inner join country as f
on e.country_id= f.country_id;

#* 7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, 
# payment, and rental.)

select * from film;
select * from film_category;
select * from category;
select * from payment;
select * from inventory;
select * from rental;


select a.category_id, a.name , sum(f.amount)
from category as a
inner join film_category as b
on a.category_id=b.category_id
inner join film as c
on b.film_id =c.film_id
inner join inventory as d
on c.film_id =d.film_id
inner join rental as e
on d.inventory_id= e.inventory_id
inner join payment as f
on e.rental_id=f.rental_id
group by a.category_id
order by sum(f.amount) desc limit 5;

#* 8a. In your new role as an executive, you would like to have an easy way of viewing 
#the Top five genres by gross revenue. Use the solution from the problem above to 
#create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres_revenue
as select a.category_id, a.name , sum(f.amount)
from category as a
inner join film_category as b
on a.category_id=b.category_id
inner join film as c
on b.film_id =c.film_id
inner join inventory as d
on c.film_id =d.film_id
inner join rental as e
on d.inventory_id= e.inventory_id
inner join payment as f
on e.rental_id=f.rental_id
group by a.category_id
order by sum(f.amount) desc limit 5;


#* 8b. How would you display the view that you created in 8a?

select * from top_five_genres_revenue;

#* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five_genres_revenue;








