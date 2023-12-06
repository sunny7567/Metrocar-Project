
-- Using the percent of previous approach, what are the user-level conversion rates for the first 3 stages of the funnel (app download to signup and signup to ride requested)?

SELECT COUNT( DISTINCT app_download_key) as user_download,
       COUNT( DISTINCT s.user_id) as user_signup,
       COUNT( DISTINCT r.user_id) as user_riderequest
FROM app_downloads as a
LEFT JOIN signups as s
ON a.app_download_key = s.session_id
LEFT JOIN ride_requests as r
USING (user_id) 

SELECT 1/1.0 * user_signup / user_download as singup,
        1/1.0 * user_riderequest / user_signup as request
FROM t1


-- Using the percent of top approach, what are the user-level conversion rates for the first 3 stages of the funnel (app download to signup and signup to ride requested)?

WITH t1 AS (SELECT COUNT( DISTINCT app_download_key) as user_download,
       COUNT( DISTINCT s.user_id) as user_signup,
       COUNT( DISTINCT r.user_id) as user_riderequest
FROM app_downloads as a
LEFT JOIN signups as s
ON a.app_download_key = s.session_id
LEFT JOIN ride_requests as r
USING (user_id) )

SELECT 1/1.0 * user_signup / user_download as singup,
        1/1.0 * user_riderequest / user_download as request
FROM t1

-- Using the percent of previous approach, what are the user-level conversion rates for the following 3 stages of the funnel? 1. signup, 2. ride requested, 3. ride completed
WITH t1 AS (SELECT COUNT( DISTINCT CASE WHEN dropoff_ts IS NOT NULL THEN user_id END ) as user_complted,
       COUNT( DISTINCT s.user_id) as user_signup,
       COUNT( DISTINCT r.user_id) as user_riderequest
FROM app_downloads as a
LEFT JOIN signups as s
ON a.app_download_key = s.session_id
LEFT JOIN ride_requests as r
USING (user_id) )

SELECT 1/1.0 * user_riderequest / user_signup as singup,
        1/1.0 * user_complted / user_riderequest as request
FROM t1

-- Using the percent of top approach, what are the user-level conversion rates for the following 3 stages of the funnel? 1. signup, 2. ride requested, 3. ride completed (hint: signup is the top of this funnel)

WITH t1 AS (SELECT COUNT( DISTINCT CASE WHEN dropoff_ts IS NOT NULL THEN user_id END ) as user_complted,
       COUNT( DISTINCT s.user_id) as user_signup,
       COUNT( DISTINCT r.user_id) as user_riderequest
FROM app_downloads as a
LEFT JOIN signups as s
ON a.app_download_key = s.session_id
LEFT JOIN ride_requests as r
USING (user_id) )

SELECT 1/1.0 * user_riderequest / user_signup as singup,
        1/1.0 * user_complted / user_signup as request
FROM t1


Q) How many times was the app downloaded?
Select count(*)
FROM app_downloads;

Q) How many users signed up on the app? This question is required.
SELECT count(*)
FROM signups;

Q) How many rides were requested through the app?
SELECT count(*)
FROM ride_requests;

Q) How many rides were requested and completed through the app?**
SELECT count(user_id) AS tr, count (case when dropoff_ts IS NOT NULL THEN ride_id END) 
FROM ride_requests 

Q) How many rides were requested and how many unique users requested a ride?**
SELECT count(*) as ride, count(DISTINCT user_id) as uni
FROM ride_requests;

Q)What is the average time of a ride from pick up to drop off?
SELECT AVG (pickup_ts - dropoff_ts) as dif
FROM ride_requests; 

Q) How many rides were accepted by a driver?
SELECT count(driver_id)
FROM ride_requests;

Q) How many rides did we successfully collect payments and how much was collected?
SELECT count(purchase_amount_usd), SUM(purchase_amount_usd)
FROM transactions
WHERE charge_status = 'Approved';

Q) How many ride requests happened on each platform?This question is required.****
SELECT platform, Count(*)
FROM app_downloads as a
INNER JOIN signups as s
ON a.app_download_key = s.session_id
INNER JOIN ride_requests as r 
using (user_id)
group by 1;

Q) What is the drop-off from users signing up to users requesting a ride?
SELECT  1 -  1.0 * count(distinct r.user_id) /count(distinct s.user_id)   
FROM signups as s
LEFT JOIN ride_requests as r
USING(user_id)
INNER JOIN transactions as t 
USING (ride_id)


-- How many unique users requested a ride through the Metrocar app?
SELECT COUNT ( DISTINCT user_id)
FROM ride_requests

-- How many unique users completed a ride through the Metrocar app?
SELECT COUNT( DISTINCT CASE WHEN dropoff_ts IS NOT NULL THEN user_id END )
FROM ride_requests

-- Of the users that signed up on the app, what percentage these users requested a ride?
SELECT 1/1.0 * COUNT(DISTINCT r.user_id ) / COUNT(DISTINCT s.user_id) 
FROM signups as s
LEFT JOIN ride_requests as r
USING (user_id)

-- Of the users that signed up on the app, what percentage these users completed a ride?
 SELECT 1/1.0 * COUNT( DISTINCT CASE WHEN dropoff_ts IS NOT NULL THEN user_id END )  / COUNT(DISTINCT s.user_id ) 
FROM signups as s
LEFT JOIN ride_requests as r
USING (user_id)

