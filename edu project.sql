-- creation of database
create database walmart;
use walmart;

create table weekly_sales(
store int,
date date,
weekly_sales double
);

select * from weekly_sales;
desc weekly_sales;
alter table weekly_sales add column id int auto_increment primary key;

create table economic_factors(
store int,
date date,
holiday_flag int,
temperature float,
fuel_price double,
cpi double,
unemployment double
);

select * from economic_factors;
desc economic_factors;

-- adding a unique id column to economic fators and setting it as primary key
alter table economic_factors add column uid int auto_increment primary key;


-- to retrieve the date in a formatted string like "Month Day, Year" 
-- for all records in the weekly_sales table
select date, date_format(date,'%c-%d-%y') from weekly_sales;

-- to find the average weekly sales across all stores?
select store, round(avg(weekly_sales),0) from weekly_sales
group by store;

-- Calculate the total sales for each store in the last quarter.
select store, round(sum(weekly_sales), 0) from weekly_sales
where date between '2010-11-01' and '2011-02-28'
group by store;

-- to Determine the difference between highest and lowest performed weekly sales of store 1
select store, round(max(weekly_sales) - min(weekly_sales),2) as diffrence
from weekly_sales where store = 1;

-- to Calculate the average weekly sales for each month.
select date_format(date,'%c-%y') as month, round(avg(weekly_sales),0) from weekly_sales
group by month order by month;

-- for Findng the date with the highest temperature recorded across all stores.
select store, max(temperature) from economic_factors
group by store order by store;

-- to analyse the total weekly sales for all stores during the holiday season?
select w.store, round(sum(w.weekly_sales),0)
from weekly_sales as w
left join economic_factors as e
on w.id = e.uid
where e.holiday_flag = 1
group by w.store
order by w.store;


-- to Calculate the average fuel price for each store.
select store, truncate(avg(fuel_price),2) from economic_factors
group by store;

-- for Finding the store with the maximum CPI value.
select distinct store, max(cpi)as cpi from economic_factors
group by store order by cpi desc;

-- Ranking the stores based on their weekly sales using view fucntion.
create view demo as
(select store, sum(weekly_sales) as weekly_sales from weekly_sales
group by store);

select store, rank() over (order by weekly_sales desc) from demo;

-- to Calculate the moving average of weekly sales over a period of 4 weeks for each store.
SELECT store, week,
AVG(round(weekly_sales,0)) OVER (PARTITION BY store ORDER BY week ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_avg_sales
FROM 
(SELECT store, week(date) AS week, SUM(weekly_sales) AS weekly_sales
FROM weekly_sales
GROUP BY store, week) AS weekly_sales_data;

-- for creation of a view that categorizes the weeks with holiday_flag = 1 as "Holiday Weeks"
-- and others as "Regular Weeks".
CREATE VIEW week_categories_view AS
SELECT * ,CASE WHEN holiday_flag = 1 THEN 'Holiday Weeks'
ELSE 'Regular Weeks' END AS week_category
FROM economic_factors;

select * from week_categories_view;

-- creation of a new procedure sales_report to sort the weekly sales table by a particular date period

DELIMITER //

CREATE PROCEDURE sales_report(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT * FROM weekly_sales WHERE date BETWEEN p_start_date AND p_end_date;
END //
DELIMITER ;
drop procedure sales_report;

call sales_report('2011-01-01','2011-02-01');




