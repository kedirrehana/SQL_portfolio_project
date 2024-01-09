--************************Music Store Analysis Questions*******************************--

--1. What are the top-selling albums of all time?--

SELECT a.title, SUM(il.quantity) AS total_sold
FROM album a
JOIN track t
ON a.album_id = t.album_id
JOIN invoice_line il 
ON t.track_id = il.track_id
GROUP BY a.title
ORDER BY total_sold DESC
LIMIT 10;


-- 2. Which artists have the most tracks in the store? --

SELECT ar.name, COUNT(tr.track_id) AS track_count
FROM artist ar
JOIN album al
ON ar.artist_id = al.artist_id
JOIN track tr 
ON al.album_id = tr.album_id
GROUP BY ar.name
ORDER BY track_count DESC
LIMIT 10;

--3. What is the distribution of sales across different genres? --

SELECT g.name AS genre, COUNT(il.invoice_id) AS sales_count
FROM genre g
JOIN track t
ON g.genre_id = t.genre_id
JOIN invoice_line il
ON t.track_id = il.track_id
GROUP BY genre
ORDER BY sales_count DESC;

--4. How do sales vary by month or year? --

SELECT DATE_TRUNC('month', i.invoice_date) AS month_year,
       SUM(il.unit_price) AS total_sales
FROM invoice i
JOIN invoice_line il 
ON i.invoice_id = il.invoice_id
GROUP BY month_year
ORDER BY month_year;

--5. Who are the top-spending customers? --

SELECT c.first_name, c.last_name,
       SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

--6. What are the average sales per customer? --

SELECT AVG(total) AS average_sales_per_customer
FROM (
    SELECT customer_id, SUM(total) AS total
    FROM invoice
    GROUP BY customer_id
) AS customer_totals;

--7. Which countries have the highest sales? --

SELECT billing_country, SUM(total) AS total_sales
FROM invoice
GROUP BY billing_country
ORDER BY total_sales DESC
LIMIT 10;

--8. How do sales compare between digital tracks and full albums? --

SELECT invoice_line_id,
       CASE
           WHEN (
               SELECT COUNT(track_id)
               FROM invoice_line 
               WHERE invoice_line.invoice_id = invoice.invoice_id
           ) = (
               SELECT COUNT(track_id)
               FROM track
               WHERE track.album_id = (
                   SELECT album.album_id
                   FROM album
                   JOIN track 
				   ON album.album_id = track.album_id
                   WHERE track.track_id = invoice_line.track_id
               )
           ) THEN 'Full Album'
           ELSE 'Individual Tracks'
       END AS purchase_type,
       SUM(unit_price) AS total_sales
FROM invoice_line
JOIN invoice 
ON invoice_line.invoice_id = invoice.invoice_id
GROUP BY invoice_line.invoice_line_id, purchase_type;
 
 --9. What are the most popular tracks recently? --
 
 SELECT t.name AS track_name, COUNT(il.invoice_line_id) AS sales_count
FROM track t
JOIN invoice_line il 
ON t.track_id = il.track_id
JOIN invoice i 
ON il.invoice_id = i.invoice_id
WHERE i.invoice_date >= CURRENT_DATE - INTERVAL '46' MONTH
GROUP BY track_name
ORDER BY sales_count DESC
LIMIT 10;

--10. Which employees have processed the most sales? --

SELECT e.first_name, e.last_name,
       COUNT(i.invoice_id) AS total_sales_processed
FROM employee e
JOIN customer c 
ON CAST(e.employee_id AS INTEGER) = c.support_rep_id
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY total_sales_processed DESC;

--11. What is the average number of tracks in an album? --

SELECT AVG(track_count) AS average_tracks_per_album
FROM (
    SELECT album.album_id, COUNT(track.track_id) AS track_count
    FROM album
    JOIN track 
	ON album.album_id = track.album_id
    GROUP BY album.album_id
) AS Album_Average;


--12. Which genres have the highest average track length? --

SELECT g.name AS genre, AVG(t.milliseconds) AS avg_track_length
FROM genre g
JOIN track t 
ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY avg_track_length DESC;


--13. What are the total sales for each album? --

SELECT a.title AS album_title, SUM(il.unit_price) AS total_sales
FROM album a
JOIN track t 
ON a.album_id = t.album_id
JOIN invoice_line il 
ON t.track_id = il.track_id
GROUP BY album_title
ORDER BY total_sales DESC;


--14. How does sales revenue vary by day of the week? --

SELECT DATE_TRUNC('day', i.invoice_date) AS day_of_week,
       SUM(total) AS total_sales
FROM invoice i
GROUP BY day_of_week
ORDER BY total_sales DESC


--15. Which tracks have never been purchased? --

SELECT t.name AS track_name
FROM track t
LEFT JOIN invoice_line il 
ON t.track_id = il.track_id
WHERE il.track_id IS NULL;



