CREATE DATABASE CREDITCARD_FRAUD;
USE CREDITCARD_FRAUD;

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(50),
    City VARCHAR(50),
    Email VARCHAR(50)
);

-- Credit Cards Table
CREATE TABLE CreditCards (
    CardID INT PRIMARY KEY,
    CustomerID INT,
    CardNumber VARCHAR(16),
    CardType VARCHAR(20),
    ExpiryDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Transactions Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    CardID INT,
    TransactionDateTime DATETIME,
    Location VARCHAR(50),
    Amount DECIMAL(10,2),
    Merchant VARCHAR(50),
    IsFraud BOOLEAN DEFAULT 0,
    FOREIGN KEY (CardID) REFERENCES CreditCards(CardID)
);

Select * from transactions;

-- Total Transactions & Fraud Percentage
SELECT 
    COUNT(*) AS TotalTransactions,
    SUM(IsFraud) AS FraudulentTransactions,
    ROUND(SUM(IsFraud)*100.0 / COUNT(*),2) AS FraudPercentage
FROM Transactions;

-- High-Value Transactions (> ₹10,000)
SELECT t.TransactionID , c.Name , t.Amount , t.Location , t.TransactionDateTime 
FROM transactions t
join creditcards cc on t.CardID = cc.CardID
join customers c on cc.CustomerID = c.CustomerID
where t.Amount > 10000;

--  Multiple Transactions in < 5 Minutes (Potential Fraud)
SELECT t1.TransactionID, t2.TransactionID, c.Name, 
       t1.TransactionDateTime, t2.TransactionDateTime, t1.Location, t2.Location
FROM Transactions t1
JOIN Transactions t2 ON t1.CardID = t2.CardID 
  AND t2.TransactionDateTime BETWEEN t1.TransactionDateTime AND DATE_ADD(t1.TransactionDateTime, INTERVAL 5 MINUTE)
  AND t1.TransactionID <> t2.TransactionID
JOIN CreditCards cc ON t1.CardID = cc.CardID
JOIN Customers c ON cc.CustomerID = c.CustomerID
ORDER BY c.Name, t1.TransactionDateTime;

-- Impossible Travel (Different Cities within 10 Min)
SELECT t1.TransactionID, t2.TransactionID, c.Name, t1.Location, t2.Location,
       TIMESTAMPDIFF(MINUTE, t1.TransactionDateTime, t2.TransactionDateTime) AS TimeDiffMin
FROM Transactions t1
JOIN Transactions t2 ON t1.CardID = t2.CardID
  AND t1.TransactionID < t2.TransactionID
  AND t1.Location <> t2.Location
  AND TIMESTAMPDIFF(MINUTE, t1.TransactionDateTime, t2.TransactionDateTime) <= 10
JOIN CreditCards cc ON t1.CardID = cc.CardID
JOIN Customers c ON cc.CustomerID = c.CustomerID
ORDER BY c.Name;

-- Rank Customers by Fraudulent Transactions (Window Function)
SELECT c.Name, COUNT(*) AS FraudCount,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS FraudRank
FROM Customers c
JOIN CreditCards cc ON c.CustomerID = cc.CustomerID
JOIN Transactions t ON cc.CardID = t.CardID
WHERE t.IsFraud = 1
GROUP BY c.Name;





