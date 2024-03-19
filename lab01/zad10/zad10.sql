SELECT
    curr.productid,
    curr.productname,
    curr.categoryid,
    curr.date,
    curr.unitprice,
    prev.unitprice AS previousprodprice,
    next.unitprice AS nextprodprice
FROM
    product_history curr
LEFT JOIN
    product_history prev ON curr.productid = prev.productid
    AND prev.date = (
        SELECT MAX(date)
        FROM product_history
        WHERE productid = curr.productid AND date < curr.date
    )
LEFT JOIN
    product_history next ON curr.productid = next.productid
    AND next.date = (
        SELECT MIN(date)
        FROM product_history
        WHERE productid = curr.productid AND date > curr.date
    )
WHERE
    curr.productid = 2
    AND YEAR(curr.date) = 2022
ORDER BY
    curr.date;


--- SQLITE
CAST(strftime('%Y', curr.date) AS INTEGER) = 2022

--postgres
EXTRACT('Year' FROM curr.date) = 2022