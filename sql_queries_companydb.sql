
--Hard Questions

--Show the employee's first_name and last_name, a "num_orders" column with a count of the orders taken, and a column called "Shipped" that displays "On Time" if the order shipped_date is less or equal to the required_date, "Late" if the order shipped late, "Not Shipped" if shipped_date is null.
--Order by employee last_name, then by first_name, and then descending by number of orders.
SELECT first_name, last_name, count(order_id),
(
case when shipped_date > required_date then 'Late'
  when shipped_date is null then 'Not shipped'
else 'On time' end) as status
from employees
join orders on
employees.employee_id = orders.employee_id
group by first_name, last_name, status
order by last_name, first_name, count(order_id) desc

--Show how much money the company lost due to giving discounts each year, order the years from most recent to least recent. Round to 2 decimal places
Select 
YEAR(o.order_date) AS 'order_year' , 
ROUND(SUM(p.unit_price * od.quantity * od.discount),2) AS 'discount_amount' 

from orders o 
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id

group by YEAR(o.order_date)
order by order_year desc;




--Medium Questions

--Show the ProductName, CompanyName, CategoryName from the products, suppliers, and categories table
SELECT product_name, company_name, category_name
from products
join categories on products.category_id = categories.category_id
join suppliers on products.supplier_id = suppliers.supplier_id

--Show the category_name and the average product unit price for each category rounded to 2 decimal places.
SELECT category_name, round(avg(unit_price),2)
from products
join categories on products.category_id = categories.category_id
group by category_name

--Show the city, company_name, contact_name from the customers and suppliers table merged together. Create a column which contains 'customers' or 'suppliers' depending on the table it came from.
SELECT city, company_name, contact_name, 'Customers'
from customers
union
SELECT city, company_name, contact_name, 'suppliers'
from suppliers

--Show the total amount of orders for each year/month.
SELECT year(order_date), month(order_date), count(order_date)
from orders
group by month(order_date), year(order_date)
order by year(order_date)




--Easy Questions

--Show the category_name and description from the categories table sorted by category_name.
SELECT category_name, description
from categories
order by category_name

--Show all the contact_name, address, city of all customers which are not from 'Germany', 'Mexico', 'Spain'
SELECT contact_name, address, city
from customers
where country not in ('Germany','Mexico','Spain')

--Show order_date, shipped_date, customer_id, Freight of all orders placed on 2018 Feb 26
SELECT order_date, shipped_date, customer_id, freight
from orders
where order_date is '2018-02-26'

--Show the employee_id, order_id, customer_id, required_date, shipped_date from all orders shipped later than the required date
SELECT employee_id, order_id, customer_id, required_date,
shipped_date
from orders
where shipped_date > required_date

--Show all the even numbered Order_id from the orders table
SELECT  order_id
from orders
where order_id%2 = 0

--Show the city, company_name, contact_name of all customers from cities which contains the letter 'L' in the city name, sorted by contact_name
SELECT city, company_name, contact_name
from customers
where city like '%l%'
order by contact_name

--Show the company_name, contact_name, fax number of all customers that has a fax number. (not null)
SELECT company_name, contact_name, fax
from customers
where fax is not null

--Show the first_name, last_name. hire_date of the most recently hired employee.
SELECT first_name, last_name, max(hire_date)
from employees

--Show the average unit price rounded to 2 decimal places, the total units in stock, total discontinued products from the products table.
SELECT round(avg(unit_price),2), sum(units_in_stock),
sum(discontinued)
from products