-- SmartCart automation triggers

DELIMITER $$

CREATE TRIGGER trg_order_details_before_insert
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;

    SELECT stock_qty INTO available_stock
    FROM inventory
    WHERE product_id = NEW.product_id;

    IF available_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product inventory record not found';
    END IF;

    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for product';
    END IF;

    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END$$

CREATE TRIGGER trg_order_details_before_update
BEFORE UPDATE ON order_details
FOR EACH ROW
BEGIN
    SET NEW.line_total = NEW.quantity * NEW.unit_price;
END$$

CREATE TRIGGER trg_order_details_after_insert
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_qty = stock_qty - NEW.quantity
    WHERE product_id = NEW.product_id;

    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_details
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

CREATE TRIGGER trg_order_details_after_update
AFTER UPDATE ON order_details
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_qty = stock_qty + OLD.quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_details
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

CREATE TRIGGER trg_order_details_after_delete
AFTER DELETE ON order_details
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_qty = stock_qty + OLD.quantity
    WHERE product_id = OLD.product_id;

    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_details
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END$$

CREATE TRIGGER trg_payments_after_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'completed' AND OLD.payment_status <> 'completed' THEN
        UPDATE orders
        SET order_status = 'paid'
        WHERE order_id = NEW.order_id
          AND order_status = 'pending';
    END IF;

    IF NEW.payment_status = 'refunded' AND OLD.payment_status <> 'refunded' THEN
        UPDATE orders
        SET order_status = 'cancelled'
        WHERE order_id = NEW.order_id;
    END IF;
END$$

DELIMITER ;
