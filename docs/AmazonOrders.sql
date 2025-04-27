/*─────────────────────────────────────────────────────────────
  Revenue & Profitability
  MONTHLY REVENUE, COST, GMV & YoY%
──────────────────────────────────────────────── */
WITH order_totals AS (         
    SELECT
        co.orderNumber,
        co.orderDate,
        SUM(iio.totalItemCost)                 AS orderRevenue,
        SUM(i.itemCost * iio.numberOf)         AS orderCost
    FROM   CustomerOrders  co
    JOIN   ItemsInOrder    iio ON iio.orderNumber = co.orderNumber
    JOIN   Items           i   ON i.itemID = iio.itemID
    GROUP  BY co.orderNumber, co.orderDate
),
monthly_finance AS (           -- monthly aggregation
    SELECT
        DATE_FORMAT(orderDate, '%Y-%m')        AS ym,
        SUM(orderRevenue)                      AS revenue,
        SUM(orderCost)                         AS cost
    FROM   order_totals
    GROUP  BY ym
)
SELECT
    ym,
    revenue,
    cost,
    revenue - cost                              AS grossMargin,
    ROUND(100 * (revenue - cost) / revenue, 2) AS marginPct,
    LAG(revenue, 12)  OVER (ORDER BY ym)        AS PY_revenue,
    ROUND(
        100 * (revenue - LAG(revenue,12) OVER (ORDER BY ym)) 
        /  LAG(revenue,12) OVER (ORDER BY ym), 2)            AS YoY_GrowthPct
FROM   monthly_finance
ORDER  BY ym;

/* ─────────────────────────────────
   Customer Lifetime Value & Segmentation
   PURPOSE  : Show customer spend and frequency.
────────────────────────────────── */
WITH customer_orders AS (
    SELECT
        co.customerID,
        COUNT(DISTINCT co.orderNumber)                      AS orders,
        SUM(iio.totalItemCost)                              AS spend
    FROM   CustomerOrders  co
    JOIN   ItemsInOrder    iio ON iio.orderNumber = co.orderNumber
    GROUP  BY co.customerID
)
SELECT
    c.customerID,
    c.firstName,
    c.lastName,
    COALESCE(spend,0)   AS totalSpend,
    COALESCE(orders,0)  AS orderCount,
    CASE  WHEN spend > 10000 THEN 'goldmine'
          WHEN spend >  1000 THEN 'big spender'
          WHEN spend >   500 THEN 'average spender'
          ELSE                   'unworthy'     END          AS spendTier
FROM   Customers c
LEFT   JOIN customer_orders ON c.customerID = co.customerID
ORDER  BY spendTier, totalSpend DESC;

-- Repeat‑vs‑First orders by month 
WITH first_purchase AS (
    SELECT customerID, MIN(orderDate) firstDate
    FROM   CustomerOrders
    GROUP  BY customerID
)
SELECT
    DATE_FORMAT(co.orderDate,'%Y-%m') AS ym,
    SUM(co.orderDate = fp.firstDate)  AS firstOrders,
    SUM(co.orderDate  > fp.firstDate) AS repeatOrders
FROM   CustomerOrders co
JOIN   first_purchase fp ON co.customerID = fp.customerID
GROUP  BY ym
ORDER  BY ym;

/* ────────────────────────────────────
   Product & Category Performance
   Top‑5 Categories by Units Sold
────────────────────────────────────── */

SELECT ic.categoryName,
    SUM(iio.numberOf)                       AS unitsSold
FROM   ItemCategories  AS ic
JOIN   Items           AS i   ON i.categoryID = ic.categoryID
JOIN   ItemsInOrder    AS iio ON iio.itemID   = i.itemID
GROUP  BY ic.categoryName
ORDER  BY unitsSold DESC
LIMIT 5;

/*========================================================
  CATEGORY MARGIN LEAGUE TABLE
========================================================*/
WITH category_rev AS (
    SELECT
        ic.categoryName,
        SUM(iio.totalItemCost)              AS revenue,
        SUM(i.itemCost * iio.numberOf)      AS cost
    FROM   ItemCategories  AS ic
    JOIN   Items           AS i   ON i.categoryID = ic.categoryID
    JOIN   ItemsInOrder    AS iio ON iio.itemID   = i.itemID
    GROUP  BY ic.categoryName
)
SELECT
    categoryName,
    revenue,
    cost,
    revenue - cost                                AS grossMargin,
    ROUND(100.0 * (revenue - cost) / NULLIF(revenue,0), 2) AS marginPct
FROM   category_rev
ORDER  BY grossMargin DESC;

/*========================================================
  Pricing & Promotion Effectiveness
  LOWEST MARK‑UP & AFFECTED ITEMS
========================================================*/
WITH min_markup AS (
    SELECT MIN(markup) AS smallestMarkup
    FROM   ItemMarkupHistory
)
SELECT
    i.itemName,
    imh.startDate,
    imh.endDate,
    imh.markup
FROM   ItemMarkupHistory AS imh
JOIN   min_markup        ON imh.markup = min_markup.smallestMarkup
JOIN   Items             AS i   ON i.itemID = imh.itemID;

/*========================================================
  SALE vs REGULAR (2020 PROMO IMPACT)
========================================================*/
SELECT
    CASE WHEN imh.sale = TRUE THEN 'Sale' ELSE 'Regular' END  AS lineType,
    COUNT(*)                                               AS orderLines,
    SUM(iio.numberOf)                                      AS unitsSold,
    SUM(iio.totalItemCost)                                 AS revenue,
    SUM(iio.totalItemCost - i.itemCost * iio.numberOf)     AS margin
FROM   ItemsInOrder      AS iio
JOIN   Items             AS i   ON i.itemID  = iio.itemID
JOIN   ItemMarkupHistory AS imh ON imh.itemID = i.itemID
WHERE  YEAR(imh.startDate) = 2020
GROUP  BY CASE WHEN imh.sale = TRUE THEN 'Sale' ELSE 'Regular' END;

/*-------------------------------------------------------------
Sales Pattern Analysis: Identify high‑traffic dates and item volume.
-------------------------------------------------------------*/
SELECT 
    DATE(orderDate) AS order_day,
    CASE 
        WHEN DAYOFWEEK(orderDate) = 1 THEN 'Sunday'
        WHEN DAYOFWEEK(orderDate) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(orderDate) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(orderDate) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(orderDate) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(orderDate) = 6 THEN 'Friday'
        ELSE 'Saturday' END AS weekday_name,
    CASE 
        WHEN MONTH(orderDate) = 1 THEN 'January'
        WHEN MONTH(orderDate) = 2 THEN 'February'
        WHEN MONTH(orderDate) = 3 THEN 'March'
        WHEN MONTH(orderDate) = 4 THEN 'April'
        WHEN MONTH(orderDate) = 5 THEN 'May'
        WHEN MONTH(orderDate) = 6 THEN 'June'
        WHEN MONTH(orderDate) = 7 THEN 'July'
        WHEN MONTH(orderDate) = 8 THEN 'August'
        WHEN MONTH(orderDate) = 9 THEN 'September'
        WHEN MONTH(orderDate) = 10 THEN 'October'
        WHEN MONTH(orderDate) = 11 THEN 'November'
        ELSE 'December' END AS month_name,
    YEAR(orderDate) AS year,
    COUNT(co.orderNumber) AS num_orders,
    SUM(iio.numberOf) AS total_items
FROM CustomerOrders co
JOIN ItemsInOrder iio 
    ON co.orderNumber = iio.orderNumber
WHERE orderDate > '2019-01-01'
GROUP BY DATE(orderDate), order_day, DAYOFWEEK(orderDate), weekday_name, 
        MONTH(orderDate), month_name, YEAR(orderDate), year
ORDER BY num_orders DESC, total_items ASC;

/*-------------------------------------------------------------
   PURPOSE  : Spot highly‑rated but under‑selling (or vice‑versa) SKUs.
   RETURNS  : itemID, itemName, avgRating, unitsSold
-------------------------------------------------------------*/
SELECT
    i.itemID,
    i.itemName,
    COALESCE(AVG(r.rating), 0)          AS avgRating,
    COALESCE(SUM(iio.numberOf), 0)    AS unitsSold
FROM   Items            AS i
LEFT  JOIN Reviews      AS r ON r.itemID  = i.itemID
LEFT  JOIN ItemsInOrder AS iio ON iio.itemID = i.itemID
GROUP  BY i.itemID, i.itemName
HAVING unitsSold > 0
ORDER  BY avgRating DESC, unitsSold DESC;
/*-------------------------------------------------------------
  PURPOSE  : Revenue contribution by geographic region
  RETURNS  : region, revenue, uniqueCustomers
-------------------------------------------------------------*/
SELECT
    a.region,
    SUM(iio.totalItemCost)                      AS revenue,
    COUNT(DISTINCT c.customerID)                AS uniqueCustomers
FROM   Addresses        AS a
JOIN   Customers      AS c   ON c.addressID = a.addressID
JOIN   CustomerOrders AS co  ON co.customerID = c.customerID
JOIN   ItemsInOrder   AS iio ON iio.orderNumber = co.orderNumber
GROUP  BY a.region
ORDER  BY revenue DESC;

/*-------------------------------------------------------------
  Operational / Cash‑Flow KPIs 
  PURPOSE  : Cash‑flow / collections KPI.
  RETURNS  : avg_DSO_days 
-------------------------------------------------------------*/
SELECT
    ROUND(AVG(DATEDIFF(datePaid, orderDate)),1) AS avg_DSO_days
FROM   CustomerOrders
WHERE  datePaid IS NOT NULL;

/*-------------------------------------------------------------
  PURPOSE  : Build a re‑activation list for Customers inactive for ≥12 months
  RETURNS  : customerID, firstName, lastName, lastOrderDate
-------------------------------------------------------------*/
SELECT
    c.customerID,
    c.firstName,
    c.lastName,
    MAX(co.orderDate) AS lastOrderDate
FROM   Customers       AS c
LEFT JOIN CustomerOrders AS co ON co.customerID = c.customerID
GROUP  BY c.customerID, c.firstName, c.lastName
HAVING lastOrderDate < DATE_SUB(CURDATE(), INTERVAL 12 MONTH)  -- or IS NULL
    OR lastOrderDate IS NULL
ORDER  BY lastOrderDate;