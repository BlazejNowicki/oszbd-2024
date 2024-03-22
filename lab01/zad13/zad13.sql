WITH OrderTotals AS (
    SELECT
        o.CustomerID,
        o.OrderID,
        o.OrderDate,
        SUM((od.UnitPrice * od.Quantity) * (1 - od.Discount)) + o.Freight AS TotalValue,
        YEAR(o.orderdate) AS OrderYear,
        MONTH(o.orderdate) AS OrderMonth
    FROM
        orders o
        JOIN orderdetails od ON o.OrderID = od.OrderID
    GROUP BY
        o.CustomerID, o.OrderID, o.OrderDate, o.Freight
), MonthlyExtremes AS (
    SELECT
        CustomerID,
        OrderYear,
        OrderMonth,
        FIRST_VALUE(OrderID) OVER(PARTITION BY CustomerID, OrderYear, OrderMonth ORDER BY TotalValue ASC) AS MinOrderID,
        FIRST_VALUE(OrderID) OVER(PARTITION BY CustomerID, OrderYear, OrderMonth ORDER BY TotalValue DESC) AS MaxOrderID
    FROM OrderTotals
)
SELECT
    DISTINCT me.CustomerID,
    me.OrderYear,
    me.OrderMonth,
    me.MinOrderID,
    otMin.OrderDate AS MinOrderDate,
    otMin.TotalValue AS MinTotalValue,
    me.MaxOrderID,
    otMax.OrderDate AS MaxOrderDate,
    otMax.TotalValue AS MaxTotalValue
FROM MonthlyExtremes me
JOIN OrderTotals otMin ON me.MinOrderID = otMin.OrderID
JOIN OrderTotals otMax ON me.MaxOrderID = otMax.OrderID
ORDER BY me.CustomerID, me.OrderYear, me.OrderMonth;