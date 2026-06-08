-- total number of companies
select count(DISTINCT(account)) as total_companies
from accounts

-- total distinct sectors
select count(DISTINCT(sector)) as total_distinct_sectors
from accounts

-- company having highest annual revenue
select account 
from accounts
order by revenue DESC
limit 1

-- company having highest number of employees
select account
from accounts
order by employees DESC
limit 1

-- oldest company 
SELECT account
from accounts
order by year_established 
limit 1

-- latest company
SELECT account
from accounts
order by year_established desc
limit 1

--  top 3 highest revenue generating sectors
select sector,sum(revenue) as total_revenue
from accounts
group by sector
order by total_revenue DESC
limit 3

-- highest revenue generating company in each sector
SELECT sector,account,revenue
from(
select sector,account,revenue,dense_rank()over(PARTITION by sector order by revenue DESC) as rnk
from accounts
)
where rnk = 1

-- number of headquaters of different companies at same cities
select office_location,count(DISTINCT(account)) as total_headquaters
from accounts
group by office_location

--(most of headquater of different company are in united states out of  85 companies 71 companies headquaters are in us)

-- total number of sole trades company , total number of subsidiary company
SELECT
COUNT(CASE WHEN subsidiary_of IS NOT NULL THEN 1 END) AS subsidiary_companies,
COUNT(CASE WHEN subsidiary_of IS NULL THEN 1 END) AS sole_companies
FROM accounts;

--  top 3 sectors with highest number of employees
select sector,sum(employees) as total_employees
from accounts
group by sector
order by total_employees Desc
limit 3

--(with this we can observe that top 3 sector for number of employees and top3 revenue genrating sector are same )
--(so high revenue genrating sector means high number of employees)

-- total no of sales agent
select count(DISTINCT(sales_agent)) as total_sales_agent
from sales_teams

-- total no of managers
select count(DISTINCT(manager)) as total_managers
from sales_teams

-- managerwise total no of sales agent
select manager,count(DISTINCT(sales_agent)) as total_agents
from sales_teams
group by manager

--regionwise total no of sales_agent and total no of managers
select regional_office,count(DISTINCT(sales_agent)) as total_agents,count(DISTINCT(manager)) as total_managers
from sales_teams
group by regional_office

-- total offers and successful_offers per agent
select sales_agent,count(opportunity_id) as total_offers,
sum(case when deal_stage= "Win" then 1 else 0 END) as successful_offers
from sales_pipeline
group by sales_agent

-- top 10 agent with good win percentage
SELECT sales_agent,total_offers,successful_offers,(successful_offers * 100.0 /total_offers) as win_percentage
from (select sales_agent,count(opportunity_id) as total_offers,
sum(case when deal_stage = "Won" then 1 else 0 END) as successful_offers
from sales_pipeline
group by sales_agent)
order by win_percentage DESC


-- total number of products
select count(DISTINCT(product)) as total_products
from products

-- total different series
SELECT count(DISTINCT(series)) as DISTINCT_series
from products

--total products per series
select series,count(DISTINCT(product)) as total_products
from products
group by series

-- most expensive product
SELECT product,sales_price
from products
order by sales_price Desc
limit 1

-- most expensive product per series
SELECT product,series,sales_price
from(
SELECT product,sales_price,series,rank()over(PARTITION by series order by sales_price Desc) as rnk
from products
) 
where rnk = 1

-- total deal offers
select count(DISTINCT(opportunity_id)) as total_deal_offers
from sales_pipeline

-- total successful deal offers
select count(DISTINCT(opportunity_id)) as total_succeful_deal_offers
from sales_pipeline
where deal_stage = "Won"

-- total unsuccessful deal offers
select count(DISTINCT(opportunity_id)) as total_unsuccessful_deal_offers
from sales_pipeline 
where deal_stage = "Lost"

-- deal offers that just are at initial state
select count(DISTINCT(opportunity_id)) as total__deal_offers_at_initial_state
from sales_pipeline 
where deal_stage = "Prospecting"
or deal_stage = "Engaging"

-- win percentage of deal offers
select (succesful_deals * 100.0/total_deals) as win_percentage
from(
select sum(case when deal_stage = "Won" then 1 else 0 END) as succesful_deals,
sum(case when deal_stage = "Lost" then 1 else 0 END) as unsuccesful_deals,
sum(case when deal_stage = "Prospecting" or deal_stage = "Engaging" then 1 else 0 END) as unsuccessful_deals,
count(DISTINCT(opportunity_id)) as total_deals
from sales_pipeline
)


-- total_offers and successful_deals and win % company wise
SELECT account,total_deals,successful_deals,deals_at_initial,
(successful_deals * 100.0 / total_deals) as win_percentage
from(
select account,count(DISTINCT(opportunity_id)) as total_deals,
sum(case when deal_stage = "Won" then 1 else 0 END) as successful_deals,
sum(case when deal_stage = "Prospecting" or deal_stage = "Engaging" then 1 else 0 END) as deals_at_initial
from sales_pipeline
group by account
)


-- top 10 companies with highest deals
SELECT account,total_deals
from(
select account,count(DISTINCT(opportunity_id)) as total_deals,
sum(case when deal_stage = "Won" then 1 else 0 END) as successful_deals,
sum(case when deal_stage = "Prospecting" or deal_stage = "Engaging" then 1 else 0 END) as deals_at_initial
from sales_pipeline
group by account
)
order by total_deals DESC
limit 10

-- top 10 companies with highest win percentage
SELECT account,
(successful_deals * 100.0 / total_deals) as win_percentage
from(
select account,count(DISTINCT(opportunity_id)) as total_deals,
sum(case when deal_stage = "Won" then 1 else 0 END) as successful_deals,
sum(case when deal_stage = "Prospecting" or deal_stage = "Engaging" then 1 else 0 END) as deals_at_initial
from sales_pipeline
group by account
)
order by win_percentage Desc
limit 10 


-- top 10 company revenue wise
select account,sum(close_value) as total_revenue
from sales_pipeline
group by account
order by total_revenue DESC
limit 10

--deal duration companywise and deal_stage
select account,deal_duration,deal_stage
from(
select *,(julianday(close_date) - julianday(engage_date)) as deal_duration
from sales_pipeline
)
order by deal_duration DESC

--average deal duration
select avg(deal_duration) as avg_duration
from(
select *,(julianday(close_date) - julianday(engage_date)) as deal_duration
from sales_pipeline
)
order by deal_duration DESC


-- avg duration of deals_which won
select avg(deal_duration) as avg_duration_won_deals
from(
select *,(julianday(close_date) - julianday(engage_date)) as deal_duration
from sales_pipeline
WHERE deal_stage="Won"
)

-- avg duration of deals_which Lost
select avg(deal_duration) as avg_duration_lost_deals
from(
select *,(julianday(close_date) - julianday(engage_date)) as deal_duration
from sales_pipeline
WHERE deal_stage="Lost"
)

-- win rate per sales agent
select sales_agent,(successful_orders * 100.0 / total_orders) as win_percentage
from(
select sales_agent,count(opportunity_id) as total_orders,
sum(case when deal_stage = "Won" then 1 else 0 end) as successful_orders
from sales_pipeline
group by sales_agent
)
order by win_percentage DESC

-- win percentage per manager
select s.manager,avg(d.win_percentage) as M_win_percentage
from(
select sales_agent,(successful_orders * 100.0 / total_orders) as win_percentage
from(
select sales_agent,count(opportunity_id) as total_orders,
sum(case when deal_stage = "Won" then 1 else 0 end) as successful_orders
from sales_pipeline
group by sales_agent
)
) as d
join sales_teams as s
where s.sales_agent = d.sales_agent
group by s.manager
order by avg(d.win_percentage) DESC


-- sector wise win percentage 
select s.sector,avg(d.win_percentage) as win_percent
from(
SELECT account,total_deals,successful_deals,deals_at_initial,
(successful_deals * 100.0 / total_deals) as win_percentage
from(
select account,count(DISTINCT(opportunity_id)) as total_deals,
sum(case when deal_stage = "Won" then 1 else 0 END) as successful_deals,
sum(case when deal_stage = "Prospecting" or deal_stage = "Engaging" then 1 else 0 END) as deals_at_initial
from sales_pipeline
group by account
)) as d
join accounts as s
on s.account = d.account
group by s.sector
order by win_percent Desc

--product wise total_sales
select p.product,sum(s.close_value) as total_revenue
from products as p
join sales_pipeline as s
on s.product = p.product
group by p.product
order by total_revenue DESC

-- product wise win percentage
select product, (successful_orders * 100.0 / total_orders) as win_percentage
from(
select p.product,count(s.opportunity_id) as total_orders,
sum(case when deal_stage = "Won" then 1 else 0 END)as successful_orders
from products as p
join sales_pipeline as s
on p.product = s.product
group by p.product
)
order by win_percentage DESC

-- product wise total_loss orders and profit orders
SELECT p.product,sum(case when o.close_value < p.sales_price then 1 else 0 END) as loss_deals,
sum(case when o.close_value > p.sales_price then 1 else 0 END) as profit_deals,
sum(case when o.close_value = p.sales_price then 1 else 0 END) as normal_deals
from products as p
join sales_pipeline as o
on p.product = o.product
group by p.product