CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY,
    store_location VARCHAR(255) NOT NULL,
    store_manager VARCHAR(255),
    store_opening_date DATE
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    store_id INTEGER,
    employee_name VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    hire_date DATE,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE staff_rota (
    rota_id SERIAL PRIMARY KEY,
    store_id INTEGER,
    employee_id INTEGER,
    shift_date DATE NOT NULL,
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    store_id INTEGER,
    employee_id INTEGER,
    payment_method VARCHAR(50),
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE product_categories (
    product_category_id SERIAL PRIMARY KEY,
    product_category VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE product_types (
    product_type_id SERIAL PRIMARY KEY,
    product_type VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_category_id INTEGER,
    product_type_id INTEGER,
    product_detail VARCHAR(255) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    supplier VARCHAR(255),
    FOREIGN KEY (product_category_id) REFERENCES product_categories(product_category_id),
    FOREIGN KEY (product_type_id) REFERENCES product_types(product_type_id)
);

CREATE TABLE store_inventory (
    inventory_id SERIAL PRIMARY KEY,
    store_id INTEGER,
    product_id INTEGER,
    stock_quantity INTEGER DEFAULT 0,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE transaction_details (
    transaction_detail_id SERIAL PRIMARY KEY,
    transaction_id INTEGER,
    product_id INTEGER,
    transaction_qty INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE customer_loyalty (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    total_points INTEGER DEFAULT 0,
    membership_tier VARCHAR(50)
);

CREATE TABLE customer_transactions (
    customer_transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    transaction_id INTEGER,
    points_earned INTEGER DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customer_loyalty(customer_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

-- Enhancements:
-- 1. Added `employees` table to track staff handling transactions.
-- 2. Added `payment_method` and `total_amount` to `transactions` for detailed sales tracking.
-- 3. Introduced `store_inventory` for per-store inventory tracking.
-- 4. Added `discount_applied` to `transaction_details` for discount tracking.
-- 5. Created `customer_loyalty` and `customer_transactions` to manage customer loyalty programs.
-- 6. Expanded `stores` with store manager and opening date for store history tracking.
-- 7. Added `staff_rota` table to assign employees to shifts at specific stores.
-- 8. Added `cost price` to `products` to enable better profit tracking 
