/* I use this kind of queries to see columns for each table */

SELECT *
  FROM customers
LIMIT 5;

/* I use this kind of queries to see the number of rows for each table */

SELECT COUNT(*)
  FROM customers;

/* Write a query to display the following tables:
-   select each table name as a string
-   select the number of attributes as an integer
    (count the number of attributes per table)
-   select the number of rows using COUNT(*) function
-   use the compound-operator UNION ALL ro bind these rows together
*/

/* Create a table with a table_name, number_of_attributes and number_of_rows columns */
SELECT 'Customers' as table_name,
	13 as number_of_attributes,
	count(*) as number_of_rows
	FROM customers

UNION ALL

SELECT 'Employees' as table_name,
	8 as number_of_attributes,
	count(*) as number_of_rows
FROM employees

UNION ALL

SELECT 'Offices' as table_name,
	9 as number_of_attributes,
	count(*) as number_of_rows
FROM offices

UNION ALL

SELECT 'Orders' as table_name,
	7 as number_of_attributes,
	count(*) as number_of_rows
	FROM orders

UNION ALL

SELECT 'OrderDetails' as table_name,
	5 as number_of_attributes,
	count(*) as number_of_rows
FROM orderdetails

UNION ALL

SELECT 'Payments' as table_name,
	4 as number_of_attributes,
	count(*) as number_of_rows
FROM payments
UNION ALL

SELECT 'Products' as table_name,
	9 as number_of_attributes,
	count(*) as number_of_rows
FROM products

UNION ALL

SELECT 'ProductLines' as table_name,
	4 as number_of_attributes,
	count(*) as number_of_rows
FROM productlines

/* Write a query to compute the low stock for each product using a correlated subquery */

SELECT productCode, round(sum(quantityOrdered) * 1.0 /(SELECT quantityInStock 
								FROM products
								GROUP by productCode),2)
	as low_stock
	FROM orderdetails
	GROUP by productCode
	ORDER BY low_stock DESC
	LIMIT 10;

/* Write a query to compute the product performance for each product */

SELECT productCode, sum(quantityOrdered * priceEach)
as prod_perf
from orderdetails
GROUP by productCode
ORDER by prod_perf DESC
LIMIT 10;

/* Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using hte IN operator */

WITH 
low_stock_table as (
SELECT 	productCode, 
		round(sum(quantityOrdered) * 1.0 /(SELECT quantityInStock 
								FROM products
								GROUP by productCode),2)
	as low_stock
	FROM orderdetails
	GROUP by productCode
	ORDER BY low_stock DESC
	LIMIT 10)

SELECT 	productCode, 
		sum(quantityOrdered * priceEach)
as prod_perf
from orderdetails
WHERE productCode in (SELECT productCode
						FROM low_stock_table)
GROUP by productCode
ORDER by prod_perf DESC
LIMIT 10;

/* Get the product name of the top three priority products */

SELECT * 
from products
WHERE productCode in ("S18_3856","S18_1342","S18_3232")

/* Profit per customer number */

SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber;

/* Top 5 VIPs and 5 less engaged customers */

WITH

profit_per_cust as (
SELECT o.customerNumber, sum(quantityOrdered * (priceEach - buyPrice)) as profit
from products p
JOIN orderdetails od
on p.productCode = od.productCode
JOIN orders o
on o.orderNumber = od.orderNumber
GROUP by o.customerNumber)

SELECT contactLastName, contactFirstName, city, country, pc.profit
from customers c
JOIN profit_per_cust pc
on pc.customerNumber = c.customerNumber
order by pc.profit DESC
LIMIT 5;
/*OR 
order by profit
LIMIT 5;*/

/* Find the number of new customers arriving each month */

WITH 

payment_with_year_month_table AS (
SELECT *, 
       CAST(SUBSTR(paymentDate, 1,4) AS INTEGER)*100 + CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
  FROM payments p
),

customers_by_month_table AS (
SELECT p1.year_month, COUNT(*) AS number_of_customers, SUM(p1.amount) AS total
  FROM payment_with_year_month_table p1
 GROUP BY p1.year_month
),

new_customers_by_month_table AS (
SELECT p1.year_month, 
       COUNT(*) AS number_of_new_customers,
       SUM(p1.amount) AS new_customer_total,
       (SELECT number_of_customers
          FROM customers_by_month_table c
        WHERE c.year_month = p1.year_month) AS number_of_customers,
       (SELECT total
          FROM customers_by_month_table c
         WHERE c.year_month = p1.year_month) AS total
  FROM payment_with_year_month_table p1
 WHERE p1.customerNumber NOT IN (SELECT customerNumber
                                   FROM payment_with_year_month_table p2
                                  WHERE p2.year_month < p1.year_month)
 GROUP BY p1.year_month
)

SELECT year_month, 
       ROUND(number_of_new_customers*100/number_of_customers,1) AS number_of_new_customers_props,
       ROUND(new_customer_total*100/total,1) AS new_customers_total_props
  FROM new_customers_by_month_table;