-- zad4 postgres

-- subquery
SELECT *
from (SELECT p.ProductID,
             p.ProductName,
             p.UnitPrice,
             (SELECT AVG(UnitPrice) FROM Products p2 WHERE p2.categoryid = p.categoryid) AS AvgCatPrice
      from products p) as p2
where AvgCatPrice < UnitPrice
order by productid;

--window
select *
from (Select p.ProductID, p.ProductName, p.UnitPrice, AVG(p.UnitPrice) over (partition by p.categoryid) as AvgCatPrice
      from products p) as p2
where AvgCatPrice < UnitPrice
order by productid;

--join
SELECT p.ProductID, p.ProductName, p.UnitPrice, avg(p2.unitprice) as AvgCatPrice
from products p
         inner join products p2 on p2.categoryid = p.categoryid
group by p.ProductID, p.ProductName, p.UnitPrice
having avg(p2.unitprice) < p.UnitPrice
order by productid;
