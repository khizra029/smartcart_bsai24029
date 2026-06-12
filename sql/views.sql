-- SmartCart reporting views

CREATE VIEW vw_product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    p.unit_price,
    p.is_active,
    i.stock_qty,
    i.reorder_level,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN inventory i ON i.product_id = p.product_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY
    p.product_id, p.product_name, c.category_name, s.supplier_name,
    p.unit_price, p.is_active, i.stock_qty, i.reorder_level;

CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    u.full_name AS customer_name,
    o.order_date,
    o.order_status,
    o.total_amount,
    py.payment_status,
    py.payment_method,
    COUNT(od.order_detail_id) AS item_count,
    SUM(od.quantity) AS total_units
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN users u ON u.user_id = c.user_id
LEFT JOIN payments py ON py.order_id = o.order_id
LEFT JOIN order_details od ON od.order_id = o.order_id
GROUP BY
    o.order_id, u.full_name, o.order_date, o.order_status,
    o.total_amount, py.payment_status, py.payment_method;

CREATE VIEW vw_inventory_alerts AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    s.email AS supplier_email,
    s.phone AS supplier_phone,
    i.stock_qty,
    i.reorder_level,
    CASE
        WHEN i.stock_qty = 0 THEN 'out_of_stock'
        WHEN i.stock_qty < i.reorder_level THEN 'low_stock'
        ELSE 'healthy'
    END AS stock_status
FROM inventory i
JOIN products p ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id;

CREATE VIEW vw_customer_activity AS
SELECT
    c.customer_id,
    u.full_name AS customer_name,
    u.email,
    c.city,
    c.country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_spend,
    COUNT(DISTINCT sc.cart_item_id) AS cart_items,
    COUNT(DISTINCT r.review_id) AS reviews_written
FROM customers c
JOIN users u ON u.user_id = c.user_id
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN shopping_cart sc ON sc.customer_id = c.customer_id
LEFT JOIN reviews r ON r.customer_id = c.customer_id
GROUP BY
    c.customer_id, u.full_name, u.email, c.city, c.country;
