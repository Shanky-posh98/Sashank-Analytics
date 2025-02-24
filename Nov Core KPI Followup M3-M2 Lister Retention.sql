-- Over all listers by month cohort

select mx.*,dx.#_users_activated from
(SELECT
    (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')) AS "joined_month",
    lister.home_domain  AS "home_domain",
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS "is_restricted",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 1)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M1",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 2)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M2",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 3)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M3",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 4)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M4",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 5)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M5",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 6)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M6",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 7)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M7",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 8)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M8",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 9)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M9",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 10)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M10",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 11)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M11",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) = 12)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M12",
    COUNT(DISTINCT CASE WHEN (( DATEDIFF(month,(coalesce(lister.guest_joined_at, lister.joined_at)),dw_listings.first_published_at) + 1  ) >= 13)
                                 AND ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END) AS "M13+"
FROM analytics.dw_listings  AS dw_listings
LEFT JOIN analytics.dw_users  AS lister ON dw_listings.seller_id  = lister.user_id
WHERE (((((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) >= (TIMESTAMP '2019-01-01') AND ((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) < (TIMESTAMP '2024-12-31')))) AND
      (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL) AND (( CASE
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
ELSE 'Other'
END ) ILIKE  'iOS') AND (dw_listings.is_valid_listing = TRUE )
GROUP BY
    (DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) )),
    2,
    3
ORDER BY
    1 DESC)mx
left join

(SELECT (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')) AS "joined_month",
    lister.home_domain  AS "home_domain",
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS "is_restricted",

       count( DISTINCT (lister.user_id)) "#_users_activated" FROM analytics.dw_users as lister

WHERE (((((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) >= (TIMESTAMP '2019-01-01') AND ((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) < (TIMESTAMP '2024-12-31')))) AND
      (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL) AND (( CASE
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
ELSE 'Other'
END ) ILIKE  'iOS')

GROUP BY (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')),2,3  order by 1 desc)dx

on mx.joined_month=dx.joined_month and mx.home_domain=dx.home_domain and mx.is_restricted=dx.is_restricted
order by mx.joined_month desc ;
-------------------------------------------------------------------------------------------------------------------------------------

-- M2 break down

WITH seller_data AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', COALESCE(lister.guest_joined_at, lister.joined_at)), 'YYYY-MM') AS joined_month,
        lister.home_domain  AS home_domain,
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS is_restricted,
        case when ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END AS seller_id,
        DATEDIFF(month, COALESCE(lister.guest_joined_at, lister.joined_at), dw_listings.first_published_at) + 1 AS month_diff
    FROM analytics.dw_listings AS dw_listings
    LEFT JOIN analytics.dw_users AS lister ON dw_listings.seller_id = lister.user_id
      AND (COALESCE(lister.guest_joined_at, lister.joined_at) BETWEEN TIMESTAMP '2019-01-01' AND TIMESTAMP '2024-12-31')
      AND (( CASE
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
          ELSE 'Other'
          END ) ILIKE  'iOS')
      AND (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),
            (CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) )
            OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted'
            THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL)
      AND dw_listings.is_valid_listing = TRUE
),
month_data AS (
    SELECT
        joined_month,
        home_domain,
        is_restricted,
        seller_id,
        month_diff
    FROM seller_data
    WHERE month_diff BETWEEN 1 AND 13
)

select mx.*,dx.#_users_activated from
(select joined_month,home_domain,is_restricted,
        count(distinct case when M1_flag+M2_flag=1 and M2_flag=1 then seller_id end) as "New M2 listers",
        count(distinct case when M1_flag+M2_flag=2 then seller_id end) as "M2 streaksters"


from
(select joined_month, home_domain,is_restricted, seller_id,
       max(case when month_diff=1 then 1 else 0 end) as M1_flag,
       max(case when month_diff=2 then 1 else 0 end) as M2_flag,
       max(case when month_diff=3 then 1 else 0 end) as M3_flag,
       max(case when month_diff=4 then 1 else 0 end) as M4_flag,
       max(case when month_diff=5 then 1 else 0 end) as M5_flag,
       max(case when month_diff=6 then 1 else 0 end) as M6_flag,
       max(case when month_diff=7 then 1 else 0 end) as M7_flag,
       max(case when month_diff=8 then 1 else 0 end) as M8_flag,
       max(case when month_diff=9 then 1 else 0 end) as M9_flag,
       max(case when month_diff=10 then 1 else 0 end) as M10_flag,
       max(case when month_diff=11 then 1 else 0 end) as M11_flag,
       max(case when month_diff=12 then 1 else 0 end) as M12_flag,
       max(case when month_diff>=13 then 1 else 0 end) as M13_and_more_flag
       from month_data group by joined_month, home_domain,is_restricted, seller_id)a group by joined_month,home_domain,is_restricted order by joined_month desc)mx
left join

(SELECT (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')) AS "joined_month",
    lister.home_domain  AS "home_domain",
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS "is_restricted",

       count( DISTINCT (lister.user_id)) "#_users_activated" FROM analytics.dw_users as lister

WHERE (((((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) >= (TIMESTAMP '2019-01-01') AND ((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) < (TIMESTAMP '2024-12-31')))) AND
      (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL) AND (( CASE
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
ELSE 'Other'
END ) ILIKE  'iOS')

GROUP BY (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')),2,3  order by 1 desc)dx

on mx.joined_month=dx.joined_month and mx.home_domain=dx.home_domain and mx.is_restricted=dx.is_restricted
order by mx.joined_month desc;
-------------------------------------------------------------------------------------------------------------------------

-- M3 Break down

WITH seller_data AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', COALESCE(lister.guest_joined_at, lister.joined_at)), 'YYYY-MM') AS joined_month,
        lister.home_domain  AS home_domain,
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS is_restricted,
        case when ((( dw_listings.parent_listing_id  ) IS NULL)) THEN dw_listings.seller_id  ELSE NULL END AS seller_id,
        DATEDIFF(month, COALESCE(lister.guest_joined_at, lister.joined_at), dw_listings.first_published_at) + 1 AS month_diff
    FROM analytics.dw_listings AS dw_listings
    LEFT JOIN analytics.dw_users AS lister ON dw_listings.seller_id = lister.user_id
      AND (COALESCE(lister.guest_joined_at, lister.joined_at) BETWEEN TIMESTAMP '2019-01-01' AND TIMESTAMP '2024-12-31')
      AND (( CASE
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
          WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
          ELSE 'Other'
          END ) ILIKE  'iOS')
      AND (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),
            (CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) )
            OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted'
            THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL)
      AND dw_listings.is_valid_listing = TRUE
),
month_data AS (
    SELECT
        joined_month,
        home_domain,
        is_restricted,
        seller_id,
        month_diff
    FROM seller_data
    WHERE month_diff BETWEEN 1 AND 13
)

select mx.*,dx.#_users_activated from
(select joined_month,home_domain,is_restricted,

       count(distinct case when M1_flag+M2_flag+M3_flag=2 and M2_flag=0 then seller_id end) as "M1->NOT M2->M3",
       count(distinct case when M1_flag+M2_flag+M3_flag=2 and M1_flag=0 then seller_id end) as "NOT M1->M2->M3",
       count(distinct case when M1_flag+M2_flag+M3_flag=3 then seller_id end) as "M1->M2->M3",
       count(distinct case when M1_flag+M2_flag+M3_flag=1 and M3_flag=1 then seller_id end) as "New M3 listers"

from
(select joined_month, home_domain,is_restricted, seller_id,
       max(case when month_diff=1 then 1 else 0 end) as M1_flag,
       max(case when month_diff=2 then 1 else 0 end) as M2_flag,
       max(case when month_diff=3 then 1 else 0 end) as M3_flag,
       max(case when month_diff=4 then 1 else 0 end) as M4_flag,
       max(case when month_diff=5 then 1 else 0 end) as M5_flag,
       max(case when month_diff=6 then 1 else 0 end) as M6_flag,
       max(case when month_diff=7 then 1 else 0 end) as M7_flag,
       max(case when month_diff=8 then 1 else 0 end) as M8_flag,
       max(case when month_diff=9 then 1 else 0 end) as M9_flag,
       max(case when month_diff=10 then 1 else 0 end) as M10_flag,
       max(case when month_diff=11 then 1 else 0 end) as M11_flag,
       max(case when month_diff=12 then 1 else 0 end) as M12_flag,
       max(case when month_diff>=13 then 1 else 0 end) as M13_and_more_flag
       from month_data group by joined_month, home_domain,is_restricted, seller_id)a group by joined_month,home_domain,is_restricted order by joined_month desc)mx
left join

(SELECT (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')) AS "joined_month",
    lister.home_domain  AS "home_domain",
        (CASE WHEN coalesce(lister.user_status = 'restricted', FALSE)  THEN 'Yes' ELSE 'No' END) AS "is_restricted",

       count( DISTINCT (lister.user_id)) "#_users_activated" FROM analytics.dw_users as lister

WHERE (((((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) >= (TIMESTAMP '2019-01-01') AND ((( coalesce(lister.guest_joined_at, lister.joined_at)  ))) < (TIMESTAMP '2024-12-31')))) AND
      (NOT (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) OR (coalesce((datediff(day,(coalesce(lister.guest_joined_at, lister.joined_at)),(CASE WHEN lister.user_status = 'restricted' THEN lister.status_updated_at ELSE NULL END)) + 1) <= 30, FALSE) ) IS NULL) AND (( CASE
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) in ('iphone','ipad')  THEN 'iOS'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'android'  THEN 'Android'
WHEN (coalesce(lister.guest_reg_app,lister.reg_app)) = 'web'  THEN 'Web'
ELSE 'Other'
END ) ILIKE  'iOS')

GROUP BY (TO_CHAR(DATE_TRUNC('month', coalesce(lister.guest_joined_at, lister.joined_at) ), 'YYYY-MM')),2,3  order by 1 desc)dx

on mx.joined_month=dx.joined_month and mx.home_domain=dx.home_domain and mx.is_restricted=dx.is_restricted
order by mx.joined_month desc;
