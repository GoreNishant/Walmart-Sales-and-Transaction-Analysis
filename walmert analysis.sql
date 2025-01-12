select * from walmates limit 5;

-- buissneess problem
--Q 1] find different payment method and no of transaction and quantity sold?

select payment_method,sum(quantity)as quantity_sold,count(unit_price) as noof_transaction from walmates group by payment_method;

--Q]2 identify highest rated category in each branch,displayingbranch,category and avg rating
select a.category,a. "Branch",a.ranked
from(
select category, "Branch", avg(rating) as average_rating ,
rank() over (partition by "Branch" order by avg(rating) desc )as ranked
from walmates group by category,"Branch" order by average_rating desc limit 5) as a ;

-- Q]3] identify busiest day for each branch based on no of transaction?
	
	ALTER TABLE walmates
ADD COLUMN total_price NUMERIC;

UPDATE walmates
SET total_price = quantity * unit_price;
select *
from(
SELECT 
    "Branch",
    to_char(date,'day')as day,
    COUNT(*) AS no_of_transactions,
	rank() over (partition by "Branch" order by COUNT(*))as ranked
	FROM 
    walmates
GROUP BY 
    "Branch",day
ORDER BY 
     no_of_transactions)as a where a.ranked=1 ;


-- Q 4] identify total quantity sold by payment method?
SELECT 
    payment_method,
    SUM(quantity) AS total_quantity_sold
FROM 
    walmates
GROUP BY 
    payment_method;


-- Q 5]what is average,minimum and maximum rating foe category in each city ?
SELECT 
    category, 
    "City", 
    AVG(rating) AS avg_rating, 
    MIN(rating) AS min_rating, 
    MAX(rating) AS max_rating
FROM 
    walmates
GROUP BY 
    category, "City";

-- Q 6]what is total profit for each category ranked highest to lowest?
SELECT 
    category, 
    SUM(total_price) AS total_profit
FROM 
    walmates
GROUP BY 
    category
ORDER BY 
    total_profit DESC;

-- Q 7]determine which frequently payment methd for each branch?
SELECT 
    "Branch",
    payment_method,
    COUNT(*) AS payment_method_count
FROM 
    walmates
GROUP BY 
    "Branch", payment_method
ORDER BY 
    "Branch", payment_method_count DESC;

-- Q8] how many transaction occurs each shift morning,afternoon,evening?
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(time, 'HH24:MI:SS')) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(time, 'HH24:MI:SS')) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP(time, 'HH24:MI:SS')) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS shift,
    COUNT(*) AS number_of_transactions
FROM 
    walmates
GROUP BY
    shift;


-- Q 9] which branches experience  largest decrease in revenue comapare to previous year  by year revenue?
	WITH yearly_revenue AS (
    SELECT 
        "Branch",
        EXTRACT(YEAR FROM date) AS year,
        SUM(total_price) AS revenue
    FROM walmates
    GROUP BY "Branch", EXTRACT(YEAR FROM date)
)
SELECT 
    current."Branch",
    current.year,
    current.revenue - previous.revenue AS revenue_change
FROM yearly_revenue current
LEFT JOIN yearly_revenue previous
    ON current."Branch" = previous."Branch" 
    AND current.year = previous.year + 1
ORDER BY revenue_change ASC;


