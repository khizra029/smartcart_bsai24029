-- 1) List all products with category, supplier, and stock
SELECT p.product_id, p.product_name, c.category_name, s.supplier_name, p.unit_price, i.stock_qty
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
JOIN inventory i ON i.product_id = p.product_id
ORDER BY p.product_id;

-- 2) Search products by keyword (example: 'shoe')
SELECT p.product_id, p.product_name, c.category_name, p.unit_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE LOWER(p.product_name) LIKE '%shoe%'
   OR LOWER(c.category_name) LIKE '%shoe%';

-- 3) Low stock products (stock below reorder level)
SELECT p.product_name, i.stock_qty, i.reorder_level
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.stock_qty < i.reorder_level;

-- 4) Customer order history
SELECT o.order_id, u.full_name AS customer_name, o.order_date, o.order_status, o.total_amount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN users u ON u.user_id = c.user_id
ORDER BY o.order_date DESC;

-- 5) Detailed order breakdown
SELECT od.order_id, p.product_name, od.quantity, od.unit_price, od.line_total
FROM order_details od
JOIN products p ON p.product_id = od.product_id
ORDER BY od.order_id, od.order_detail_id;

-- 6) Orders with payment status
SELECT o.order_id, o.order_status, o.total_amount, py.payment_status, py.payment_method
FROM orders o
LEFT JOIN payments py ON py.order_id = o.order_id
ORDER BY o.order_id;

-- 7) Top-selling products by quantity
SELECT p.product_name, SUM(od.quantity) AS total_units_sold
FROM order_details od
JOIN products p ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;

-- 8) Revenue by month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month, SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- 9) Count orders by status
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 10) Total customers count
SELECT COUNT(*) AS total_customers
FROM customers;

-- 11) Products per category
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;

-- 12) Average order value
SELECT ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders;

-- 13) Pending payments
SELECT py.payment_id, py.order_id, py.payment_status, py.amount_paid
FROM payments py
WHERE py.payment_status = 'pending';

-- 14) Inventory value estimate
SELECT SUM(i.stock_qty * p.unit_price) AS inventory_value
FROM inventory i
JOIN products p ON p.product_id = i.product_id;

-- 15) Customer spending summary
SELECT u.full_name AS customer_name, SUM(o.total_amount) AS lifetime_spend
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN users u ON u.user_id = c.user_id
GROUP BY u.user_id, u.full_name
ORDER BY lifetime_spend DESC;
