-- SmartCart stored procedures for common business operations

DELIMITER $$

CREATE PROCEDURE sp_add_to_cart(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_active BOOLEAN;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    SELECT is_active INTO v_active
    FROM products
    WHERE product_id = p_product_id;

    IF v_active IS NULL OR v_active = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product is not available';
    END IF;

    SELECT stock_qty INTO v_stock
    FROM inventory
    WHERE product_id = p_product_id;

    IF v_stock IS NULL OR v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock to add item to cart';
    END IF;

    INSERT INTO shopping_cart (customer_id, product_id, quantity)
    VALUES (p_customer_id, p_product_id, p_quantity)
    ON DUPLICATE KEY UPDATE quantity = quantity + p_quantity;
END$$

CREATE PROCEDURE sp_view_cart(
    IN p_customer_id INT
)
BEGIN
    SELECT
        sc.cart_item_id,
        p.product_id,
        p.product_name,
        c.category_name,
        p.unit_price,
        sc.quantity,
        (sc.quantity * p.unit_price) AS line_total,
        i.stock_qty
    FROM shopping_cart sc
    JOIN products p ON p.product_id = sc.product_id
    JOIN categories c ON c.category_id = p.category_id
    JOIN inventory i ON i.product_id = p.product_id
    WHERE sc.customer_id = p_customer_id
    ORDER BY sc.added_at DESC;
END$$

CREATE PROCEDURE sp_create_order_from_cart(
    IN p_customer_id INT,
    IN p_shipping_address VARCHAR(255),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_cart_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cart_count
    FROM shopping_cart
    WHERE customer_id = p_customer_id;

    IF v_cart_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shopping cart is empty';
    END IF;

    START TRANSACTION;

    INSERT INTO orders (customer_id, order_status, shipping_address, total_amount)
    VALUES (p_customer_id, 'pending', p_shipping_address, 0);

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO order_details (order_id, product_id, quantity, unit_price, line_total)
    SELECT
        p_order_id,
        sc.product_id,
        sc.quantity,
        p.unit_price,
        sc.quantity * p.unit_price
    FROM shopping_cart sc
    JOIN products p ON p.product_id = sc.product_id
    WHERE sc.customer_id = p_customer_id;

    DELETE FROM shopping_cart
    WHERE customer_id = p_customer_id;

    COMMIT;
END$$

CREATE PROCEDURE sp_record_payment(
    IN p_order_id INT,
    IN p_payment_method VARCHAR(30),
    IN p_amount_paid DECIMAL(12,2),
    IN p_transaction_ref VARCHAR(100)
)
BEGIN
    DECLARE v_order_total DECIMAL(12,2);
    DECLARE v_order_status VARCHAR(20);

    SELECT total_amount, order_status
    INTO v_order_total, v_order_status
    FROM orders
    WHERE order_id = p_order_id;

    IF v_order_total IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Order not found';
    END IF;

    IF v_order_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot record payment for cancelled order';
    END IF;

    INSERT INTO payments (order_id, payment_method, payment_status, amount_paid, transaction_ref)
    VALUES (
        p_order_id,
        p_payment_method,
        IF(p_amount_paid >= v_order_total, 'completed', 'pending'),
        p_amount_paid,
        p_transaction_ref
    )
    ON DUPLICATE KEY UPDATE
        payment_method = VALUES(payment_method),
        payment_status = VALUES(payment_status),
        amount_paid = VALUES(amount_paid),
        transaction_ref = VALUES(transaction_ref),
        payment_date = CURRENT_TIMESTAMP;
END$$

CREATE PROCEDURE sp_get_low_stock_products()
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        s.supplier_name,
        i.stock_qty,
        i.reorder_level,
        (i.reorder_level - i.stock_qty) AS units_below_reorder
    FROM inventory i
    JOIN products p ON p.product_id = i.product_id
    JOIN categories c ON c.category_id = p.category_id
    LEFT JOIN suppliers s ON s.supplier_id = p.supplier_id
    WHERE i.stock_qty <= i.reorder_level
    ORDER BY units_below_reorder DESC, p.product_name;
END$$

CREATE PROCEDURE sp_get_sales_summary(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        DATE(o.order_date) AS sale_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS daily_revenue,
        SUM(od.quantity) AS units_sold
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
      AND o.order_status IN ('paid', 'shipped', 'delivered')
    GROUP BY DATE(o.order_date)
    ORDER BY sale_date;
END$$

DELIMITER ;
