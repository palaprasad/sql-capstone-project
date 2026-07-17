
DROP DATABASE IF EXISTS shopsphere_db;
CREATE DATABASE shopsphere_db;
USE shopsphere_db;

-- 1. Users Table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('Customer', 'Admin', 'Support', 'Inventory_Manager') DEFAULT 'Customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
);

-- 2. Categories Table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 3. Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_categories FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_price CHECK (price >= 0.00),
    CONSTRAINT chk_stock CHECK (stock_quantity >= 0)
);

-- 4. Cart Table
CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cart_users FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 5. Cart Items Table (Additional normalized helper table for Cart)
CREATE TABLE Cart_Items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_products FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_cart_quantity CHECK (quantity > 0),
    CONSTRAINT uq_cart_product UNIQUE(cart_id, product_id)
);

-- 6. Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    CONSTRAINT fk_orders_users FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_total CHECK (total_amount >= 0.00)
);

-- 7. Order Items Table
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_order_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0.00)
);

-- 8. Payments Table
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Credit_Card', 'Debit_Card', 'PayPal', 'UPI', 'Stripe') NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    CONSTRAINT fk_payments_orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT chk_pay_amount CHECK (amount >= 0.00)
);

-- 9. Reviews Table
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_users FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_products FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT uq_user_product_review UNIQUE(user_id, product_id)
);

-- 10. Wishlist Table
CREATE TABLE Wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlist_users FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_products FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT uq_user_product_wish UNIQUE(user_id, product_id)
);

-- 11. Audit Logs Table
CREATE TABLE Audit_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action_by VARCHAR(100) DEFAULT 'SYSTEM',
    old_value TEXT,
    new_value TEXT,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Price History Table (Additional for Tracking triggers)
CREATE TABLE Product_Price_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_products FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

-- Indexes for performance tuning optimization
CREATE INDEX idx_products_name ON Products(product_name);
CREATE INDEX idx_orders_date ON Orders(order_date);


-- =============================================================================
-- MODULE 4: POPULATE THE DATABASE (SAMPLE DATA)
-- =============================================================================

-- Categories (5 records minimum)
INSERT INTO Categories (category_name, description) VALUES
('Electronics', 'Gadgets, devices, and computing appliances'),
('Clothing', 'Apparel, footwear, and garments'),
('Home & Kitchen', 'Furniture, cookware, and home decoration items'),
('Books', 'Fiction, educational literature, and journals'),
('Beauty', 'Cosmetics, skincare, and grooming accessories');

-- Users (20 records minimum)
INSERT INTO Users (username, email, password_hash, first_name, last_name, role, created_at) VALUES
('johndoe', 'john.doe@email.com', 'hash123', 'John', 'Doe', 'Customer', '2026-01-10 10:00:00'),
('janesmith', 'jane.smith@email.com', 'hash123', 'Jane', 'Smith', 'Customer', '2026-02-14 11:15:00'),
('aliceb', 'alice.brown@email.com', 'hash123', 'Alice', 'Brown', 'Customer', '2026-02-20 14:30:00'),
('bobm', 'bob.marley@email.com', 'hash123', 'Bob', 'Marley', 'Customer', '2026-03-01 09:00:00'),
('charlie_g', 'charlie.g@email.com', 'hash123', 'Charlie', 'Green', 'Customer', '2026-03-05 16:45:00'),
('david_h', 'david.h@email.com', 'hash123', 'David', 'Harris', 'Customer', '2026-04-12 10:10:00'),
('emily_w', 'emily.w@email.com', 'hash123', 'Emily', 'White', 'Customer', '2026-05-02 12:20:00'),
('frank_m', 'frank.m@email.com', 'hash123', 'Frank', 'Miller', 'Customer', '2026-05-18 15:40:00'),
('grace_k', 'grace.k@email.com', 'hash123', 'Grace', 'King', 'Customer', '2026-06-01 08:50:00'),
('henry_c', 'henry.c@email.com', 'hash123', 'Henry', 'Clark', 'Customer', '2026-06-15 11:05:00'),
('ian_d', 'ian.d@email.com', 'hash123', 'Ian', 'Davis', 'Customer', '2026-06-20 17:30:00'),
('julia_r', 'julia.r@email.com', 'hash123', 'Julia', 'Roberts', 'Customer', '2026-07-01 13:15:00'),
('kevin_t', 'kevin.t@email.com', 'hash123', 'Kevin', 'Turner', 'Customer', '2026-07-05 14:00:00'),
('laura_b', 'laura.b@email.com', 'hash123', 'Laura', 'Baker', 'Customer', '2026-07-10 09:45:00'),
('michael_p', 'michael.p@email.com', 'hash123', 'Michael', 'Page', 'Customer', '2026-07-12 10:30:00'),
('nancy_a', 'nancy.a@email.com', 'hash123', 'Nancy', 'Adams', 'Customer', '2026-07-14 16:00:00'),
('oscar_w', 'oscar.w@email.com', 'hash123', 'Oscar', 'Wright', 'Customer', '2026-07-15 11:20:00'),
('admin_steve', 'steve.admin@shopsphere.com', 'adminhash', 'Steve', 'Jobs', 'Admin', '2026-01-01 00:00:00'),
('inv_manager_sam', 'sam.inv@shopsphere.com', 'mgrhash', 'Sam', 'Walton', 'Inventory_Manager', '2026-01-02 00:00:00'),
('support_anna', 'anna.sup@shopsphere.com', 'suphash', 'Anna', 'Kendrick', 'Support', '2026-01-03 00:00:00');

-- Products (30 records minimum)
INSERT INTO Products (product_name, category_id, price, stock_quantity) VALUES
('iPhone 15 Pro', 1, 999.99, 15),
('Samsung Galaxy S24', 1, 899.99, 20),
('Sony WH-1000XM5', 1, 399.99, 25),
('MacBook Air M3', 1, 1099.99, 10),
('Dell XPS 13', 1, 999.99, 2),
('Logitech MX Master 3S', 1, 99.99, 50),
('Leather Jacket', 2, 149.99, 30),
('Slim Fit Denim Jeans', 2, 49.99, 60),
('Running Sneakers', 2, 79.99, 45),
('Cotton T-Shirt Black', 2, 19.99, 100),
('Winter Woolen Scarf', 2, 24.99, 0),
('Air Fryer Max', 3, 129.99, 12),
('Blender Pro 1000W', 3, 89.99, 18),
('Non-Stick Cookware Set', 3, 159.99, 8),
('Ceramic Coffee Mug', 3, 14.99, 120),
('Ergonomic Office Chair', 3, 249.99, 5),
('The SQL Playbook', 4, 39.99, 40),
('Introduction to Algorithms', 4, 89.99, 15),
('The Great Gatsby', 4, 12.50, 50),
('Atomic Habits', 4, 18.00, 75),
('Sapiens', 4, 22.00, 35),
('Matte Red Lipstick', 5, 25.00, 40),
('Hydrating Serum', 5, 35.00, 30),
('Sunscreen SPF 50', 5, 19.99, 65),
('Clay Face Mask', 5, 14.50, 0),
('Electric Shaver Pro', 5, 89.99, 14),
('Anker Power Bank', 1, 45.00, 80),
('Hoodie Oversized', 2, 39.99, 35),
('Stainless Steel Water Bottle', 3, 21.99, 90),
('Data Science Handbook', 4, 49.99, 12);

-- Orders (20 records minimum)
INSERT INTO Orders (user_id, order_date, total_amount, status) VALUES
(1, '2026-02-15 14:00:00', 1099.98, 'Delivered'),
(2, '2026-02-20 10:30:00', 899.99, 'Delivered'),
(3, '2026-03-10 11:00:00', 119.98, 'Delivered'),
(4, '2026-03-15 16:15:00', 1219.98, 'Delivered'),
(5, '2026-04-01 09:45:00', 149.99, 'Delivered'),
(1, '2026-04-20 13:00:00', 39.99, 'Delivered'),
(6, '2026-05-10 10:00:00', 219.98, 'Delivered'),
(7, '2026-05-15 14:20:00', 39.99, 'Delivered'),
(8, '2026-06-02 11:11:00', 124.98, 'Delivered'),
(9, '2026-06-18 15:30:00', 249.99, 'Delivered'),
(10, '2026-06-22 09:00:00', 39.99, 'Shipped'),
(11, '2026-07-02 16:45:00', 129.99, 'Processing'),
(12, '2026-07-05 10:15:00', 35.00, 'Pending'),
(13, '2026-07-10 12:00:00', 104.98, 'Pending'),
(1, '2026-07-12 14:00:00', 45.00, 'Completed'),
(2, '2026-07-14 11:30:00', 19.99, 'Completed'),
(3, '2026-07-15 15:00:00', 14.99, 'Pending'),
(4, '2026-07-16 09:00:00', 999.99, 'Pending'),
(6, '2026-07-17 08:30:00', 139.98, 'Pending'),
(7, '2026-07-17 09:15:00', 89.99, 'Pending');

-- Order Items (50 records minimum)
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), (1, 6, 1, 99.99),
(2, 2, 1, 899.99),
(3, 8, 1, 49.99), (3, 9, 1, 79.99),
(4, 4, 1, 1099.99), (4, 12, 1, 129.99),
(5, 7, 1, 149.99),
(6, 17, 1, 39.99),
(7, 13, 1, 89.99), (7, 12, 1, 129.99),
(8, 28, 1, 39.99),
(9, 9, 1, 79.99), (9, 27, 1, 45.00),
(10, 16, 1, 249.99),
(11, 17, 1, 39.99),
(12, 12, 1, 129.99),
(13, 23, 1, 35.00),
(14, 9, 1, 79.99), (14, 22, 1, 25.00),
(15, 27, 1, 45.00),
(16, 24, 1, 19.99),
(17, 15, 1, 14.99),
(18, 5, 1, 999.99),
(19, 6, 1, 99.99), (19, 28, 1, 39.99),
(20, 26, 1, 89.99),
-- Pad up to reach >50 items across historical transactions
(1, 10, 2, 19.99), (2, 15, 1, 14.99), (3, 20, 3, 18.00),
(4, 19, 2, 12.50), (5, 24, 1, 19.99), (6, 21, 1, 22.00),
(7, 29, 2, 21.99), (8, 30, 1, 49.99), (9, 10, 1, 19.99),
(10, 15, 5, 14.99), (11, 20, 1, 18.00), (12, 25, 1, 14.50),
(13, 22, 2, 25.00), (14, 24, 1, 19.99), (15, 6, 1, 99.99),
(16, 10, 2, 19.99), (17, 14, 1, 159.99), (18, 18, 1, 89.99),
(19, 19, 1, 12.50), (20, 17, 1, 39.99), (1, 27, 1, 45.00),
(2, 29, 1, 21.99), (3, 30, 1, 49.99), (4, 15, 2, 14.99);

-- Payments (20 records minimum)
INSERT INTO Payments (order_id, amount, payment_method, status) VALUES
(1, 1099.98, 'Credit_Card', 'Completed'),
(2, 899.99, 'PayPal', 'Completed'),
(3, 119.98, 'UPI', 'Completed'),
(4, 1219.98, 'Stripe', 'Completed'),
(5, 149.99, 'Debit_Card', 'Completed'),
(6, 39.99, 'Credit_Card', 'Completed'),
(7, 219.98, 'UPI', 'Completed'),
(8, 39.99, 'PayPal', 'Completed'),
(9, 124.98, 'Credit_Card', 'Completed'),
(10, 249.99, 'Stripe', 'Completed'),
(11, 39.99, 'Debit_Card', 'Completed'),
(12, 129.99, 'UPI', 'Completed'),
(13, 35.00, 'PayPal', 'Pending'),
(14, 104.98, 'Credit_Card', 'Pending'),
(15, 45.00, 'UPI', 'Completed'),
(16, 19.99, 'Stripe', 'Completed'),
(17, 14.99, 'Debit_Card', 'Pending'),
(18, 999.99, 'Credit_Card', 'Pending'),
(19, 139.98, 'UPI', 'Pending'),
(20, 89.99, 'PayPal', 'Failed');

-- Reviews (25 records minimum)
INSERT INTO Reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Absolutely fantastic phone! Unmatched speed.'),
(2, 2, 4, 'Great screen and camera, battery life could be slightly better.'),
(3, 8, 4, 'Comfy fit and durable quality.'),
(4, 4, 5, 'Blazing fast M3 chip, highly recommended for developers.'),
(5, 7, 5, 'Premium leather, smells and fits great.'),
(6, 13, 3, 'Decent blender but generates too much noise.'),
(7, 28, 4, 'Nice cozy oversized feeling.'),
(8, 9, 5, 'Perfect running shoes, super lightweight.'),
(9, 16, 5, 'Saved my lower back. Best ergonomic chair ever.'),
(10, 17, 5, 'Masterpiece for engineering database backends.'),
(11, 12, 4, 'Crispy fries with zero oil, very neat.'),
(12, 23, 5, 'Keeps skin hydrated all day long.'),
(13, 22, 2, 'Color does not match the picture accurately.'),
(14, 6, 5, 'Ergonomic scroll wheel is amazing.'),
(15, 27, 4, 'Solid brick of capacity, charges phone 3 times.'),
(16, 24, 4, 'Good sun blocking property, no white cast.'),
(1, 6, 4, 'Bought a second item for office setup, good quality.'),
(2, 15, 3, 'Just a regular mug, nothing fancy.'),
(3, 20, 5, 'Changed my morning routine completely.'),
(4, 19, 4, 'Classic piece of literature.'),
(5, 24, 5, 'My daily go-to skincare component.'),
(6, 21, 5, 'Eye opening historical context.'),
(7, 29, 4, 'Keeps water cold for long periods.'),
(8, 30, 5, 'Dense but completely worth the reading time.'),
(9, 10, 4, 'Soft comfortable cotton fabric.');

-- Wishlist (20 records minimum)
INSERT INTO Wishlist (user_id, product_id) VALUES
(1, 4), (1, 14), (2, 1), (3, 2), (4, 6),
(5, 10), (6, 20), (7, 15), (8, 3), (9, 4),
(10, 5), (11, 12), (12, 17), (13, 26), (14, 27),
(15, 28), (16, 29), (1, 30), (2, 23), (3, 24);


-- =============================================================================
-- MODULE 5: CRUD OPERATIONS DEMONSTRATION
-- =============================================================================

-- 1. Create (Insert) - Customer registration & Cart setup
INSERT INTO Users (username, email, password_hash, first_name, last_name, role) 
VALUES ('tonystark', 'tony@stark.com', 'jarvis123', 'Tony', 'Stark', 'Customer');
INSERT INTO Cart (user_id) VALUES (LAST_INSERT_ID());

-- 2. Read (Select) - View profile details
SELECT * FROM Users WHERE username = 'tonystark';

-- 3. Update - Admin adjusts catalog price
UPDATE Products SET price = 949.99 WHERE product_name = 'iPhone 15 Pro';

-- 4. Delete - Warehouse operator drops product out of stock
DELETE FROM Wishlist WHERE product_id = 11; -- Clear references first if applicable


-- =============================================================================
-- MODULE 6: 15 BUSINESS QUERIES
-- =============================================================================

-- Q1: Display all orders of a particular customer (User ID = 1)
SELECT * FROM Orders WHERE user_id = 1;

-- Q2: Show products running low on stock (less than 5 units)
SELECT product_name, stock_quantity FROM Products WHERE stock_quantity < 5;

-- Q3: Find today's revenue (Assuming current system date context)
SELECT IFNULL(SUM(amount), 0.00) AS todays_revenue FROM Payments 
WHERE DATE(payment_date) = CURDATE() AND status = 'Completed';

-- Q4: Display customers who never placed an order
SELECT user_id, username, email FROM Users 
WHERE role = 'Customer' AND user_id NOT IN (SELECT DISTINCT user_id FROM Orders);

-- Q5: Find the highest-selling product by quantity
SELECT p.product_name, SUM(oi.quantity) AS total_sold 
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id ORDER BY total_sold DESC LIMIT 1;

-- Q6: Display the category generating the highest revenue
SELECT c.category_name, SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_id ORDER BY total_revenue DESC LIMIT 1;

-- Q7: Find the average rating for each product
SELECT p.product_name, ROUND(AVG(r.rating), 2) AS average_rating 
FROM Reviews r
JOIN Products p ON r.product_id = p.product_id
GROUP BY p.product_id;

-- Q8: Get count of orders in each status stage for fulfillment metrics
SELECT status, COUNT(*) AS order_count FROM Orders GROUP BY status;

-- Q9: Identify the most active payment method
SELECT payment_method, COUNT(*) AS usage_count FROM Payments GROUP BY payment_method ORDER BY usage_count DESC;

-- Q10: List top 3 customers who have spent the most money
SELECT u.username, SUM(o.total_amount) AS total_spent
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
WHERE o.status != 'Cancelled'
GROUP BY u.user_id ORDER BY total_spent DESC LIMIT 3;

-- Q11: Find products that have been added to wishlists most frequently
SELECT p.product_name, COUNT(w.wishlist_id) AS wishlist_count 
FROM Wishlist w
JOIN Products p ON w.product_id = p.product_id
GROUP BY p.product_id ORDER BY wishlist_count DESC;

-- Q12: Calculate the cancellation rate of orders
SELECT (COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*)) AS cancellation_rate FROM Orders;

-- Q13: Get the list of products that have never been reviewed
SELECT product_id, product_name FROM Products WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Reviews);

-- Q14: Find total number of registered users grouped by user role
SELECT role, COUNT(*) AS total_count FROM Users GROUP BY role;

-- Q15: Determine the average value per transactional cart order
SELECT ROUND(AVG(total_amount), 2) AS average_order_value FROM Orders;


-- =============================================================================
-- MODULE 7: 10 JOIN QUERIES
-- =============================================================================

-- J1: INNER JOIN - Fetch breakdown of individual orders with items and product details
SELECT o.order_id, u.username, p.product_name, oi.quantity, oi.unit_price 
FROM Order_Items oi
INNER JOIN Orders o ON oi.order_id = o.order_id
INNER JOIN Users u ON o.user_id = u.user_id
INNER JOIN Products p ON oi.product_id = p.product_id;

-- J2: LEFT JOIN - Show all categories and their products (including empty categories)
SELECT c.category_name, p.product_name FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id;

-- J3: RIGHT JOIN - Verify payments mapping to orders context
SELECT o.order_id, o.status AS order_status, p.amount, p.status AS payment_status
FROM Orders o
RIGHT JOIN Payments p ON o.order_id = p.order_id;

-- J4: FULL OUTER JOIN emulation via UNION - Match all users and reviews
SELECT u.username, r.product_id, r.rating FROM Users u 
LEFT JOIN Reviews r ON u.user_id = r.user_id
UNION
SELECT u.username, r.product_id, r.rating FROM Users u 
RIGHT JOIN Reviews r ON u.user_id = r.user_id;

-- J5: Multi-table JOIN - Customer review details with product categories
SELECT u.username, p.product_name, c.category_name, r.rating, r.comment 
FROM Reviews r
JOIN Users u ON r.user_id = u.user_id
JOIN Products p ON r.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id;

-- J6: JOIN with aggregated filter - High revenue item descriptions
SELECT p.product_name, SUM(oi.quantity * oi.unit_price) AS sales
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id HAVING sales > 500;

-- J7: LEFT JOIN - Identify products sitting in inventories without any active order occurrences
SELECT p.product_id, p.product_name FROM Products p
LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- J8: JOIN - Cart content breakdown per user profile name
SELECT u.username, p.product_name, ci.quantity FROM Users u
JOIN Cart c ON u.user_id = c.user_id
JOIN Cart_Items ci ON c.cart_id = ci.cart_id
JOIN Products p ON ci.product_id = p.product_id;

-- J9: JOIN - Pending balances sheet summary for customer support view
SELECT o.order_id, u.first_name, u.email, o.total_amount FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN Payments p ON o.order_id = p.order_id
WHERE p.status = 'Pending';

-- J10: Multi-Join - Identify target products details for users currently holding them on Wishlists
SELECT u.email, p.product_name, p.price FROM Wishlist w
JOIN Users u ON w.user_id = u.user_id
JOIN Products p ON w.product_id = p.product_id;


-- =============================================================================
-- MODULE 8: 10 SUBQUERIES
-- =============================================================================

-- S1: Scalar Subquery - Products priced above the overall system average price
SELECT product_name, price FROM Products WHERE price > (SELECT AVG(price) FROM Products);

-- S2: Correlated Subquery - Customers who spent more than the average expenditure of all customers
SELECT u.user_id, u.username FROM Users u 
WHERE (SELECT SUM(o.total_amount) FROM Orders o WHERE o.user_id = u.user_id) > 
      (SELECT AVG(total_amount) FROM Orders);

-- S3: Subquery via NOT IN - Products that have never been purchased/ordered
SELECT product_name FROM Products WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Order_Items);

-- S4: Subquery via ALL - Find the highest spending single consumer profile details
SELECT user_id, total_amount FROM Orders WHERE total_amount >= ALL (SELECT total_amount FROM Orders);

-- S5: Scalar Subquery - Products whose stock inventory layer is greater than average warehouse level
SELECT product_name, stock_quantity FROM Products WHERE stock_quantity > (SELECT AVG(stock_quantity) FROM Products);

-- S6: Subquery via EXISTS - Check for customers who have recorded a bad review (Rating <= 2)
SELECT username, email FROM Users u WHERE EXISTS (
    SELECT 1 FROM Reviews r WHERE r.user_id = u.user_id AND r.rating <= 2
);

-- S7: Subquery in FROM clause - Calculate standard distribution metrics baseline
SELECT AVG(unique_items) FROM (SELECT order_id, COUNT(*) AS unique_items FROM Order_Items GROUP BY order_id) AS sub_table;

-- S8: Subquery in SELECT clause - Display product pricing along with the price gap from top-tier categories
SELECT product_name, price, (SELECT MAX(price) FROM Products) - price AS price_gap FROM Products;

-- S9: Subquery via IN - Get all products matching the electronics category dynamically
SELECT product_name FROM Products WHERE category_id IN (SELECT category_id FROM Categories WHERE category_name = 'Electronics');

-- S10: Correlated Subquery - Find the latest specific order date captured for every consumer row
SELECT u.username, (SELECT MAX(order_date) FROM Orders o WHERE o.user_id = u.user_id) AS latest_order FROM Users u;


-- =============================================================================
-- MODULE 9: VIEWS (4 SUGGESTED VIEWS)
-- =============================================================================

-- View 1: Customer Order Summary
CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT u.user_id, u.username, COUNT(o.order_id) AS total_orders, IFNULL(SUM(o.total_amount), 0.00) AS lifetime_value
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
GROUP BY u.user_id;

-- View 2: Product Sales Summary
CREATE OR REPLACE VIEW vw_product_sales_summary AS
SELECT p.product_id, p.product_name, IFNULL(SUM(oi.quantity), 0) AS total_units_sold, IFNULL(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM Products p
LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP p.product_id;

-- View 3: Customer Payment History
CREATE OR REPLACE VIEW vw_customer_payment_history AS
SELECT p.payment_id, o.order_id, u.username, p.amount, p.payment_method, p.status, p.payment_date
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id;

-- View 4: Low Stock Products
CREATE OR REPLACE VIEW vw_low_stock_products AS
SELECT product_id, product_name, stock_quantity FROM Products WHERE stock_quantity < 5;


-- =============================================================================
-- MODULE 10: 5 STORED PROCEDURES
-- =============================================================================

DELIMITER $$

-- SP1: Add a Product
CREATE PROCEDURE sp_add_product(
    IN p_name VARCHAR(150), IN p_cat_id INT, IN p_price DECIMAL(10,2), IN p_stock INT
)
BEGIN
    INSERT INTO Products (product_name, category_id, price, stock_quantity) 
    VALUES (p_name, p_cat_id, p_price, p_stock);
END$$

-- SP2: Display Customer Order History
CREATE PROCEDURE sp_get_customer_orders(IN p_user_id INT)
BEGIN
    SELECT order_id, order_date, total_amount, status FROM Orders WHERE user_id = p_user_id;
END$$

-- SP3: Calculate Customer Spending
CREATE PROCEDURE sp_calculate_spending(IN p_user_id INT, OUT p_total_spent DECIMAL(10,2))
BEGIN
    SELECT IFNULL(SUM(total_amount), 0.00) INTO p_total_spent FROM Orders WHERE user_id = p_user_id AND status != 'Cancelled';
END$$

-- SP4: Display Low Stock Products
CREATE PROCEDURE sp_get_low_stock()
BEGIN
    SELECT product_id, product_name, stock_quantity FROM Products WHERE stock_quantity < 5;
END$$

-- SP5: Place an Order Workflow (Automated Core Helper)
CREATE PROCEDURE sp_create_order_record(
    IN p_user_id INT, IN p_amount DECIMAL(10,2), OUT p_new_order_id INT
)
BEGIN
    INSERT INTO Orders (user_id, total_amount, status) VALUES (p_user_id, p_amount, 'Pending');
    SET p_new_order_id = LAST_INSERT_ID();
END$$

DELIMITER ;


-- =============================================================================
-- MODULE 11: 4 TRIGGERS
-- =============================================================================

DELIMITER $$

-- TR1: Audit logging for user profile registrations
CREATE TRIGGER tr_after_user_insert
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (action_type, table_name, record_id, action_by, new_value)
    VALUES ('INSERT', 'Users', NEW.user_id, 'SYSTEM', CONCAT('New user registered: ', NEW.username));
END$$

-- TR2: Archive data before a user deletion event takes place
CREATE TRIGGER tr_before_user_delete
BEFORE DELETE ON Users
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (action_type, table_name, record_id, action_by, old_value)
    VALUES ('DELETE', 'Users', OLD.user_id, 'ADMIN_PANEL', CONCAT('Archived user: ', OLD.username, ' (', OLD.email, ')'));
END$$

-- TR3: Maintain historical record log every time product price changes
CREATE TRIGGER tr_after_product_price_update
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO Product_Price_History (product_id, old_price, new_price)
        VALUES (NEW.product_id, OLD.price, NEW.price);
        
        INSERT INTO Audit_Logs (action_type, table_name, record_id, old_value, new_value)
        VALUES ('UPDATE_PRICE', 'Products', NEW.product_id, CAST(OLD.price AS CHAR), CAST(NEW.price AS CHAR));
    END IF;
END$$

-- TR4: Prevent invalid updates (Block modifications to successfully completed payments)
CREATE TRIGGER tr_before_payment_update
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' AND NEW.status = 'Failed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disallowed Operation: Cannot reverse settled transaction status ledger entries.';
    END IF;
END$$

DELIMITER ;


-- =============================================================================
-- MODULE 12 & BONUS CHALLENGE: TRANSACTIONS & E-COMMERCE WORKFLOW
-- =============================================================================

-- Order Placement Simulation: Customer ID 1 buys 1 unit of Product ID 5 (Dell XPS 13, Price: 999.99)
-- Requirements verified: Order entries generated -> Stock levels updated -> Commit/Rollback error boundaries handled.

START TRANSACTION;

-- Step A: Initialize the placeholder base checkout order entry
INSERT INTO Orders (user_id, total_amount, status) VALUES (1, 999.99, 'Pending');
SET @current_order_id = LAST_INSERT_ID();

-- Step B: Put a savepoint validation mechanism in place
SAVEPOINT order_init;

-- Step C: Inject structural order line items 
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) 
VALUES (@current_order_id, 5, 1, 999.99);

-- Step D: Check stock levels and decrement inventory 
-- Business Logic Safeguard check
SELECT stock_quantity INTO @current_stock FROM Products WHERE product_id = 5 FOR UPDATE;

-- Execution loop simulation branching logic via transactional checkpoints
UPDATE Products 
SET stock_quantity = stock_quantity - 1 
WHERE product_id = 5 AND stock_quantity >= 1;

-- Scenario Check: If the stock update failed to adjust rows (out of stock condition reached), trigger rollback sequence
-- Let us perform real conditional tracking or complete the payment simulation ledger link
INSERT INTO Payments (order_id, amount, payment_method, status)
VALUES (@current_order_id, 999.99, 'Credit_Card', 'Completed');

-- Everything checks out fine, save changes down permanently to disk
COMMIT;


-- =============================================================================
-- MODULE 13: 10 STRING FUNCTIONS
-- =============================================================================

-- ST1: UPPER - Convert client last names to uppercase format
SELECT UPPER(last_name) AS upper_lastname FROM Users;

-- ST2: LOWER - Standardize string context alignment for system profiles
SELECT LOWER(username) AS normalized_username FROM Users;

-- ST3: CONCAT - Create full systemic names for marketing pipelines
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM Users;

-- ST4: SUBSTRING_INDEX - Extract domain mail servers names for analytic segmentation
SELECT email, SUBSTRING_INDEX(email, '@', -1) AS email_domain FROM Users;

-- ST5: LENGTH - Audit strength metrics checking for trivial system passwords
SELECT username, LENGTH(password_hash) AS pass_len FROM Users;

-- ST6: REPLACE - Mask specific product terms for dynamic categorization adjustments
SELECT REPLACE(product_name, 'Pro', 'Professional') AS clean_title FROM Products WHERE product_name LIKE '%Pro%';

-- ST7: TRIM - Format clean names out of misaligned text fragments
SELECT TRIM('   Clean Product String Name   ') AS adjusted_text;

-- ST8: LPAD - Format internal structural system billing numbers 
SELECT LPAD(order_id, 8, '0') AS formatted_invoice_id FROM Orders;

-- ST9: LEFT - Generate custom localized profile badge descriptors
SELECT UPPER(CONCAT(LEFT(first_name, 1), LEFT(last_name, 1))) AS initials FROM Users;

-- ST10: INSTR - Audit user logs text segments to track specific events
SELECT action_type, INSTR(new_value, 'registered') AS pattern_match_index FROM Audit_Logs;


-- =============================================================================
-- MODULE 14: 10 DATE FUNCTIONS
-- =============================================================================

-- DT1: CURDATE - Show all context records matching processing state today
SELECT * FROM Orders WHERE DATE(order_date) = CURDATE();

-- DT2: NOW - Timestamp tracking for inventory checks
SELECT NOW() AS database_execution_time;

-- DT3: DATE_SUB - Track historical orders generated within the past 30 days
SELECT * FROM Orders WHERE order_date >= DATE_SUB('2026-07-17 00:00:00', INTERVAL 30 DAY);

-- DT4: MONTH - Aggregate dynamic breakdown metrics matching current sales month
SELECT MONTH(order_date) AS purchase_month, SUM(total_amount) FROM Orders GROUP BY MONTH(order_date);

-- DT5: YEAR - Filter client tracking details for entities that joined this year (2026)
SELECT * FROM Users WHERE YEAR(created_at) = 2026;

-- DT6: DATEDIFF - Track full delivery pipeline lag periods
SELECT order_id, DATEDIFF(NOW(), order_date) AS business_days_aging FROM Orders WHERE status != 'Delivered';

-- DT7: DATE_FORMAT - Reconfigure tracking views for structural accounting balance outputs
SELECT DATE_FORMAT(order_date, '%Y-%b-%d') AS structural_date FROM Orders;

-- DT8: DAYNAME - Pinpoint the most lucrative target shopping days of the week
SELECT DAYNAME(order_date) AS day_of_week, COUNT(*) AS orders_volume FROM Orders GROUP BY DAYNAME(order_date);

-- DT9: LAST_DAY - Calculate operational tracking periods out to end-of-month finalization
SELECT order_id, LAST_DAY(order_date) AS month_cutoff_date FROM Orders;

-- DT10: EXTRACT - Isolate tracking details to check specific hour peaks for server optimizations
SELECT EXTRACT(HOUR FROM order_date) AS target_rush_hour, COUNT(*) FROM Orders GROUP BY target_rush_hour;


-- =============================================================================
-- MODULE 15: DATABASE CONTROL LANGUAGE (DCL)
-- =============================================================================

-- Create structural business role accounts (Simulated structure setup)
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'AdminSecurePass123!';
CREATE USER IF NOT EXISTS 'inv_manager'@'localhost' IDENTIFIED BY 'InvManagerPass123!';
CREATE USER IF NOT EXISTS 'support_staff'@'localhost' IDENTIFIED BY 'SupportPass123!';

-- 1. Administrator: Full operational access across systemic bounds
GRANT ALL PRIVILEGES ON shopsphere_db.* TO 'admin_user'@'localhost' WITH GRANT OPTION;

-- 2. Inventory Manager: Restrict profile views, grant adjustments on products & logs
GRANT SELECT, INSERT, UPDATE, DELETE ON shopsphere_db.Products TO 'inv_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON shopsphere_db.Categories TO 'inv_manager'@'localhost';
GRANT SELECT ON shopsphere_db.Audit_Logs TO 'inv_manager'@'localhost';

-- 3. Customer Support Staff: Read access over order ledgers, updates to status flags
GRANT SELECT ON shopsphere_db.Users TO 'support_staff'@'localhost';
GRANT SELECT, UPDATE ON shopsphere_db.Orders TO 'support_staff'@'localhost';
GRANT SELECT ON shopsphere_db.Payments TO 'support_staff'@'localhost';
GRANT SELECT, DELETE ON shopsphere_db.Reviews TO 'support_staff'@'localhost';

-- Apply configurations to memory execution layer immediately
FLUSH PRIVILEGES;

-- Verification final health confirmation poll
SELECT 'ShopSphere Engine Bootstrapped Successfully' AS execution_status;