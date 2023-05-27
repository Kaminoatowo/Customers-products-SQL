# Introduction

Install a tool to query and manipulate SQLite: DB Browser for SQLite

I downloaded the `stores.db` database file

Using DB Browser for SQLite I can inspect data in the `stores.db`

There is an *Execute SQL* tab from which I can execute SQL queries

With data analysis we can extract key performance indicators (KIPs) to make smarter decisions, which saves time, resources and money

For this project I will analyze data from a sales records database for scale model cars and extract information for decision-making

# Questions

1.  Which products should we order more of or less of?
2.  How should we tailor marketing and communication strategies to customer behaviors?
3.  How much can we spend on acquiring new customers?

# Scale model cars database

The database contains eight tables:

-   customers: customer data
-   employees: all employee information
-   offices: sales office information
-   orders: customers' sales orders
-   orderdetails: sales order line for each sales order
-   payments: customers' payment records
-   products: a list of scale model cars
-   productlines: a list of product line categories

## Inspect the database

**through queries**

E.g.

-   Display the first five lines from the `products`
```
SELECT *
  FROM products
 LIMIT 5;
```

-   Count lines in the `products` table
```
SELECT COUNT(*)
  FROM products;
```

**Informations on the tables**

|Tables         |N. columns |N. rows    |
|---|---|---|
|`customer`     |$13$       |$122$      |
|`employees`    |$8$        |$23$       |
|`offices`      |$9$        |$7$        |
|`orders`       |$7$        |$326$      |
|`orderdetails` |$5$        |$2996$     |
|`payments`     |$4$        |$273$      |
|`products`     |$9$        |$110$      |
|`productlines` |$4$        |$7$        |
|---|---|---|

-   `customers` table contains information about customers as the number, names, phone numbers and address
-   `employees` table has data related to employees, such as their names, email, office numbers and job title
-   `offices` table contains data about offices, where they are and the respective phone numbers and address
-   `orders` table has the number and dates related to orders, together with their status and any comments
-   `orderdetails` table has some more data related to orders, as quantities, price and codes
-   `payments` table contains the number of customer who made the payment, the check number, payment date and the amount
-   `products` table contains information on products, like names, type of product, descriptions, quantity in stock and also prices
-   `productlines` table has more details on the product lines

## Answering the questions

### Which Products Should We Order More of or Less of?

This question refers to inventory reports, including **low stock** and **product performance**. This will optimize supply and the user experience by preventing the best-selling products from going out-of-stock.

*Low stock* represents the quantity of the sum of each product ordered divided by the quantity of product in stock. Consider the highest rates. Obtain the top ten products that are almost out-of-stock or completely out-of-stock.

*Product performance* is the sum of the sales per product.

*Priority products* for restocking are those with high *product performance* that are on the brink of being out of stock.

I need the `products` and `orderdetails` tables to perform these calculations:

- $low stock = \frac{SUM(quantityOrdered)}{quantityInStock}$
- $products performance = SUM(quantityOrdered \times priceEach)$

**Instructions**

- Write a query to compute the low stock for each product using a correlated subquery
  - round down the result to the nearest hundredth
  - select `productCode` and group the rows
  - keep only the top ten of products by low stock
- Write a query to compute the product performance for each product
  - select `productCode` and group the rows by it
  - keep only the top ten products by product performance
- Combine the previous queries using a Common Table Expression (CTE) to display priority products for restocking using hte IN operator

**Results**

Top $3$ products that are almost out of stock are

|Products         |productCode |product performance    |
|---|---|---|
|1992 Ferrari 360 Spider red     |`S18_3232`       |$276839.98$     |
|1937 Lincoln Berline   |`S18_1342`       |$102563.52$      |
|1941 Chevrolet Special Deluxe Cabriolet      |`S18_3856`      |$102537.45$        |

### How Should We Match Marketing and Communication Strategies to Customer Behavior?

Let's explore customer information. To answer the question I have to categorize customers: find the VIP customers and those who are less engaged.

- VIP customers bring in the most profit to the store
- less-engaged customers bring in less profit

E.g. we could organize events to drive loyalty for the VIPs and launch a campaign for the less engaged.

I need `products`, `orderdetails` and `orders` tables

**Instructions**

- Write a query to join `products`, `orders` and `orderdetails` tables to have customersand products information in the same place
  - select `customerNumber`
  - compute, for each customer, the profit

$profit = SUM(quantityOrdered \times (priceEach - buyPrice))$

**Find the top 5 VIPs and less engaged customers**

- Use previous query to get a CTE
  - select `constactLastName`, `contactFirstName`, `city` and `country` from the `customers` table and the `profit` from the CTE

**Results**

|VIPs names       |city |profit    |
|---|---|---|
|Freyre, Diego  |Madrid, Spain       |$326519.66$ |
|Nelson, Susan  |San Rafael, USA     |$236769.39$ |
|Young, Jeff    |NYC, USA            |$72370.09$ |
|Ferguson, Peter|Melbourne, Australia|$70311.07$|
|Labrune, Janine|Nantes, France      |$60875.3$ |

|Less engaged customers       |city |profit    |
|---|---|---|
|Young, Mary    |Glendale, USA  |$2610.87$  |
|Taylor, Leslie |Brickhaven, USA|$6586.02$  |
|Ricotti, Franco|Milan, Italy   |$9532.93$  |
|Schmitt, Carine|Nantes, France |$10063.8$  |
|Smith, Thomas  |London, UK     |$10868.04$ |

### How Much Can We Spend on Acquiring New Customers?

Find the number of customers arriving each month. In this way we can check if it's worth it to psend money on acquiring new customers. 

The number of clients has been decreasing since 2003. After September 2004 the store had no new customer. 

To determine how much money we can spend acquiring new customers, compute the Customer Lifetime Value (LTV), which represents the average amount of money a customer generates

**Instructions**

Write a query to compute the average of customer profits using the CTE 
-> $39039.59$