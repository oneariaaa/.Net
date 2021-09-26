USE Northwind
GO

--4.Create a view named “view_product_order_[your_last_name]”
--list all products and total ordered quantity for that product.
DROP VIEW view_product_order_Wu
CREATE VIEW view_product_order_Wu
AS
SELECT p.ProductName, SUM(o.Quantity) AS TotalQuantities
FROM Products p INNER JOIN [Order Details] o ON p.ProductID = o.ProductID
GROUP BY p.ProductName

--5.Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
DROP PROCEDURE sp_product_order_quantity_Wu
CREATE PROCEDURE sp_product_order_quantity_Wu
@productId SMALLINT,
@totalQuantities INT OUTPUT
AS
BEGIN
SELECT @totalQuantities = SUM(o.Quantity)
FROM Products p INNER JOIN [Order Details] o ON p.ProductID = o.ProductID
WHERE p.ProductID = @productId
GROUP BY p.ProductName
END

DECLARE @output INT;
EXECUTE sp_product_order_quantity_Wu 1, @output OUTPUT
SELECT @output AS TotalQuantities

--6.Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and
--top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
DROP PROCEDURE sp_product_order_city_Wu
CREATE PROCEDURE sp_product_order_city_Wu
@productName VARCHAR,
@topCities VARCHAR OUTPUT
AS
BEGIN
SELECT TOP 5 c.City, SUM(od.Quantity) AS Num
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
END

DECLARE @top VARCHAR
EXECUTE sp_product_order_city_Wu 'Chai', @top OUTPUT

--9.Create 2 new tables “people_your_last_name” “city_your_last_name”.
--City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}.
--People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}.
--Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”.
--Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
DROP TABLE city_Wu
DROP TABLE people_Wu
DROP VIEW Packers_QinWU

CREATE TABLE city_Wu
(Id INT PRIMARY KEY,
City VARCHAR(20) NOT NULL)

CREATE TABLE people_Wu
(Id INT PRIMARY KEY,
PName VARCHAR(20) NOT NULL,
City INT FOREIGN KEY REFERENCES city_Wu(Id) ON DELETE SET NULL)

INSERT INTO city_Wu
VALUES (1, 'Seattle'),
(2, 'Green Bay')

INSERT INTO people_Wu
VALUES (1, 'Aaron Rodgers', 2),
(2, 'Russell Wilson', 1),
(3, 'Jody Nelson', 2)

SELECT *
FROM people_Wu

SELECT *
FROM city_Wu

DELETE FROM city_Wu
WHERE City = 'Seattle'

INSERT INTO city_Wu
VALUES (3, 'Madison')

UPDATE people_Wu
SET City = 3
WHERE City IS NULL

CREATE VIEW Packers_QinWU
AS
SELECT PName
FROM people_Wu p INNER JOIN city_Wu c ON p.City = c.Id
WHERE c.City = 'Green Bay'

--10.Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” 
--and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
SELECT EmployeeID, LastName, FirstName, BirthDate
FROM Employees

DROP PROCEDURE sp_birthday_employees_Wu
DROP TABLE birthday_employees_Wu

CREATE PROCEDURE sp_birthday_employees_Wu
AS
BEGIN
CREATE TABLE birthday_employees_Wu
(Id INT IDENTITY(1, 1) PRIMARY KEY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(EmployeeID),
Birthday DATE)

INSERT INTO birthday_employees_Wu
SELECT EmployeeID, BirthDate
FROM Employees
WHERE MONTH(BirthDate) = 2
END

EXECUTE sp_birthday_employees_Wu

SELECT *
FROM birthday_employees_Wu

--11.Create a stored procedure named “sp_your_last_name_1” that returns all cites that have at least 2 customers who have bought no or only one kind of product.
--Create a stored procedure named “sp_your_last_name_2” that returns the same but using a different approach. (sub-query and no-sub-query).
DROP PROCEDURE sp_Wu_1
DROP PROCEDURE sp_Wu_2

CREATE PROCEDURE sp_Wu_1
AS
BEGIN
SELECT  c.City, COUNT(DISTINCT c.CustomerID)
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.City
HAVING COUNT(DISTINCT c.CustomerID) > 2 AND COUNT(od.ProductID) < 2
END

CREATE PROCEDURE sp_Wu_2
AS
BEGIN
SELECT  c.City
FROM Customers c, Orders o
WHERE c.CustomerID = o.CustomerID AND o.OrderID IN (
SELECT OrderID
FROM [Order Details]
GROUP BY OrderID
HAVING COUNT(ProductID) < 2
)
GROUP BY c.City
HAVING COUNT(DISTINCT c.CustomerID) > 2
END

--12.How do you make sure two tables have the same data?
--Ans: We can use UNION to combine two tables and compare the number of rows of the combined table with the number of rows that the original tables have.

--14.
DROP TABLE NameList
CREATE TABLE NameList
(id INT PRIMARY KEY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
MiddleName VARCHAR(20))

INSERT INTO NameList
VALUES(1, 'Indhu', 'S', 'M'),
(2, 'Qin', 'Wu', NULL)

SELECT *
FROM NameList

SELECT FirstName + ' ' + LastName AS " Full Name"
FROM NameList
WHERE MiddleName IS NULL
UNION
SELECT FirstName + ' ' + LastName + ' ' + MiddleName + '.' AS "Full Name"
FROM NameList
WHERE MiddleName IS NOT NULL

--15.
SELECT TOP 1 Marks
FROM Scores
WHERE Sex = 'F'
ORDER BY Marks DESC

--16.
SELECT Student, Marks, Sex
FROM Scores
WHERE Sex = 'F'
ORDER BY Marks DESC
UNION
SELECT Student, Marks, Sex
FROM Scores
WHERE Sex = 'M'
ORDER BY Marks DESC
