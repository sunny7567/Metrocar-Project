Q.1) How many times was the app downloaded?
Select count(*)
FROM app_downloads;

Q.2) How many users signed up on the app? This question is required.
SELECT count(*)
FROM signups;

Q.3) How many rides were requested through the app?
SELECT count(*)
FROM ride_requests;

Q.4) How many rides were requested and completed through the app?**
SELECT count(user_id) AS tr, count (case when dropoff_ts IS NOT NULL THEN ride_id END) 
FROM ride_requests 

Q.5) How many rides were requested and how many unique users requested a ride?**
SELECT count(*) as ride, count(DISTINCT user_id) as uni
FROM ride_requests;

Q.6 )What is the average time of a ride from pick up to drop off?
SELECT AVG (pickup_ts - dropoff_ts) as dif
FROM ride_requests; 

Q.7) How many rides were accepted by a driver?
SELECT count(driver_id)
FROM ride_requests;

Q.8) How many rides did we successfully collect payments and how much was collected?
SELECT count(purchase_amount_usd), SUM(purchase_amount_usd)
FROM transactions
WHERE charge_status = 'Approved';

Q.9) How many ride requests happened on each platform?This question is required.****
SELECT platform, Count(*)
FROM app_downloads as a
INNER JOIN signups as s
ON a.app_download_key = s.session_id
INNER JOIN ride_requests as r 
using (user_id)
group by 1;

Q.10) What is the drop-off from users signing up to users requesting a ride?
SELECT  1 -  1.0 * count(distinct r.user_id) /count(distinct s.user_id)   
FROM signups as s
LEFT JOIN ride_requests as r
USING(user_id)
INNER JOIN transactions as t 
USING (ride_id)
