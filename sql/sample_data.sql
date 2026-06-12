INSERT INTO users (full_name, email, password_hash, role) VALUES
('Admin One', 'admin@smartcart.com', 'hash_admin_001', 'admin'),
('Khizra Bilal', 'khizra@example.com', 'hash_customer_001', 'customer'),
('Ali Raza', 'ali@example.com', 'hash_customer_002', 'customer'),
('Business Manager', 'manager@smartcart.com', 'hash_manager_001', 'manager');

INSERT INTO customers (user_id, phone, address_line, city, country, postal_code) VALUES
(2, '+92-300-1111111', 'Street 10, Model Town', 'Lahore', 'Pakistan', '54000'),
(3, '+92-300-2222222', 'House 44, Gulberg', 'Lahore', 'Pakistan', '54660');

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Phones, laptops, and gadgets'),
('Clothing', 'Shirts, pants, and fashion wear'),
('Footwear', 'Shoes and sandals'),
('Accessories', 'Bags, belts, and watches'),
('Household', 'Kitchen and home essentials');

INSERT INTO suppliers (supplier_name, contact_person, email, phone, address_line, city, country) VALUES
('TechSource Ltd', 'Sara Ahmed', 'sales@techsource.com', '+92-42-1111111', 'Industrial Area Phase 5', 'Lahore', 'Pakistan'),
('Fashion Hub PK', 'Imran Khan', 'orders@fashionhub.pk', '+92-42-2222222', 'Liberty Market', 'Lahore', 'Pakistan'),
('StepWell Footwear', 'Nadia Hussain', 'supply@stepwell.com', '+92-42-3333333', 'Hall Road', 'Lahore', 'Pakistan'),
('HomeEase Supplies', 'Bilal Qureshi', 'contact@homeease.com', '+92-42-4444444', 'Johar Town', 'Lahore', 'Pakistan');

INSERT INTO products (category_id, supplier_id, product_name, description, unit_price, is_active) VALUES
(1, 1, 'Wireless Mouse', 'Ergonomic Bluetooth mouse', 2500.00, TRUE),
(1, 1, 'Mechanical Keyboard', 'RGB gaming keyboard', 8500.00, TRUE),
(2, 2, 'Cotton T-Shirt', 'Unisex round-neck t-shirt', 1800.00, TRUE),
(3, 3, 'Running Shoes', 'Lightweight sports shoes', 6200.00, TRUE),
(4, 2, 'Leather Wallet', 'Genuine leather wallet', 3200.00, TRUE),
(5, 4, 'Non-Stick Pan Set', '3-piece kitchen pan set', 4500.00, TRUE),
(1, 1, 'USB-C Hub', '7-in-1 multiport adapter', 3900.00, TRUE);

INSERT INTO inventory (product_id, stock_qty, reorder_level) VALUES
(1, 40, 10),
(2, 20, 8),
(3, 70, 15),
(4, 15, 6),
(5, 50, 10),
(6, 25, 8),
(7, 30, 10);

INSERT INTO orders (customer_id, order_status, shipping_address, total_amount) VALUES
(1, 'paid', 'Street 10, Model Town, Lahore', 11100.00),
(2, 'pending', 'House 44, Gulberg, Lahore', 6200.00),
(1, 'delivered', 'Street 10, Model Town, Lahore', 5000.00);

INSERT INTO order_details (order_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 2500.00, 2500.00),
(1, 2, 1, 8500.00, 8500.00),
(2, 4, 1, 6200.00, 6200.00),
(3, 1, 2, 2500.00, 5000.00);

INSERT INTO payments (order_id, payment_method, payment_status, amount_paid, transaction_ref) VALUES
(1, 'card', 'completed', 11100.00, 'TXN-SC-1001'),
(2, 'cash_on_delivery', 'pending', 0.00, 'TXN-SC-1002'),
(3, 'wallet', 'completed', 5000.00, 'TXN-SC-1003');

INSERT INTO shopping_cart (customer_id, product_id, quantity) VALUES
(2, 3, 2),
(2, 5, 1);

INSERT INTO reviews (product_id, customer_id, rating, review_text) VALUES
(1, 1, 5, 'Smooth tracking and comfortable grip.'),
(2, 1, 4, 'Great keyboard, slightly loud switches.'),
(4, 2, 5, 'Very comfortable for daily runs.'),
(3, 2, 4, 'Good fabric quality and fit.');
