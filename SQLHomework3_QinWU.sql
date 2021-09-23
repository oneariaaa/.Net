USE Northwind
GO

--1.List all cities that have both Employees and Customers.
--Use JOIN
SELECT DISTINCT e.City
FROM Employees e INNER JOIN Customers c ON e.City = c.City

--Use INTERSECT
SELECT City
FROM Employees
INTERSECT
SELECT City
FROM Customers


--2.List all cities that have Customers but no Employee.
--a.Use sub-query
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN(
SELECT City
FROM Employees
)
--b.Do not use sub-query
SELECT City
FROM Customers
EXCEPT
SELECT City
FROM  Employees

--3.List all products and their total order quantities throughout all orders.
SELECT p.ProductName, COUNT(od.OrderID) AS NumberOfOrders
FROM Products p INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductName

--4.List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(od.Quantity) AS NumberOfQuantities
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City

--5.List all Customer Cities that have at least two customers.
--a.Use union
SELECT c.City
FROM Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID) = 2
UNION
SELECT c.City
FROM Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID) > 2

--b.Use sub-query and no union
SELECT City
FROM (SELECT City, COUNT(CustomerID) AS NumberOfCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2) dt

--6.List all Customer Cities that have ordered at least two different kinds of products.
SELECT City
FROM (SELECT c.City, COUNT(od.ProductID) AS NumberOfProducrs
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.City
HAVING COUNT(od.ProductID) >= 2) dt

--7.List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT c.ContactName
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City != o.ShipCity

--8.List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
SELECT TOP 5 p.ProductName, SUM(od.Quantity) AS NumOfSales, ROUND(AVG(od.UnitPrice), 2) AS AvgPrice, c.City
FROM Products p INNER JOIN [Order Details] od ON p.ProductID = od.ProductID INNER JOIN Orders o ON od.OrderID = o.OrderID INNER JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY p.ProductName, c.City
ORDER BY NumOfSales DESC

--9.List all cities that have never ordered something but we have employees there.
--a.Use sub-query
SELECT City
FROM Employees
WHERE City NOT IN(
SELECT c.City
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID
)

--b.Do not use sub-query
SELECT City
FROM Employees
EXCEPT
SELECT c.City
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID

--10.List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is,
--and also the city of most total quantity of products ordered from. (tip: join  sub-query)
SELECT TOP 1 e.City, COUNT(o.OrderID) AS CNT
FROM Employees e INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.City
ORDER BY CNT DESC

SELECT City
FROM
(SELECT City, CNT, RANK() OVER (ORDER BY CNT DESC) AS RNK
FROM
(SELECT c.City, od.ProductID, SUM(od.Quantity) AS CNT
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City, od.ProductID) dt) tmp
WHERE RNK = 1

--11.How do you remove the duplicates record of a table?
--Ans: 
--Method1: Use DISTINCT keyword.
--Method2: Use ROW_NUMBER function.

--12.Sample table to be used for solutions below
-- Employee (empid integer, mgrid integer, deptid integer, salary money)
-- Dept (deptid integer, deptname varchar(20))
--Find employees who do not manage anybody.
SELECT empid
FROM Employee
WHERE empid NOT IN (
SELECT mgrid
FROM Employee
)

--13. Find departments that have maximum number of employees.
--(solution should consider scenario having more than 1 departments that have maximum number of employees).
--Result should only have - deptname, count of employees sorted by deptname.
SELECT deptname, Num
FROM (
SELECT d2.deptname, dt.Num, RANK() OVER (ORDER BY dt.Num DESC) AS RNK
FROM
(SELECT d1.deptid, COUNT(e.empid) AS Num
FROM Dept d1 INNER JOIN Employee e ON d1.deptid = e.deptid
GROUP BY d.deptid) dt INNER JOIN Dept d2 ON dt.deptid = d2.deptid)
WHERE RNK = 1
ORDER BY deptname

--14. Find top 3 employees (salary based) in every department.
--Result should have deptname, empid, salary sorted by deptname and then employee with high to low salary.
SELECT deptname, empid, salary
FROM (
SELECT d.deptname, e.empid, e.salary, ROW_NUMBER() OVER ( PARTITION BY e.deptid ORDER BY e.salary DESC ) AS RNK
FROM Employee e INNER JOIN Dept d ON e.deptid = d.deptid) dt
WHERE RNK <= 3
ORDER BY deptname, RNK;