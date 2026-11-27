-- ============================================================

-- ============================================================
-- DATA DIGGER: E-COMMERCE STORE DATABASE
-- Database: Microsoft SQL Server
-- Description: CRUD, Keys, Joins, Clauses and Aggregates
-- ============================================================

-- STEP 1: CREATE DATABASE
IF DB_ID('DataDigger') IS NULL
BEGIN
    CREATE DATABASE DataDigger;
END;
GO

USE DataDigger;
GO

-- ============================================================
-- STEP 2: CREATE TABLES
-- ============================================================

-- TABLE 1: CUSTOMERS
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Address VARCHAR(255)
);

-- TABLE 2: PRODUCTS
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT DEFAULT 0
);

-- TABLE 3: ORDERS
CREATE TABLE [Orders] (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- TABLE 4: ORDER DETAILS
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (OrderID)
    REFERENCES [Orders](OrderID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    FOREIGN KEY (ProductID)
    REFERENCES Products(ProductID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- ============================================================
-- STEP 3: INSERT CUSTOMERS
-- ============================================================

INSERT INTO Customers (Name, Email, Address)
VALUES
('Alice Johnson', 'alice.johnson@email.com', '123 Maple Street, Mumbai, MH 400001'),
('Bob Smith', 'bob.smith@email.com', '456 Oak Avenue, Delhi, DL 110001'),
('Charlie Brown', 'charlie.brown@email.com', '789 Pine Road, Bangalore, KA 560001'),
('Diana Prince', 'diana.prince@email.com', '321 Cedar Lane, Chennai, TN 600001'),
('Ethan Hunt', 'ethan.hunt@email.com', '654 Birch Drive, Kolkata, WB 700001');

-- ============================================================
-- STEP 4: INSERT PRODUCTS
-- ============================================================

INSERT INTO Products (ProductName, Price, Stock)
VALUES
('Wireless Mouse', 799.00, 50),
('Mechanical Keyboard', 2499.00, 30),
('USB-C Hub', 1299.00, 0),
('Laptop Stand', 899.00, 75),
('Webcam HD', 1899.00, 20);

-- ============================================================
-- STEP 5: INSERT ORDERS
-- ============================================================

INSERT INTO [Orders] (CustomerID, OrderDate, TotalAmount)
VALUES
(1, DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), 799.00),
(2, DATEADD(DAY, -15, CAST(GETDATE() AS DATE)), 2499.00),
(3, DATEADD(DAY, -25, CAST(GETDATE() AS DATE)), 2198.00),
(1, DATEADD(DAY, -40, CAST(GETDATE() AS DATE)), 899.00),
(4, DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), 1899.00);

-- ============================================================
-- STEP 6: INSERT ORDER DETAILS
-- ============================================================

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, SubTotal)
VALUES
(1, 1, 1, 799.00),
(2, 2, 1, 2499.00),
(3, 1, 2, 1598.00),
(3, 4, 1, 600.00),
(5, 5, 1, 1899.00);

-- ============================================================
-- SECTION A: CUSTOMERS TABLE QUERIES
-- ============================================================

-- A1: Retrieve all customer details
SELECT * FROM Customers;

-- A2: Update a customer's address
UPDATE Customers
SET Address = '999 New Street, Gurgaon, HR 122001'
WHERE CustomerID = 2;

-- Verify the update
SELECT * FROM Customers
WHERE CustomerID = 2;

-- A3: Delete a customer
DELETE FROM Customers
WHERE CustomerID = 5;

-- Verify deletion
SELECT * FROM Customers;

-- A4: Find customer by exact name
SELECT * FROM Customers
WHERE Name = 'Alice Johnson';

-- Alternative: Partial name search
SELECT * FROM Customers
WHERE Name LIKE '%Alice%';

-- ============================================================
-- SECTION B: ORDERS TABLE QUERIES
-- ============================================================

-- B1: Retrieve all orders
SELECT * FROM [Orders];

-- B2: Orders made by a specific customer
SELECT * FROM [Orders]
WHERE CustomerID = 1;

-- B3: Update order amount
UPDATE [Orders]
SET TotalAmount = 899.00
WHERE OrderID = 1;

-- Verify update
SELECT * FROM [Orders]
WHERE OrderID = 1;

-- B4: Delete a specific order
DELETE FROM [Orders]
WHERE OrderID = 4;

-- Verify deletion
SELECT * FROM [Orders];

-- B5: Orders placed in the last 30 days
SELECT * FROM [Orders]
WHERE OrderDate >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE));

-- B6: Highest, lowest and average order amount
SELECT
    MAX(TotalAmount) AS HighestOrderAmount,
    MIN(TotalAmount) AS LowestOrderAmount,
    ROUND(AVG(TotalAmount), 2) AS AverageOrderAmount
FROM [Orders];

-- ============================================================
-- SECTION C: PRODUCTS TABLE QUERIES
-- ============================================================

-- C1: Retrieve all products
SELECT * FROM Products;

-- C2: Sort products by price (highest first)
SELECT * FROM Products
ORDER BY Price DESC;

-- C3: Update product price
UPDATE Products
SET Price = 849.00
WHERE ProductID = 1;

-- Verify update
SELECT * FROM Products
WHERE ProductID = 1;

-- C4: Delete products that are out of stock
DELETE FROM Products
WHERE Stock = 0;

-- Verify deletion
SELECT * FROM Products;

-- C5: Products priced between 500 and 2000
SELECT * FROM Products
WHERE Price BETWEEN 500 AND 2000;

-- C6: Most expensive and cheapest prices
SELECT
    MAX(Price) AS MostExpensivePrice,
    MIN(Price) AS CheapestPrice
FROM Products;

-- Detailed view of most expensive and cheapest products
SELECT * FROM Products
WHERE Price = (SELECT MAX(Price) FROM Products)
   OR Price = (SELECT MIN(Price) FROM Products);

-- ============================================================
-- SECTION D: ORDER DETAILS TABLE QUERIES
-- ============================================================

-- D1: Retrieve all order details
SELECT * FROM OrderDetails;

-- D2: Order details for a specific order
SELECT * FROM OrderDetails
WHERE OrderID = 3;

-- D3: Calculate total revenue using SUM()
SELECT SUM(SubTotal) AS TotalRevenue
FROM OrderDetails;

-- Alternative: Revenue from Orders table
SELECT SUM(TotalAmount) AS TotalRevenue
FROM [Orders];

-- D4: Top 3 most ordered products
SELECT TOP (3)
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalQuantityOrdered DESC;

-- D5: Count how many times a product was sold
-- ProductID = 1

SELECT
    p.ProductID,
    p.ProductName,
    COUNT(od.OrderDetailID) AS TimesSold,
    SUM(od.Quantity) AS TotalUnitsSold
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
WHERE p.ProductID = 1
GROUP BY
    p.ProductID,
    p.ProductName;

-- ============================================================
-- END OF DATA DIGGER PROJECT
-- ============================================================
