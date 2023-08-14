-- 1.How many olympics games have been held?

select count(distinct(year, season)) from olympics_history

select count(distinct games) from olympics_history
-- 2.List down all Olympics games held so far.
select distinct year, season,city from olympics_history

-- 3.Mention the total no of nations who participated in each olympics game?
select count(distinct(noc)), year,season from olympics_history group by year,season

-- 4.Which year saw the highest and lowest no of countries participating in olympics?
with t1 as (select games,count(distinct(noc)) cnt from olympics_history group by games)
		select concat(first_value(games) over(order by t1.cnt),'-',first_value(cnt) over(order by t1.cnt)) leat_countries,
		concat(first_value(games) over(order by t1.cnt desc),'-',first_value(cnt) over(order by t1.cnt desc)) most_countries from t1 limit 1

SELECT Year, COUNT(DISTINCT NOC) AS num_countries
FROM olympics_history
GROUP BY Year
HAVING COUNT(DISTINCT NOC) = (
    SELECT MAX(country_count)
    FROM (
        SELECT COUNT(DISTINCT NOC) AS country_count
        FROM olympics_history
        GROUP BY Year
    ) AS counts
)
UNION
SELECT Year, COUNT(DISTINCT NOC) AS num_countries
FROM olympics_history
GROUP BY Year
HAVING COUNT(DISTINCT NOC) = (
    SELECT MIN(country_count)
    FROM (
        SELECT COUNT(DISTINCT NOC) AS country_count
        FROM olympics_history
        GROUP BY Year
    ) AS counts
)
-- 5.Which nation has participated in all of the olympic games?


select count(distinct games),region from olympics_history oh join noc_details nd on oh.noc=nd.noc 
		group by region having count(distinct games)=(select count(distinct games) from olympics_history)
		
-- 6.Identify the sport which was played in all summer olympics.
select * from olympics_history
select count(distinct games) from olympics_history where games like '%Summer%'

select count(distinct games),sport from olympics_history group by sport 
		having count(distinct games)=(select count(distinct games) from olympics_history where games like '%Summer%')

-- 7.Which Sports were just played only once in the olympics?

select count(distinct games),sport from olympics_history group by sport 
		having count(distinct games)=1

-- 8.Fetch the total no of sports played in each olympic games.
select count(distinct sport) as no_sports, games from olympics_history group by games

-- 9.Fetch details of the oldest athletes to win a gold medal.
select * from (
select *,dense_rank() over(order by age desc) rnk from olympics_history  where medal='Gold' and age !='NA' order by age desc
			) t1 where rnk=1
			
-- 10.Find the Ratio of male and female athletes participated in all olympic games.
select  t1.games,round(no_males/no_females,2) as male_female_ratio from
(select count(sex) no_males, games from olympics_history where sex='M' group by games) t1
join 
(select count(sex) no_females, games from olympics_history where sex='F' group by games) t2
on t1.games=t2.games

select
round(((select count(sex) no_males from olympics_history where sex='M' )/
(select count(sex) no_females from olympics_history where sex='F' )),2) as ratio

-- 11.Fetch the top 5 athletes who have won the most gold medals.

select count(1),name from olympics_history where medal='Gold' group by name order by count(1) desc limit 5

with golds as (select name,team,count(1),row_number() over(order by count(1) desc) rn from olympics_history
												where medal='Gold' group by name,team order by count(1) desc)
				select * from golds where rn<6

-- 12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select name,team,count(1) from olympics_history where medal<>'NA' group by name,team order by count(1) desc limit 5

-- 13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select team,count(1) from olympics_history where medal<>'NA' group by team order by count(1) desc limit 5

-- 14.List down total gold, silver and broze medals won by each country.

select team,medal,count(1) from olympics_history where medal<>'NA' group by team,medal order by count(1) desc

select nd.region,sum(case when medal='Gold' then 1 else 0 end) Gold,
			  sum(case when medal='Silver' then 1 else 0 end) Silver,
			  sum(case when medal='Bronze' then 1 else 0 end) Bronze 
			  from noc_details nd join olympics_history oh on oh.noc=nd.noc group by nd.region order by Gold desc
			  
-- 15.List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select nd.region,oh.games,sum(case when medal='Gold' then 1 else 0 end) Gold,
			  sum(case when medal='Silver' then 1 else 0 end) Silver,
			  sum(case when medal='Bronze' then 1 else 0 end) Bronze 
			  from noc_details nd join olympics_history oh on oh.noc=nd.noc 
			  group by nd.region,oh.games order by games,Gold desc

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc),
	 most_medals as 
(
select games,
concat(first_value(region) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Gold' then 1 else 0 end)) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc)) Gold,
concat(first_value(region) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Silver' then 1 else 0 end)) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc)
) Silver,concat(first_value(region) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Bronze' then 1 else 0 end)) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc) ) Bronze, 
	row_number() over(partition by games) rn from all_data GROUP BY games,region
)
select * from most_medals where rn=1

-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc),
	 most_medals as 
(
select games,
concat(first_value(region) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Gold' then 1 else 0 end)) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc)) Gold,
concat(first_value(region) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Silver' then 1 else 0 end)) over(partition by games order by sum(case when medal='Silver' then 1 else 0 end) desc)
) Silver,concat(first_value(region) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='Bronze' then 1 else 0 end)) over(partition by games order by sum(case when medal='Bronze' then 1 else 0 end) desc) ) Bronze,
concat(first_value(region) over(partition by games order by sum(case when medal='Gold' then 1 else 0 end) desc),'-',
	first_value(sum(case when medal='NA' then 0 else 1 end)) over(partition by games order by sum(case when medal='NA' then 0 else 1 end) desc)) total_medals,
	row_number() over(partition by games) rn from all_data GROUP BY games,region
)
select * from most_medals where rn=1

-- 18.Which countries have never won gold medal but have won silver/bronze medals?

select ngm.* from
(select region,sum(g_medals) from (with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc)
	select region,medal,(case when medal='Gold' then 1 else 0 end) g_medals from all_data
		) t1 group by region  having sum(g_medals)>=1 order by sum(g_medals) desc) gm
right join
(select region,sum(ng_medals) from (with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc)
	select region,medal,(case when medal='Silver' then 1 when medal='Bronze' then 1 else 0 end) ng_medals from all_data
		where medal!='Gold') t1 group by region  having sum(ng_medals)>=1 order by sum(ng_medals) desc) ngm
on gm.region=ngm.region
where gm.region isnull

-- 19.In which Sport/event, India has won highest medals.
with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc)
select sport,count(medal) medal_count from all_data where region='India' and medal!='NA' group by sport order by medal_count desc

-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

with all_data as (select oh.*,nd.region from olympics_history oh join noc_details nd on oh.noc=nd.noc)
select games,count(medal) medal_count from all_data where region='India' and medal!='NA' and sport='Hockey' group by games order by medal_count desc



