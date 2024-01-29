--drop database
drop database bikestore

-- drop the schemas
DROP SCHEMA IF EXISTS sales
DROP SCHEMA IF EXISTS production

-- drop tables
DROP TABLE IF EXISTS categories

-- create database
CREATE DATABASE bikestore

--create schemas
--production
CREATE SCHEMA production
go
--sales
CREATE SCHEMA sales
go

--4. Create categories table in production schema
CREATE TABLE production.categories (
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	category_name VARCHAR(255) NOT NULL
)
--
SELECT * FROM production.categories

-- Insert data into categories table
INSERT INTO production.categories(category_name)
VALUES
	('Children Bicycles'),
	('Comfort Bicycles'),
	('Cruisers Bicycles'),
	('Cyclocross Bicycles'),
	('Electric Bikes'),
	('Mountain Bikes'),
	('Road Bikes')

--
SELECT * FROM production.categories
--

-- 5 Create brands table in production schema
CREATE TABLE production.brands(
	brand_id INT IDENTITY(1,1) PRIMARY KEY,
	brand_name VARCHAR(255)  NOT NULL
)
--
SELECT * FROM production.brands

-- Insert data into production.brand table

INSERT INTO production.brands(brand_name)
VALUES
	('Electra'),
	('Haro'),
	('Heller'),
	('Pure Cycles'),
	('Ritchey'),
	('Strinder'),
	('Sun Bicycles'),
	('Surly'),
	('Trek')

--
SELECT * FROM production.brands

--
CREATE TABLE production.products(
	product_id INT IDENTITY(1,1) PRIMARY KEY,
	product_name VARCHAR(255)  NOT NULL,
	brand_id INT  NOT NULL,
	Category_id INT  NOT NULL,
	model_year SMALLINT  NOT NULL,
	list_price DECIMAL(10,2) NOT NULL,
	FOREIGN KEY(category_id) REFERENCES production.categories(category_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(BRAND_id) REFERENCES production.brands(brand_id)
	ON DELETE CASCADE ON UPDATE CASCADE
)

--
select * from production.products

-- Insert data into product table
BULK INSERT production.products
from 'C:\Users\ASUS\OneDrive\Desktop\sql_files\products.csv'
with(
	FIELDTERMINATOR=',',
	ROWTERMINATOR='\n',
	FIRSTROW=2
)

--
select * from production.products

--create customers table in sales schema
-- pull directly and apply the requirements on wizards


--8 create table in sales schema
create table sales.stores(
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	store_name varchar(255) not null,
	phone varchar(25),
	email varchar(255),
	street varchar(255),
	city varchar(255),
	state varchar(10),
	zip_code varchar(5)
)
--
select * from sales.stores

--
insert into sales.stores(store_name,phone,email,street,city,state,zip_code)
values('bhopal rockers bikes','(831) 476-4321','bhopalrockers@bikes.shop','3700 vip drive'
,'bhopal','mp',95060),
('gopal bikes','(516) 379-8888','gopal@bikes.shop','4200 old shopping mall'
,'mumbai','MH',11432),
('rowlett bikes','(972) 530-5555','rowlett@bikes.shop','8000 fairway avenue'
,'Gujrat','GU',75088)

--
select * from sales.stores


create table production.stocks(
	store_id INT ,
	product_id INT,
	qunatity INT,
	primary key (store_id,product_id),
	foreign key(store_id) references sales.stores(store_id)
	on delete cascade on update cascade,
	foreign key(product_id) references production.products(product_id)
	on delete cascade on update cascade
)

--
bulk insert production.stocks
from 'C:\Users\ASUS\OneDrive\Desktop\sql_files\stocks.csv'
with(
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow=2
)

--
select * from production.stocks

--

create table sales.staffs(
	staff_id INT IDENTITY(1,1) PRIMARY KEY,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	email varchar(255) not null unique,
	phone varchar(25),
	active tinyInt not null,
	store_id int not null,
	manager_id int,
	foreign key (store_id) references sales.stores(store_id)
	on delete cascade on update cascade,
	foreign key(manager_id) references sales.staffs(staff_id)
	on delete no action on update no action
)

bulk insert
from 'C:\Users\ASUS\OneDrive\Desktop\sql_files\'
with (
	fieldterminator=',',
	rowterminator='\n',
	firstrow=2
)


-- Ques-1 Give the list of products name,category name and its list price
-- INNER JOin (Ignore the rows of tables if keys are not matching,does not include in result)

select * from production.products

-- The Query returned only a list of category identification numbers,not the category names.
-- To include the category name in the result set,you use the INNER join clause as follows:

Select * from 
	production.products p 
INNER JOIN
	production.categories c
	ON c.category_id = p.Category_id
ORDER BY
	product_name desc
--

-- With field requirements
Select p.product_name,p.product_id,p.list_price from 
	production.products p 
INNER JOIN
	production.categories c
	ON c.category_id = p.Category_id
ORDER BY
	product_name desc


Select p.product_name,c.category_name,b.brand_name,p.list_price from 
	production.products p 
INNER JOIN
	production.categories c
	ON c.category_id = p.Category_id
INNER JOIN production.brands b
	on p.brand_id=b.brand_id
ORDER BY
	product_name desc


--Left Join
--Ques-2: Give list of products that have not been sold to any customer yet.
--Step-1, Get the order details corresponding to product name

select p.product_name,o.order_id
from production.products p
left join sales.orders_items o 
on o.product_id =p.product_id
where o.order_id is null
order by o.order_id


--Ques-3: Give the product name along with its order details like
-- order_id,its item id and the order date.
select p.product_name,o.order_id,item_id,order_date
from production.products p
Left JOIN sales.orders_items oi
on oi.product_id=p.product_id
Left Join sales.orders o 
on o.order_id=oi.order_id

--Find the products that belong to order id 100 in above query
select p.product_name,o.order_id,item_id,order_date
from production.products p
Left JOIN sales.orders_items oi
on oi.product_id=p.product_id
Left Join sales.orders o 
on o.order_id=oi.order_id
where o.order_id=100


-- Right Join

-- Cross Join
--The following statement returns the combinations of all products and stores.
-- The result set can be used for stocktaking products during the month-end and year-end clothing

select 
	product_id,
	product_name,
	store_id,
	0 as quantity -- Initial value is set as zero
from
	production.products
cross join sales.stores
order by
	product_name,
	store_id

-- self join
--Ques-5 : who reports whom? List of employees and their managers.
select
	e.first_name+' '+e.last_name employee,
	m.first_name+' '+m.last_name manager

from sales.staffs e
left join sales.staffs m
on m.staff_id=e.manager_id


select
	c1.city,
	c1.first_name+' '+c1.last_name customer_1,
	c2.first_name+' '+c2.last_name customer_2
from sales.customers c1
inner join sales.customers c2
on c1.customer_id<>c2.customer_id
and c1.city=c2.city
order by city,
customer_1,customer_2