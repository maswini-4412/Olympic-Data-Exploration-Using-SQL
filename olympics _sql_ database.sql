create database olympics;
drop table if exists athlete_events;
create table athlete_events
(
ID int,
Name varchar(255),
Sex varchar(255),
Age varchar(255),
Height varchar(255),
Weight varchar(255),
Team varchar(255),
NOC varchar(255),
Games varchar(255),
Year varchar(255),
Season varchar(255),
City varchar(255),
Sport varchar(255),
Event varchar(255),
Medal varchar(255)
);

use olympics;

select* from athlete_events;

drop table if exists noc_regions;
create table if not exists noc_regions(
NOC varchar(255),
region varchar(255),
notes varchar(255)
);

select* from noc_regions;

# 1. How many olmypics games have been held?
select count(Sport) as total_games from athlete_events;
select distinct(count(Sport)) as total_games from athlete_events;


# 2. Listdown all olmypics games held so far?
select distinct(Sport) as sports_name from athlete_events;

# 3. Mention the total no.of nations who participated in each olypic game?

select Name,count(Team) as total_parti from athlete_events
group by Name
order by  total_parti desc;

# 4. which year saw the highest and lowest no.of countries participating in olmypics?

(select NOC ,Year,count(Team) as nation_tot from athlete_events
group by NOC,year
order by count(Team) desc limit 1)
union
(select NOC ,Year,count(Team) as nation_tot from athlete_events
group by NOC,year
order by count(Team) asc limit 1);


# 5. which of the  nation has participated in all of the olympics games?

with cte1 as
(
select distinct(n.region) as region,a.NOC,count(a.NOC) as noc_count from athlete_events a
join noc_regions n on n.NOC=a.NOC 
group by n.region,a.NOC
),
cte2 as
(
select count(distinct(Games)) as total from athlete_events
) select 
cte1.region as country,cte1.NOC,cte1.noc_count,cte2.total,
 case when cte1.noc_count>=cte2.total then "higest participation"
 else "0" end as final 
 from cte1 cross join cte2;


# 6. identify the sport which was played in all summer olympics? 
with cte1 as
(
select distinct(sport) sport,count(distinct Games) as total from athlete_events where Season='Summer'
group by sport
),
cte2 as
( 
select count(distinct Games) as ovear_all from athlete_events where Season='Summer'
)
select cte1.sport,cte1.total from cte1
cross join cte2 on cte1.total =cte2.ovear_all;

# 7. which sports just were played only once in the olympics?

select * from
(select distinct(sport) sport,count(Games) as cnt from athlete_events
group by sport ) a where cnt=1;

# 8. fetch the total no.of sports played in each olympics games played?

select distinct(Games),count(distinct sport) as sport from athlete_events
group by Games
order by sport desc;

# 9. fetch details of the odlest atheletsto win a gold medal list?

SELECT ID, Name,Sex,Age,Team,Games,Year,Sport 
FROM athlete_events 
WHERE Medal = 'Gold' and Age!='NA'
group by ID, Name,Sex,age,Team,Games,Year,Sport
order by age desc limit 1;

# 10. find the ratio of the male & female atheletes participated in all olympics games?

  SELECT 
    COUNT(CASE WHEN a1.Sex = 'M' THEN 1 END) AS male,
    COUNT(CASE WHEN a1.Sex = 'F' THEN 1 END) AS female,
    ROUND(COUNT(CASE WHEN a1.Sex = 'M' THEN 1 END) / COUNT(CASE WHEN a1.Sex = 'F' THEN 1 END),2) AS ratio
FROM (
    SELECT ID, Sex, COUNT(DISTINCT Games) AS cnt 
    FROM athlete_events
    GROUP BY ID, Sex
    HAVING cnt >= (SELECT COUNT(DISTINCT Games) FROM athlete_events)
) AS a1;

# 11. Fetch the top 5 athletes who have won the most gold medals?

with cte1 as (
select x.ID,x.Name,x.Sex,x.total, dense_rank() over(order by total desc) as rnk
 from
(
select ID,Name,Sex,sum(Medal is not null) as total from athlete_events
group by ID,Name,Sex
order by total desc
) x
) select * from cte1
where rnk in (1,2,3,4,5);  


# 12. Fetch the top 1 athletes who have won the most medals?like (gold/silver/bronze)


with cte1 as (
select a.*, dense_rank() over(order by cnt desc) rnk from
(select ID,Name,Medal,count(Medal) as cnt from athlete_events where Medal='Gold'
group by  ID,Name,Medal)a
),
cte2 as(
select a1.*, dense_rank() over(order by cnt desc) rnk from
(select ID,Name,Medal,count(Medal) as cnt from athlete_events where Medal='silver'
group by  ID,Name,Medal)a1
),
cte3 as(
select a2.*, dense_rank() over(order by cnt desc) rnk from
(select ID,Name,Medal,count(Medal) as cnt from athlete_events where Medal='bronze'
group by  ID,Name,Medal)a2
),
 cte4 as ( 
 select* from cte1
 union all
 select*from cte2
 union all
 select* from cte3
 ) select * from cte4 where rnk=1;


# 13. fetch the top 5 most successfull countries in olympics. success defined by no.of medals won.

select a.* ,rank() over(order by a.total_medals desc) rnk from
(
 select region as country,count(Medal) as total_medals from noc_regions as nr
 inner join athlete_events ae on ae.NOC=nr.NOC
 group by region)a 
 limit 5;


# 14. list down the total gold,silver and bronze won by the each country?


select a.country,a.Medal,total_medals,rank() over(partition by country order by a.total_medals desc) rnk from
(
 select region as country,Medal,count(Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where Medal!='NA'
 group by region,Medal
 )a;


# 15. list down total gold,silver and bronze medals won by each country corresponding to each olympic games.

select a.country,a. sport,a.Medal,total_medals,rank() over(partition by country order by a.total_medals desc) rnk from
(
 select region as country,Games as sport ,Medal,count(Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where Medal!='NA'
 group by region,Medal,Games
 )a;

# 16. identify which country won by the most gold,most silver and most bronze ,models in each olympic games

(with cte1 as (
select a.country,a. sport,a.Medal,total_medals,rank() over(partition by country order by a.total_medals desc) rnk from
(
 select region as country,Games as sport ,Medal,count(Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where Medal!='NA'
 group by region,Medal,Games
 )a
 ) select * from cte1 where Medal='Gold'
 order by total_medals desc limit 1)
 
 union
 (with cte1 as (
select a.country,a. sport,a.Medal,total_medals,rank() over(partition by country order by a.total_medals desc) rnk from
(
 select region as country,Games as sport ,Medal,count(Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where Medal!='NA'
 group by region,Medal,Games
 )a
 ) select * from cte1 where Medal='Silver'
 order by total_medals desc limit 1)
 
 union
 
 (with cte1 as (
select a.country,a. sport,a.Medal,total_medals,rank() over(partition by country order by a.total_medals desc) rnk from
(
 select region as country,Games as sport ,Medal,count(Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where Medal!='NA'
 group by region,Medal,Games
 )a
 ) select * from cte1 where Medal='Bronze'
 order by total_medals desc limit 1);
 
 


# 17.which country have never won gold medal and but have won silver/bronze medels?

with cte1 as (
select region as country,Games as sport ,ae.Medal,count(ae.Medal) as total_medals from noc_regions as nr 
 inner join athlete_events ae on ae.NOC=nr.NOC
 where ae.Medal in('Silver','Bronze') 
 group by region,Medal,Games
 ),
cte2 AS (
    SELECT nr.region AS country
    FROM noc_regions nr
    WHERE NOT EXISTS (
        SELECT 1
        FROM athlete_events ae
        WHERE ae.NOC = nr.NOC AND ae.Medal = 'Gold'
)  
group by region
) 
select cte2.country,cte1.sport,cte1.total_medals from cte2 
inner join cte1 on cte2.country=cte1.country;



# 18. in which sport india has won highest medals?

select Name,sport,nr.region as country ,count(ae.Medal) as total from athlete_events ae 
inner join noc_regions nr on nr.NOC=ae.NOC where region='India'
group by Name,sport,nr.region
order by  total desc limit 1;




# 19. Break down all olympic games where india won medal for hockey and how many medals in each olympic games. 

select y.*,rank() over(order by x.total_medals desc) as rnk from
(
select x.* from
(
select Games,Sport,count(Medal) as total_medals from athlete_events as ae
inner join noc_regions r  on r.NOC=ae.NOC
group by Games,Sport
)x
where x.Sport='Hockey'
) y;










