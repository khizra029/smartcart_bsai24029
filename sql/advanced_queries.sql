-- Advanced operational and analytical queries (Phase 2)

-- 16) Product catalog with ratings and supplier info
SELECT *
FROM vw_product_catalog
ORDER BY category_name, product_name;

-- 17) Inventory alerts with supplier contact details
SELECT *
FROM vw_inventory_alerts
WHERE stock_status IN ('low_stock', 'out_of_stock')
ORDER BY stock_status, product_name;

-- 18) Customer activity dashboard
SELECT *
FROM vw_customer_activity
ORDER BY lifetime_spend DESC;

-- 19) Order summary view for managers
SELECT *
FROM vw_order_summary
ORDER BY order_date DESC;

-- 20) Top-rated products (minimum 1 review)
SELECT
    p.product_name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.review_id) >= 1
ORDER BY avg_rating DESC, review_count DESC;

-- 21) Revenue by category
SELECT
    c.category_name,
    SUM(od.line_total) AS category_revenue,
    SUM(od.quantity) AS units_sold
FROM order_details od
JOIN products p ON p.product_id = od.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN orders o ON o.order_id = od.order_id
WHERE o.order_status IN ('paid', 'shipped', 'delivered')
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- 22) Supplier product count and inventory value
SELECT
    s.supplier_name,
    COUNT(p.product_id) AS total_products,
    SUM(i.stock_qty) AS total_units_in_stock,
    SUM(i.stock_qty * p.unit_price) AS inventory_value
FROM suppliers s
LEFT JOIN products p ON p.supplier_id = s.supplier_id
LEFT JOIN inventory i ON i.product_id = p.product_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY inventory_value DESC;

-- 23) Active shopping carts with customer details
SELECT
    u.full_name AS customer_name,
    p.product_name,
    sc.quantity,
    (sc.quantity * p.unit_price) AS cart_line_total,
    sc.added_at
FROM shopping_cart sc
JOIN customers c ON c.customer_id = sc.customer_id
JOIN users u ON u.user_id = c.user_id
JOIN products p ON p.product_id = sc.product_id
ORDER BY sc.added_at DESC;

-- 24) Payment completion rate
SELECT
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;

-- 25) Monthly new customers
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS signup_month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY signup_month;

-- 26) Products never ordered
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    i.stock_qty
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN inventory i ON i.product_id = p.product_id
LEFT JOIN order_details od ON od.product_id = p.product_id
WHERE od.order_detail_id IS NULL
ORDER BY p.product_id;

-- 27) Average rating by category
SELECT
    c.category_name,
    ROUND(AVG(r.rating), 2) AS avg_category_rating,
    COUNT(r.review_id) AS total_reviews
FROM categories c
JOIN products p ON p.category_id = c.category_id
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY c.category_id, c.category_name
ORDER BY avg_category_rating DESC;

-- 28) Example stored procedure calls
-- CALL sp_get_low_stock_products();
-- CALL sp_view_cart(2);
-- CALL sp_get_sales_summary('2026-01-01', '2026-12-31');

-- 29) Example order-from-cart workflow
-- SET @new_order_id = 0;
-- CALL sp_create_order_from_cart(2, 'House 44, Gulberg, Lahore', @new_order_id);
-- SELECT @new_order_id AS created_order_id;
-- CALL sp_record_payment(@new_order_id, 'card', 9800.00, 'TXN-SC-2001');

-- 30) Duplicate email check for user authentication support
SELECT user_id, full_name, email, role
FROM users
WHERE email = 'khizra@example.com';
