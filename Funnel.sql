** Still work on it. 



WITH user_ride_status AS (
SELECT user_id,
       ride_id
FROM ride_requests
GROUP BY user_id,ride_id
),
totals AS (
SELECT COUNT(*) AS total_users_signed_up,
       COUNT(DISTINCT urs.user_id) AS total_users_ride_requested,
       COUNT(DISTINCT urs.ride_id) as total_ride_request
FROM signups s
LEFT JOIN user_ride_status urs ON
s.user_id = urs.user_id
),

app_download AS(
SELECT COUNT(*) AS total_downloads  --COUNT(Distinct ride_id) AS ride_count 
FROM app_downloads),

rides_accepted AS(
SELECT COUNT(Distinct user_id) AS ri_accepted , 
       COUNT(Distinct ride_id) AS ride_count
FROM ride_requests
where accept_ts IS NOT NULL),

user_ride AS (
SELECT user_id,  
       count (case when dropoff_ts IS NOT NULL THEN ride_id END) AS ride_fi
FROM ride_requests
GROUP BY user_id
),

user_ride_completed as (
  SELECT user_id,  
       count (case when dropoff_ts IS NOT NULL THEN user_id END) AS user_fi
FROM ride_requests
GROUP BY user_id
),
-- user_ride as ( 
-- select ride_requests.ride_id, 
--        count(CASE WHEN dropoff_ts IS NOT NULL THEN ride_requests.ride_id  END) AS ride_finish, 
--        ride_requests.user_id , 
--        SUM(ride_com) as t1
-- FROM ride_requests 
-- LEFT JOIN  user_ride_completed
-- ON user_ride_completed.user_id = ride_requests.user_id
-- GROUP BY ride_requests.ride_id, ride_requests.user_id
--   ),
  
--   user_ride_completed as (
--   select user_id, sum(ride_completed)  as ride_completed
--   from (
--     select 
--       ride_id, 
--       MAX(CASE WHEN dropoff_ts IS NOT NULL THEN 1 ELSE 0 END) AS ride_completed
--       , user_id
--     FROM ride_requests
--     GROUP BY ride_id, user_id
--     ) as a
--   group by user_id
-- ),
  
-- user_ride_completed2 AS (
-- SELECT
-- user_id,  ride_id 
-- FROM ride_requests
-- GROUP BY user_id, ride_id
-- ),

  
payment_received AS(
Select count(Distinct r.user_id) AS user_payment , 
       count(Distinct r.ride_id) AS ride_count 
from ride_requests as r
left join transactions as t
on r.ride_id = t.ride_id
where charge_status = 'Approved'
),

review_data AS (
Select count(Distinct user_id) AS total_review, 
       count(Distinct ride_id) as ride_count
from reviews
),

funnel_stages AS (

SELECT 1 AS funnel_step,
       'app_download' AS funnel_name,
       total_downloads AS user_count,
       0 AS r1
FROM app_download

Union

SELECT 2 AS funnel_step,
       'signups' AS funnel_name,
       total_users_signed_up AS user_count,
       0 AS r1
FROM totals

UNION

SELECT 3 AS funnel_step,
       'ride_requested' AS funnel_name,
       total_users_ride_requested AS user_count,
       total_ride_request as r1
FROM totals

UNION
 
SELECT 4 AS funnel_step,
       'ride_accepted' AS funnel_name,
       ri_accepted AS user_count,
       ride_count as r1
FROM
rides_accepted

UNION

SELECT 5 AS funnel_step,
       'ride_completed' AS funnel_name,
       user_fi As user_count,
       ride_fi as r1
FROM user_ride_completed
Left JOIN user_ride
ON user_ride.user_id = user_ride_completed.user_id


UNION

SELECT 6 AS funnel_step,
       'payment' AS funnel_name,
        user_payment AS user_count,
        ride_count as r1
FROM payment_received

UNION

SELECT 7 AS funnel_step,
       'reviews' AS funnel_name,
       total_review AS user_count,
       ride_count as r1
FROM review_data
)
SELECT *
FROM funnel_stages
ORDER BY funnel_step;
