-- Customers table
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name NVARCHAR(100),
    email NVARCHAR(100),
    phone NVARCHAR(20),
    city NVARCHAR(50),
    segment NVARCHAR(50)
);

-- Products table
CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(100),
    category NVARCHAR(50),
    price DECIMAL(10,2)
);

-- Orders table 
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_method NVARCHAR(50),
    order_month VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items table
CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Returns table
CREATE TABLE returns(
    order_id INT,
    return_reason NVARCHAR(100)
);