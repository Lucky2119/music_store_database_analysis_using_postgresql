                       --Easy
--1.Who is the senior most employee based on job title?

select *
from  employee
order by "levels"  desc
limit 1

--2.Which countries have the most Invoices? 

select *
from  employee
order by "levels"  desc
limit 1

--3.What are the top 3 values of total invoice?

select total
from invoice
order by "total" desc
limit 3

--4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals ?

select billing_city,
sum(total) as "Invoice_Total"
from invoice
group by "billing_city"
order by "Invoice_Total" desc
limit 1



--5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money ?

select c.customer_id,first_name,last_name,
sum(i.total) as "total_spendings"
from customer as c
join invoice as i
on i.customer_id=c.customer_id
group by c.customer_id
order by total_spendings desc
Limit 1

                                  --Moderate

--1.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A?

select distinct first_name,last_name,email
from customer as c
join invoice as i
on c.customer_id=i.customer_id
join invoice_line as il
on il.invoice_id=i.invoice_id
where track_id in (
	select track_id
	from track as t
	join genre as g
	on g.genre_id=t.genre_id
	where g.name like 'Rock'	
)
order by email





--2. Let invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands?

select a.artist_id,a.name,
count(a.artist_id) as "Number of songs"
from track as t
join album as ab
on ab.album_id=t.album_id
join artist as a
on a.artist_id=ab.artist_id
join genre as g
on g.genre_id=t.genre_id
where g.name like 'Rock'
group by a.artist_id
order by "Number of songs" desc
limit 10

--3.Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first ?

select name,milliseconds
from track
where "milliseconds">(select
avg(milliseconds)
from track)
order by milliseconds






                           --Advance

--1.Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 

with best_selling_artist as 
(
	select artist.artist_id as artist_id,artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track
	on track.track_id=invoice_line.track_id
	join album
	on album.album_id=track.album_id
	join artist
	on artist.artist_id=album.artist_id
	group by 1
	order by 3 desc
	limit  1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as total_amount_spent
from invoice as i
join customer as c
on c.customer_id=i.customer_id
join invoice_line as il
on i.invoice_id=il.invoice_id
join track as t
on t.track_id=il.track_id
join album as alb
on alb.album_id=t.album_id
join artist as a
on a.artist_id=alb.artist_id
join best_selling_artist as bsa
on bsa.artist_id=a.artist_id
group by 1,2,3,4
order by 5 desc


2.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres?


with most_popular_genre as
(
	select customer.country,genre.name,genre.genre_id,
	count(invoice_line.quantity) as total_purchase,
	row_number() over(partition by customer.country order by
     count(invoice_line.quantity) desc) as row_no
	from customer
	join invoice
	on customer.customer_id=invoice.customer_id
	join invoice_line 
	on invoice_line.invoice_id=invoice.invoice_id
	join track
	on track.track_id=invoice_line.track_id
	join genre
	on genre.genre_id=track.genre_id
	group by 1,2,3
	order by 1 asc

)
select * from most_popular_genre
where row_no <=1

--2nd method (recursive)

with recursive country_wise_sales as
(
	select customer.country,genre.name,genre.genre_id,
	count(invoice_line.quantity) as total_purchase
	from customer
	join invoice
	on customer.customer_id=invoice.customer_id
	join invoice_line 
	on invoice_line.invoice_id=invoice.invoice_id
	join track
	on track.track_id=invoice_line.track_id
	join genre
	on genre.genre_id=track.genre_id
	group by 1,2,3
	order by 1 asc

), country_wise_maximum_genre as 
(
	select country,
	max(total_purchase) as maximum_genre_number
	from country_wise_sales
	group by 1
	order by 1
)
select cws.* from country_wise_sales as cws
join country_wise_maximum_genre as cwmg
on cws.country=cwmg.country
where cws.total_purchase=cwmg.maximum_genre_number




--3.Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount 

with top_customer as
(
	select customer.customer_id,customer.first_name,customer.last_name,customer.country,
	sum(total) as max_amount_spent,
	row_number() over(partition by customer.country order by sum(total)desc) as row_no
	from customer
	join invoice
	on invoice.customer_id=customer.customer_id
	group by  1,2,3,4
	order by customer.country asc,max_amount_spent desc
)
select * from top_customer
where row_no<=1



--2nd method

with customer as
(
	select customer.customer_id,customer.first_name,customer.last_name,customer.country,
	sum(total) as total_amount_spent
	--row_number() over(partition by customer.country order by sum(total)desc) as row_no
	from customer
	join invoice
	on invoice.customer_id=customer.customer_id
	group by  1,2,3,4
	order by customer.country asc,total_amount_spent desc
),max_amount_spent as 
(
	select country,
	max(total_amount_spent) as max_amount
	from customer
	group by 1
	order by 1
)
select c.*
from customer as c
join max_amount_spent as mas
on mas.country=c.country
where mas.max_amount=c.total_amount_spent


