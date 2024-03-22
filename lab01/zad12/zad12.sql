--postgres, sqlite
SELECT
    p.productid,
    p.productname,
    p.unitprice,
    p.categoryid,
    (SELECT ProductName FROM Products p2 WHERE p2.CategoryID = p.CategoryID ORDER BY UnitPrice DESC LIMIT 1) AS MostExpensiveProductName,
    (SELECT ProductName FROM Products p3 WHERE p3.CategoryID = p.CategoryID ORDER BY UnitPrice ASC LIMIT 1) AS CheapestProductName
FROM
    Products p
ORDER BY
    categoryid, unitprice desc;


--mssql
SELECT
    p.productid,
    p.productname,
    p.unitprice,
    p.categoryid,
    (SELECT top 1 ProductName FROM Products p2 WHERE p2.CategoryID = p.CategoryID ORDER BY UnitPrice DESC) AS MostExpensiveProductName,
    (SELECT top 1 ProductName FROM Products p3 WHERE p3.CategoryID = p.CategoryID ORDER BY UnitPrice ASC) AS CheapestProductName
FROM
    Products p
ORDER BY
    categoryid, unitprice desc;



-- faster, windowed version
select productid, productname, unitprice, categoryid,
    first_value(productname) over (partition by categoryid
order by unitprice desc) first,
    last_value(productname) over (partition by categoryid
order by unitprice desc
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) last
from products
order by categoryid, unitprice desc;