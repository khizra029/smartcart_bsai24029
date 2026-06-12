-- SmartCart full database setup script
-- Run: mysql -u root -p < sql/setup.sql

DROP DATABASE IF EXISTS smartcart_db;
CREATE DATABASE smartcart_db;
USE smartcart_db;

SOURCE schema.sql;
SOURCE indexes.sql;
SOURCE sample_data.sql;
SOURCE triggers.sql;
SOURCE procedures.sql;
SOURCE views.sql;

SELECT 'SmartCart database setup completed successfully.' AS status;
