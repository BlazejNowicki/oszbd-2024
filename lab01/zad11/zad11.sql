--postgres, mssql

WITH OrderValues AS (
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        o.Freight,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalValue
    FROM orders o
    INNER JOIN orderdetails od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, o.CustomerID, o.OrderDate, o.Freight
),
    RankedOrders AS (
    SELECT
        c.CompanyName AS CustomerName,
        ov.OrderID,
        ov.OrderDate,
        ov.TotalValue + ov.Freight AS OrderValue,
        LAG(ov.OrderID) OVER(PARTITION BY ov.CustomerID ORDER BY ov.OrderDate) AS PreviousOrderID,
        LAG(ov.OrderDate) OVER(PARTITION BY ov.CustomerID ORDER BY ov.OrderDate) AS PreviousOrderDate,
        LAG(ov.TotalValue + ov.Freight) OVER(PARTITION BY ov.CustomerID ORDER BY ov.OrderDate) AS PreviousOrderValue
    FROM OrderValues ov
    INNER JOIN customers c ON ov.CustomerID = c.CustomerID
)
SELECT
    CustomerName,
    OrderID,
    OrderDate,
    OrderValue,
    PreviousOrderID,
    PreviousOrderDate,
    PreviousOrderValue
FROM RankedOrders
ORDER BY CustomerName, OrderDate;
