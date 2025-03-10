drop table if exists analytics_scratch.sashank_listings_published_volume_per_lister;

-- listings_published_volume_per_lister_mobile
create table analytics_scratch.sashank_listings_published_volume_per_lister as
select DATE(dw_listings.first_published_at) AS first_published_date,
       dw_listings.seller_id as seller_id,
       lister.home_domain,
       (case when dw_listings.quick_list_type = 'show' THEN 'Quick Listing'
            WHEN dw_listings_cs.listing_method = 'pm_resell' THEN 'PM Resell'
            WHEN dw_listings_cs.clone_type IS NULL THEN 'Manually Created Listing'
            WHEN dw_listings_cs.clone_type = 'self_listing_clone' THEN 'Clone'
            WHEN dw_listings_cs.clone_type = 'relist' THEN 'Reposh'
            ELSE INITCAP(REPLACE(dw_listings_cs.clone_type,'_',' ')) END) as listing_creation_method,
       dw_listings_new_manual_relist_flag.is_manual_relist as is_manual_relist,
       COUNT(DISTINCT CASE
              WHEN dw_listings.parent_listing_id IS NULL THEN dw_listings.listing_id
              ELSE null END) AS count_listings
from analytics.dw_listings dw_listings
LEFT JOIN analytics.dw_users AS lister
     ON dw_listings.seller_id = lister.user_id
LEFT JOIN analytics_scratch.dw_listings_new_manual_relist_flag  AS dw_listings_new_manual_relist_flag
     ON dw_listings.listing_id = dw_listings_new_manual_relist_flag.listing_id
LEFT JOIN analytics.dw_listings_cs  AS dw_listings_cs
     ON dw_listings.listing_id = dw_listings_cs.listing_id
where
    dw_listings.is_valid_listing = TRUE
    AND DATE(dw_listings.first_published_at) >= DATEADD(MONTH, -7, DATE_TRUNC('MONTH', CURRENT_DATE))
    AND DATE(dw_listings.first_published_at) < DATE_TRUNC('MONTH', CURRENT_DATE) -- completed 6 months
    AND (
        NOT COALESCE(
            (DATEDIFF(day, COALESCE(lister.guest_joined_at, lister.joined_at),
            CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END) + 1) <= 30,
            FALSE
        )
        OR COALESCE(
            (DATEDIFF(day, COALESCE(lister.guest_joined_at, lister.joined_at),
            CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END) + 1) <= 30,
            FALSE
        ) IS NULL
        ) -- d30
    AND (
        NOT COALESCE(lister.user_status = 'restricted', FALSE)
        OR COALESCE(lister.user_status = 'restricted', FALSE) IS NULL
        ) -- restricted
    AND ( CASE
          WHEN dw_listings.app in ('iphone','ipad')  THEN 'iOS'
          WHEN dw_listings.app = 'android'  THEN 'Android'
          WHEN dw_listings.app = 'web'  THEN 'Web'
          ELSE 'Other'
          END ) IN('iOS','Android','Other') -- app type

GROUP BY
    DATE(dw_listings.first_published_at),
    dw_listings.seller_id,
    lister.home_domain,
    (CASE
        WHEN dw_listings.quick_list_type = 'show' THEN 'Quick Listing'
        WHEN dw_listings_cs.listing_method = 'pm_resell' THEN 'PM Resell'
        WHEN dw_listings_cs.clone_type IS NULL THEN 'Manually Created Listing'
        WHEN dw_listings_cs.clone_type = 'self_listing_clone' THEN 'Clone'
        WHEN dw_listings_cs.clone_type = 'relist' THEN 'Reposh'
        ELSE INITCAP(REPLACE(dw_listings_cs.clone_type,'_',' '))
    END),
    dw_listings_new_manual_relist_flag.is_manual_relist;

------------------------------------------------------------------------------------------------------------------------
------ max in mobile fresh users
    select max(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;

------ min in mobile fresh users
    select min(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;

-- mobile fresh users
select first_published_date,count_listings,count(distinct seller_id) count_seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by first_published_date, count_listings
order by first_published_date desc, count_listings desc ;
---------- outliers
WITH "mob_data" as
    (select distinct first_published_date,count_listings, seller_id
from analytics_scratch.sashank_listings_published_volume_per_listerU
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
order by first_published_date desc, count_listings desc),
    Percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY count_listings) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY count_listings) AS Q3
    FROM mob_data
)
SELECT (p.Q3 - p.Q1) AS IQR,(p.Q1 - 1.5 * (p.Q3 - p.Q1)) as lower_limit, (p.Q3 + 1.5 * (p.Q3 - p.Q1)) as upper_limit  from Percentiles p;
-- mobile fresh listings
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and count_listings between 1 and 9
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc;
-- total listers
select sum(total_listers)from(
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc)m;

------------------------------------------------------------------------------------------------------------------------
-- mobile fresh listings
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and count_listings between 1 and 9
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc;
-- total listers
select sum(total_listers)from(
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'No'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc)m;

------------------------------------------------------------------------------------------------------------------------
-- mobile Manually relists
select first_published_date,count_listings,count(distinct seller_id) count_seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by first_published_date, count_listings
order by count_listings desc ;

------ max in mobile Manually relists
    select max(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;

------ min in mobile Manually relists
    select min(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;
---------- outliers
WITH "mob_data" as
    (select distinct first_published_date,count_listings, seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
order by first_published_date desc, count_listings desc),
    Percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY count_listings) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY count_listings) AS Q3
    FROM mob_data
)
SELECT (p.Q3 - p.Q1) AS IQR,(p.Q1 - 1.5 * (p.Q3 - p.Q1)) as lower_limit, (p.Q3 + 1.5 * (p.Q3 - p.Q1)) as upper_limit  from Percentiles p;
------------------------------------------------------------------------------------------------------------------------
-- total listers
select sum(total_listers)from(
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc)m;

-- mobile Manually relists
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Manually Created Listing' and is_manual_relist = 'Yes'and count_listings>0
and count_listings between 1 and 11
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc;

------------------------------------------------------------------------------------------------------------------------
-- mobile clone listers
select first_published_date,count_listings,count(distinct seller_id) count_seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Clone' and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by first_published_date, count_listings
order by count_listings desc ;

------ max in mobile Manually relists
    select max(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Clone' and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;

------ min in mobile Manually relists
    select min(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method = 'Clone' and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;
---------- outliers
WITH "mob_data" as
    (select distinct first_published_date,count_listings, seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Clone' and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
order by first_published_date desc, count_listings desc),
    Percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY count_listings) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY count_listings) AS Q3
    FROM mob_data
)
SELECT (p.Q3 - p.Q1) AS IQR,(p.Q1 - 1.5 * (p.Q3 - p.Q1)) as lower_limit, (p.Q3 + 1.5 * (p.Q3 - p.Q1)) as upper_limit  from Percentiles p;
------------------------------------------------------------------------------------------------------------------------
-- total listers
select sum(total_listers)from(
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Clone' and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc)m;

-- mobile clone listings
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method = 'Clone'and count_listings>0
and count_listings between 1 and 9
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc;

------------------------------------------------------------------------------------------------------------------------
-- mobile other listers
select first_published_date,count_listings,count(distinct seller_id) count_seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by first_published_date, count_listings
order by count_listings desc ;

------ max in mobile Manually relists
    select max(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;

------ min in mobile Manually relists
    select min(count_listings) from analytics_scratch.sashank_listings_published_volume_per_lister
    where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null;
---------- outliers
WITH "mob_data" as
    (select distinct first_published_date,count_listings, seller_id
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
order by first_published_date desc, count_listings desc),
    Percentiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY count_listings) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY count_listings) AS Q3
    FROM mob_data
)
SELECT (p.Q3 - p.Q1) AS IQR,(p.Q1 - 1.5 * (p.Q3 - p.Q1)) as lower_limit, (p.Q3 + 1.5 * (p.Q3 - p.Q1)) as upper_limit  from Percentiles p;
------------------------------------------------------------------------------------------------------------------------
-- total listers
select sum(total_listers)from(
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc)m;

-- mobile other listings
select count_listings,count(distinct seller_id) total_listers,
PERCENT_RANK() OVER (ORDER BY count(distinct seller_id)) AS percentile_rank
from analytics_scratch.sashank_listings_published_volume_per_lister
where home_domain = 'us' and listing_creation_method in('PM Resell','Sell Similar','Reposh','Quick Listing') and count_listings>0
and count_listings between 1 and 4
and EXTRACT(MONTH FROM first_published_date) in(1,2,9,10,11,12) and is_manual_relist is not null
group by  count_listings
order by count_listings desc;
