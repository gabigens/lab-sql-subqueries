-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;

#1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT f.title, COUNT(i.inventory_id)  AS number_of_copies
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible"
GROUP BY f.title;

#2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT * 
FROM film
WHERE length > (SELECT AVG(length) FROM film);

#3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT f.title, CONCAT(a.first_name, " ", a.last_name) AS cast 
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
WHERE f.title = "Alone Trip";

SELECT CONCAT(a.first_name, " ", a.last_name) AS cast 
FROM actor a
WHERE a.actor_id IN (
  SELECT fa.actor_id
  FROM film_actor fa
  WHERE fa.film_id = (
    SELECT film_id 
    FROM film 
    WHERE title = 'Alone Trip'));
    
-- Bonus:
#4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT f.film_id, f.title, c.name AS category
FROM film f
JOIN film_category fa
ON f.film_id = fa.film_id
JOIN (SELECT * 
	FROM category
	WHERE name = "Family") c
ON fa.category_id = c.category_id;

#5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT CONCAT(first_name, " ", last_name) AS client, email
FROM customer
WHERE address_id IN (SELECT address_id
					FROM address
					WHERE city_id IN (SELECT city_id 
									FROM city
									WHERE country_id = (SELECT country_id 
														FROM country
														WHERE country = "Canada")));
    
#6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT f.film_id, f.title, a.actor_id, CONCAT(a.first_name, " ", a.last_name) as actor_name
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE fa.actor_id = (SELECT actor_id
				FROM film_actor
				GROUP BY actor_id
				ORDER BY COUNT(film_id) DESC
				LIMIT 1);

#7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.film_id, f.title, c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS client
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN customer c
ON r.customer_id = c.customer_id
WHERE r.customer_id = (SELECT c.customer_id
					FROM customer c
					JOIN payment p
					ON c.customer_id = p.customer_id
					GROUP BY c.customer_id
					ORDER BY SUM(amount) DESC
					LIMIT 1);

#8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT c.customer_id, SUM(p.amount) AS total_amount_spent
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING total_amount_spent > (SELECT AVG(total_by_customer)
							FROM (SELECT SUM(amount) AS total_by_customer
							FROM payment
							GROUP BY customer_id) AS total); 
