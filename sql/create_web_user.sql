# Website database login (run this in MySQL Workbench while connected)

CREATE USER IF NOT EXISTS 'smartcart'@'localhost' IDENTIFIED BY 'SmartCart123!';
CREATE USER IF NOT EXISTS 'smartcart'@'127.0.0.1' IDENTIFIED BY 'SmartCart123!';

GRANT ALL PRIVILEGES ON smartcart_db.* TO 'smartcart'@'localhost';
GRANT ALL PRIVILEGES ON smartcart_db.* TO 'smartcart'@'127.0.0.1';

FLUSH PRIVILEGES;

SELECT 'Website user created. Use smartcart / SmartCart123! in config_local.py' AS status;
