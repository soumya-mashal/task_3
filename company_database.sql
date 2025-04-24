-- Create a new database (schema) for e-commerce
CREATE DATABASE IF NOT EXISTS ecommerce_db;

-- Use the e-commerce database
USE ecommerce_db;

-- Create the Customers table
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    City VARCHAR(100),
    RegistrationDate DATE
);

-- Create the Orders table
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    OrderStatus VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create the Products table
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2)
);

-- Create the OrderItems table (for many-to-many relationship between Orders and Products)
CREATE TABLE IF NOT EXISTS OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert sample data into Customers
INSERT INTO Customers (Name, Email, City, RegistrationDate) VALUES
('John Smith', 'john.smith@example.com', 'New York', '2023-01-15'),
('Jane Doe', 'jane.doe@example.com', 'Los Angeles', '2023-02-20'),
('David Johnson', 'david.johnson@example.com', 'Chicago', '2023-03-10'),
('Sarah Williams', 'sarah.williams@example.com', 'New York', '2023-04-05'),
('Michael Brown', 'michael.brown@example.com', 'Houston', '2023-05-12');

-- Insert sample data into Orders
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, OrderStatus) VALUES
(1, '2023-03-01', 150.00, 'Shipped'),
(2, '2023-03-15', 200.00, 'Delivered'),
(1, '2023-04-01', 100.00, 'Pending'),
(3, '2023-04-10', 250.00, 'Shipped'),
(4, '2023-05-01', 175.00, 'Delivered'),
(2, '2024-01-10', 300.00, 'Delivered'),
(5, '2024-02-15', 50.00, 'Pending');

-- Insert sample data into Products
INSERT INTO Products (ProductName, Category, Price) VALUES
('Laptop', 'Electronics', 1200.00),
('Mouse', 'Electronics', 25.00),
('Keyboard', 'Electronics', 75.00),
('T-Shirt', 'Clothing', 20.00),
('Jeans', 'Clothing', 50.00),
('Book', 'Books', 15.00),
('Smartphone', 'Electronics', 800.00);

-- Insert sample data into OrderItems
INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 1200.00),  -- Order 1: 1 Laptop
(1, 2, 2, 25.00),    -- Order 1: 2 Mice
(2, 1, 1, 1200.00),  -- Order 2: 1 Laptop
(2, 3, 1, 75.00),    -- Order 2: 1 Keyboard
(3, 4, 3, 20.00),    -- Order 3: 3 T-Shirts
(4, 5, 2, 50.00),    -- Order 4: 2 Jeans
(5, 6, 1, 15.00),    -- Order 5: 1 Book
(6, 1, 2, 1200.00),
(6, 3, 2, 75.00),
(7, 7, 1, 800.00);

-- a. Use SELECT, WHERE, ORDER BY, GROUP BY

-- Select all customers
SELECT * FROM Customers;

-- Select customers from New York
SELECT Name, Email FROM Customers WHERE City = 'New York';

-- Order products by price in descending order
SELECT ProductName, Price FROM Products ORDER BY Price DESC;

-- Group orders by customer and count the number of orders
SELECT CustomerID, COUNT(OrderID) AS NumberOfOrders FROM Orders GROUP BY CustomerID;



-- b. Use JOINS (INNER, LEFT, RIGHT)

-- INNER JOIN: Get customer names and their order details
SELECT Customers.Name, Orders.OrderID, Orders.OrderDate, Orders.TotalAmount
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- LEFT JOIN: Get all customers and their orders (if any)
SELECT Customers.Name, Orders.OrderID
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- RIGHT JOIN: Get all orders and their customer information.  MySQL doesn't directly support RIGHT JOIN,
-- but it can be emulated with LEFT JOIN
SELECT Customers.Name, Orders.OrderID
FROM Orders
LEFT JOIN Customers ON Orders.CustomerID = Customers.CustomerID;



-- c. Write subqueries

-- Find products with a price greater than the average price
SELECT ProductName, Price
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products);

-- Find customers who have placed orders
SELECT CustomerID, Name
FROM Customers
WHERE CustomerID IN (SELECT DISTINCT CustomerID FROM Orders);



-- d. Use aggregate functions (SUM, AVG)

-- Calculate the total revenue from all orders
SELECT SUM(TotalAmount) AS TotalRevenue FROM Orders;

-- Calculate the average order amount
SELECT AVG(TotalAmount) AS AverageOrderAmount FROM Orders;

-- Calculate the highest price of products in each category:
SELECT Category, MAX(Price) AS HighestPrice
FROM Products
GROUP BY Category;



-- e. Create views for analysis

-- Create a view for customer order history
CREATE VIEW CustomerOrderHistory AS
SELECT Customers.CustomerID, Customers.Name, Orders.OrderID, Orders.OrderDate, Orders.TotalAmount, Orders.OrderStatus
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- Query the view
SELECT * FROM CustomerOrderHistory WHERE CustomerID = 1;

-- Create a view to show product details along with order quantities:
CREATE VIEW ProductOrderQuantities AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Price,
    oi.OrderID,
    oi.Quantity
FROM
    Products p
JOIN
    OrderItems oi ON p.ProductID = oi.ProductID;

-- Query the view
SELECT * FROM ProductOrderQuantities WHERE Quantity > 1;



-- f. Optimize queries with indexes

-- Create an index on CustomerID in the Orders table to speed up joins
CREATE INDEX idx_customer_id ON Orders (CustomerID);

-- Create an index on OrderDate to optimize date-based queries
CREATE INDEX idx_order_date ON Orders (OrderDate);

-- Show the indexes for the Orders table
SHOW INDEXES FROM Orders;

-- Example query that would use the index on CustomerID
SELECT Orders.OrderID, Customers.Name
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Orders.CustomerID = 1; -- This WHERE clause can utilize the index

-- drop indexes
-- DROP INDEX idx_customer_id ON Orders;
-- DROP INDEX idx_order_date ON Orders;
