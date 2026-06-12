-- Performance indexes for SmartCart operational and reporting queries

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_active ON products(is_active);

CREATE INDEX idx_inventory_stock ON inventory(stock_qty);
CREATE INDEX idx_inventory_reorder ON inventory(reorder_level);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_date ON orders(order_date);

CREATE INDEX idx_order_details_order ON order_details(order_id);
CREATE INDEX idx_order_details_product ON order_details(product_id);

CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_date ON payments(payment_date);

CREATE INDEX idx_cart_customer ON shopping_cart(customer_id);
CREATE INDEX idx_cart_product ON shopping_cart(product_id);

CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_suppliers_active ON suppliers(is_active);
