USE AdventureWorks2019
GO

--1.How many products can you find in the Production.Product table?
SELECT COUNT(ProductID)
FROM Production.Product

--2.Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory.
--The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(ProductID)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

--3.How many Products reside in each SubCategory? Write a query to display the results with the following titles.
SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID

--4.How many products that do not have a product subcategory.
SELECT COUNT(ProductID)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL

--5.Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity)
FROM Production.ProductInventory

--6. Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100

--7.Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40 AND Quantity < 100
GROUP BY Shelf, ProductID

--8.Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10

--9.Write query  to see the average quantity of products by shelf from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf

--10.Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY ProductID, Shelf

--11.List the members (rows) and average list price in the Production.Product table.
--This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
SELECT Color, Class, COUNT(*) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class

--12.Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables.
--Join them and produce a result set similar to the following. 
SELECT c.Name AS Country, p.Name AS Province
FROM Person.CountryRegion c INNER JOIN Person.StateProvince p ON c.CountryRegionCode = p.CountryRegionCode

--13.Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
SELECT c.Name AS Country, p.Name AS Province
FROM Person.CountryRegion c INNER JOIN Person.StateProvince p ON c.CountryRegionCode = p.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')


----------------------------------------------------------------------------------------------------------------------------------------------
USE Northwind
GO

--14.List all Products that has been sold at least once in last 25 years.
--Query cost: 55%
SELECT DISTINCT p.ProductName
FROM Products p INNER JOIN [Order Details] od ON p.ProductID = od.ProductID INNER JOIN Orders o ON od.OrderID = o.OrderID
WHERE YEAR(GETDATE()) - YEAR(o.OrderDate) <= 25

--Query cost: 45%
SELECT DISTINCT p.ProductName
FROM Products p INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
WHERE od.OrderID IN (
SELECT o.OrderID
FROM Orders o
WHERE YEAR(GETDATE()) - YEAR(o.OrderDate) <= 25
)

--15.List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS Total
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipPostalCode
ORDER BY Total DESC

--16.List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 o.ShipPostalCode, SUM(od.Quantity) AS Total
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(GETDATE()) - YEAR(o.OrderDate) <= 25
GROUP BY o.ShipPostalCode
ORDER BY Total DESC

--17.List all city names and number of customers in that city.
SELECT City, COUNT(CustomerID) AS NumberOfCustomers
FROM Customers
GROUP BY City

--18.List city names which have more than 2 customers, and number of customers in that city.
SELECT City, COUNT(CustomerID) AS NumberOfCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

--19.List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.ContactName
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1/1/98'

--20.List the names of all customers with most recent order dates.
SELECT c.ContactName
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate IN (
SELECT MAX(OrderDate)
FROM Orders
)

--21.Display the names of all customers along with the count of products they bought.
SELECT c.ContactName, SUM(od.Quantity) AS NumberOfProducts
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.ContactName

--22.Display the customer ids who bought more than 100 Products with count of products.
SELECT c.ContactName, SUM(od.Quantity) AS NumberOfProducts
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.ContactName
HAVING SUM(od.Quantity) > 100

--23.List all of the possible ways that suppliers can ship their products. Display the results as below
SELECT DISTINCT sup.CompanyName AS "Supplier Company Name", shi.CompanyName AS "Shipping Company Name"
FROM Suppliers sup INNER JOIN Products p ON sup.SupplierID = p.SupplierID INNER JOIN [Order Details] od ON od.ProductID = p.ProductID INNER JOIN Orders o ON o.OrderID = od.OrderID INNER JOIN Shippers shi ON shi.ShipperID = o.ShipVia

--24.Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName, COUNT(o.OrderID) AS NumberOfSales
FROM Orders o INNER JOIN [Order Details] od on o.OrderID = od.OrderID INNER JOIN Products p ON p.ProductID = od.ProductID
GROUP BY o.OrderDate, p.ProductName
ORDER BY o.OrderDate

--25.Display pairs of employees who have the same job title.
SELECT e1.FirstName + ‘ ’ + e1.LastName AS "Employee1", e2.FirstName + ‘ ’ + e2.LastName AS "Employee2"
FROM Employees e1 INNER JOIN Employees e2 ON e1.ContactTitle = e2.ContactTitle
WHERE e1.EmployeeID != e2.EmployeeID

--26.Display all the Managers who have more than 2 employees reporting to them.
SELECT ManagerID, FirstName, LastName
FROM (
SELECT e1.EmployeeID AS ManagerID, e1.FirstName, e1.LastName, COUNT(e2.EmployeeID) AS NumberOfEmployees
FROM Employees e1 INNER JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName
HAVING COUNT(e2.EmployeeID) > 2 ) tmp

--27.Display the customers and suppliers by city. The results should have the following columns
SELECT City, CompanyName, ContactName, 'Customer' AS TypeOfCompany
FROM Customers
UNION
SELECT City, CompanyName, ContactName, 'Supplier'
FROM Suppliers
