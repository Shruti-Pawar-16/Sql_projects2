-- 1. who is the senior most employee based on job title
SELECT *
FROM employee
ORDER BY levels desc
limit 1;

-- 2. which country have the most invoices
SELECT billing_country, COUNT(*) AS Max_invoices
FROM invoice
GROUP BY billing_country
ORDER BY Max_invoices DESC

-- 3. What are top 3 values of total invoice?
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

/* 4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
SELECT billing_city, SUM(total) Invoice_total
FROM invoice
GROUP BY billing_city 
ORDER BY Invoice_total DESC
LIMIT 1

/* 5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/
SELECT C.customer_id,C.first_name, SUM(I.total) TOTAL
FROM customer C
JOIN invoice I
ON C.customer_id = I.customer_id
GROUP BY C.customer_id
ORDER BY TOTAL DESC
LIMIT 1

/* 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

SELECT DISTINCT C.email, C.first_name, C.last_name
FROM customer C
JOIN public.invoice I ON C.customer_id = I.customer_id
JOIN public.invoice_line IL ON I.invoice_id = IL.invoice_id
JOIN track T ON IL.track_id = T.track_id
JOIN genre G ON T.genre_id = G.genre_id
WHERE G.name LIKE 'Rock'
ORDER BY C.email


SELECT DISTINCT C.email, C.first_name, C.last_name
FROM customer C
JOIN public.invoice I ON C.customer_id = I.customer_id
JOIN public.invoice_line IL ON I.invoice_id = IL.invoice_id
WHERE IL.track_id IN(SELECT track_id
					 FROM track T
					 JOIN public.genre G ON T.genre_id = G.genre_id
					 WHERE G.name LIKE 'Rock'
					)
ORDER BY C.email

/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
SELECT A.artist_id, A.name, COUNT(A.artist_id) TOTAL_TRACK
FROM public.artist A
JOIN public.album AL ON A.artist_id = AL.artist_id
JOIN public.track T ON AL.album_id = T.album_id
WHERE T.genre_id = (SELECT G.genre_id
					FROM public.genre G
					WHERE G.name LIKE 'Rock')
GROUP BY A.artist_id
ORDER BY TOTAL_TRACK DESC
LIMIT 10

/* 8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/
SELECT T.name, milliseconds
FROM public.track T
WHERE milliseconds > (
						SELECT AVG(milliseconds)
						FROM track)
ORDER BY milliseconds DESC

/*1. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
WITH best_selling_artist AS(
	SELECT AR.artist_id AS artist_id, AR.name AS artist_name, SUM(IL.unit_price *IL.quantity) AS total_spend
	FROM public.invoice_line IL
	JOIN public.track T ON T.track_id = IL.track_id
	JOIN public.album A ON A.album_id = T.album_id
	JOIN public.artist AR ON AR.artist_id = A.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT DISTINCT C.customer_id,C.first_name, C.last_name,BSA.artist_name, SUM(IL.unit_price *IL.quantity) AS total_spend
FROM public.customer C
JOIN public.invoice I ON I.customer_id = C.customer_id
JOIN public.invoice_line IL ON IL.invoice_id = I.invoice_id
JOIN public.track T ON T.track_id = IL.track_id
JOIN public.album AL ON AL.album_id = T.album_id
JOIN best_selling_artist BSA ON BSA.artist_id = AL.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

/*2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */
WITH populer_genre AS(
SELECT COUNT(IL.quantity) purchase, C.country, G.genre_id, G.name genre_name,
ROW_NUMBER() OVER(PARTITION BY C.country ORDER BY COUNT(IL.quantity) DESC) AS ROW_NO
FROM invoice_line IL
JOIN public.invoice I ON I.invoice_id = IL.invoice_id
JOIN public.customer C ON C.customer_id = I.customer_id
JOIN public.track T ON T.track_id = IL.track_id
JOIN public.genre G ON G.genre_id = T.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC,1 DESC
)
SELECT *
FROM populer_genre 
WHERE ROW_NO <= 1

/*3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/