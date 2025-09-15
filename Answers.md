# Ottawa Traffic Crashes 2017-2022
## Questions and Answers

An SQL analysis about each traffic crash on city streets within the City of Ottawa. 

#### What is the total number of collisions?
```sql
SELECT
	count(*) AS total_collisions
FROM
	collisions;
```

total_records|
-------------|
74612|

#### What is the earliest and latest date of recorded crashes?
```sql
SELECT 
	min(accident_date) AS earliest_date,
	max(accident_date) AS latest_date
FROM	
	collisions
```

earliest_date|latest_date|
-------------|-----------|
2017-01-01|	2022-12-30|


#### What is the number of reported crashes per year?
```sql
SELECT
	accident_year,
	count(*) AS accident_year
FROM
	collisions
GROUP BY
	accident_year
ORDER BY 
	accident_year;
```

accident_year|accident_year|
-------------|-------------|
2017|	14399|
2018|	14530|
2019|	16437|
2020|	10049|
2021|	9696|
2022|	9501|

#### What are the different types of lighting conditions and the number of crashes?
answered
```sql
SELECT
	DISTINCT light,
	count(*) AS collision_count
FROM
	collisions
GROUP BY
	light
ORDER BY
	collision_count desc;
```

light|collision_count|
-----|---------------|
01 - Daylight|	49858|
07 - Dark|	16805|
05 - Dusk|	3445|
00 - Unknown|	2691|
03 - Dawn|	1803|
99 - Other|	10|

#### What are the different kinds of road conditions and the number of crashes?
```sql
SELECT
    DISTINCT road_surface_condition,
    COUNT(*) AS crash_count
FROM
    collisions
WHERE
    road_surface_condition IS NOT NULL
    AND TRIM(road_surface_condition) <> ''
GROUP BY
    road_surface_condition
ORDER BY
    crash_count DESC;
```

| Road Surface Condition    | Crash Count |
| ------------------------- | ----------- |
| 01 - Dry                  | 49,509      |
| 02 - Wet                  | 12,711      |
| 03 - Loose snow           | 4,559       |
| 06 - Ice                  | 3,031       |
| 04 - Slush                | 2,608       |
| 05 - Packed snow          | 2,039       |
| 08 - Loose sand or gravel | 63          |
| 99 - Other                | 36          |
| 07 - Mud                  | 10          |
| 09 - Spilled liquid       | 7           |



#### What are the top 5 Crash Types?
```sql
WITH get_collision_type AS (    
	SELECT
		Initial_Impact_Type,
		count(*) AS collision_count,
		RANK() OVER (ORDER BY count(*) desc) AS rnk
	FROM
		collisions
	GROUP BY
		Initial_Impact_Type
)
SELECT
	Initial_Impact_Type AS collision_type,
	collision_count
FROM
	get_collision_type
WHERE
	rnk <= 5;
```

Collision_type           |collision_count|
-------------------------|---------------|
03 - Rear end  |	24776|
07 - SMV other |	11885|
04 - Sideswipe |	10573|
02 - Angle |	10469|
05 - Turning movement |	7754|


#### What is the frequency of crashes relative to the time of day?
```sql
WITH most_dangerous_hour AS (
    SELECT
        EXTRACT(HOUR FROM Accident_Time)::int AS collision_hour,
        COUNT(*) AS hour_count
    FROM
        collisions
	WHERE
        Accident_Time IS NOT NULL
    GROUP BY
        collision_hour
    ORDER BY
        collision_hour ASC
)
SELECT
    to_char(to_timestamp(collision_hour::text, 'HH24'), 'HH AM') AS hour_of_day,
    hour_count,
    ROUND(100 * ((hour_count * 1.0) / (SELECT COUNT(*) FROM collisions)), 1) AS avg_of_total,
    ROUND(100 * (hour_count - LAG(hour_count) OVER ()) / LAG(hour_count) OVER()::NUMERIC, 2) AS hour_to_hour
FROM
    most_dangerous_hour;
```

hour_of_day|hour_count|avg_of_total|hour_to_hour|
-----------|----------|------------|------------|
12 AM|	713|	1.0|	
01 AM|	621|	0.8|	-12.90|
02 AM|	516|	0.7|	-16.91|
03 AM|	423|	0.6|	-18.02|
04 AM|	392|	0.5|	-7.33|
05 AM|	639|	0.9|	63.01|
06 AM|	2002|	2.7|	213.30|
07 AM|	3307|	4.4|	65.18|
08 AM|	4275|	5.7|	29.27|
09 AM|	3800|	5.1|	-11.11|
10 AM|	3343|	4.5|	-12.03|
11 AM|	3870|	5.2|	15.76|
12 PM|	4430|	5.9|	14.47|
01 PM|	4244|	5.7|	-4.20|
02 PM|	5032|	6.7|	18.57|
03 PM|	6299|	8.4|	25.18|
04 PM|	6668|	8.9|	5.86|
05 PM|	6321|	8.5|	-5.20|
06 PM|	4293|	5.8|	-32.08|
07 PM|	3136|	4.2|	-26.95|
08 PM|	2445|	3.3|	-22.03|
09 PM|	2204|	3.0|	-9.86|
10 PM|	1653|	2.2|	-25.00|
11 PM|	1229|	1.6|	-25.65|


#### What are the top 10 streets have the most collisions?
```sql
WITH streets AS (
    SELECT
        TRIM(unnest(
            regexp_split_to_array(
                regexp_replace(Location, '\(.*\)', ''),       
                '\s(@|btwn|&)\s'                                
            )
        )) AS street_name
    FROM collisions
)
SELECT
    street_name,
    COUNT(*) AS collision_count
FROM streets
GROUP BY street_name
ORDER BY collision_count DESC
LIMIT 10; 
```

stree_name|collision_count|
----------|---------------|
HIGHWAY 417|	7173|
BANK ST|	3501|
INNES RD|	2111|
WOODROFFE AVE|	2094|
CARLING AVE|	2002|
MERIVALE RD|	1860|
ST. LAURENT BLVD|	1836|
HUNT CLUB RD|	1699|
RIVERSIDE DR|	1523|
PRINCE OF WALES DR|	1521|


#### What are the top 10 deadliest streets?
```sql
WITH streets AS (
    SELECT
        TRIM(unnest(
            regexp_split_to_array(
                regexp_replace(Location, '\(.*\)', ''),       
                '\s(@|btwn|&)\s'                                
            )
        )) AS street_name
    FROM collisions
    WHERE Num_of_Fatal_Injuries IS NOT NULL
)
SELECT
    street_name,
    COUNT(*) AS fatality_count
FROM streets
GROUP BY street_name
ORDER BY fatality_count DESC
LIMIT 10; 
```

stree_name|fatality_count|
----------|--------------|
HIGHWAY 417|	15|
MERIVALE RD|	6|
BASELINE RD|	5|
UPPER DWYER HILL RD|	4|
WEST HUNT CLUB RD|	4|
MOODIE DR|	4|
CARLING AVE|	4|
MITCH OWENS RD|	4|
INNES RD|	3|
BANK ST|	3|


#### What was the ranking of the deadliest years in our recordset?
```sql
SELECT
    accident_year,
    COUNT(*) AS fatality_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS year_rank
FROM
    collisions
WHERE
    Num_of_Fatal_Injuries IS NOT NULL
GROUP BY
    accident_year
ORDER BY
    fatality_count DESC;
```

accident_year|fatality_count|year_rank|
-------------|--------------|---------|
2017|	28|	1|
2018|	26|	2|
2019|	25|	3|
2021|	24|	4|
2022|	20|	5|
2020|	18|	6|

#### What month has the most amount of fatal crashes?
```sql
SELECT
    TO_CHAR(TO_DATE(EXTRACT(MONTH FROM accident_date)::TEXT, 'MM'), 'Month') AS collision_month,
    COUNT(*) AS fatality_count
FROM
    collisions
WHERE
    Num_of_Fatal_Injuries <> 0
GROUP BY
    EXTRACT(MONTH FROM accident_date)
ORDER BY
    fatality_count DESC;
```

collision_month|fatality_count|
---------------|--------------|
July     |	23|
September|	17|
August   |	15|
June     |	12|
December |	11|
January  |	11|
February |	10|
May      |	10|
April    |	9|
March    |	9|
October  |	8|
November |	6|


#### What single day has the most amount of fatal crashes?
```sql
SELECT
    accident_date::date AS collision_day,
    SUM(Num_of_Fatal_Injuries) AS total_fatalities,
    DENSE_RANK() OVER (ORDER BY SUM(Num_of_Fatal_Injuries) DESC) AS date_rank
FROM
    collisions
WHERE
    Num_of_Fatal_Injuries IS NOT NULL
GROUP BY
    accident_date::date
ORDER BY
    total_fatalities DESC
LIMIT 10;
```

collision_day|total_fatalities|date_rank|
-------------|----------------|---------|
2019-01-11|	3|	1|
2018-02-09|	3|	1|
2017-04-15|	2|	2|
2022-02-26|	2|	2|
2020-07-05|	2|	2|
2017-06-18|	2|	2|
2017-09-07|	2|	2|
2018-04-02|	2|	2|
2021-03-11|	2|	2|
2017-02-14|	2|	2|