SELECT
    id,
    productid,
    date,
    value,
    SUM(value) OVER (PARTITION BY productid, YEAR(date), MONTH(date) ORDER BY date) AS cumulative_sales
FROM
    product_history
order by productid, date


SELECT
    ph1.id,
    ph1.productid,
    ph1.date,
    ph1.value,
    (SELECT SUM(ph2.value)
     FROM product_history ph2
     WHERE ph2.productid = ph1.productid
       AND YEAR(ph2.date) = YEAR(ph1.date)
       AND MONTH(ph2.date) = MONTH(ph1.date)
       AND ph2.date <= ph1.date) AS cumulative_sales
FROM
    product_history ph1
ORDER BY
    ph1.productid, ph1.date;
