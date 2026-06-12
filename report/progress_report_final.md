# SmartCart - Final Project Report

## Student Information
- **Name:** Khizra Bilal
- **Roll Number:** BSAI 24029
- **Project Title:** SmartCart - A Generalized E-Commerce Database System

## 1. Project Overview
SmartCart is a generalized e-commerce database system designed for small and medium retail businesses. It supports product browsing, shopping cart operations, order processing, payment tracking, inventory monitoring, supplier management, and customer reviews.

## 2. Completed Deliverables

### 2.1 Requirement Analysis
Functional and non-functional requirements documented in `requirements.md`, covering:
- User authentication roles (admin, customer, manager)
- Product and category management
- Shopping cart and order workflow
- Payment records and inventory tracking
- Search, filtering, and business reporting

### 2.2 Database Design
Relational schema designed using ER modeling and normalized up to 3NF.

**Core tables:**
- `users`, `customers`
- `categories`, `products`, `inventory`
- `orders`, `order_details`, `payments`

**Extended modules:**
- `suppliers` - vendor and supply-chain data
- `shopping_cart` - pre-checkout product selection
- `reviews` - customer product ratings and feedback

Design notes are available in `docs/normalization_notes.md`.

### 2.3 SQL Implementation
| File | Purpose |
|------|---------|
| `sql/schema.sql` | Full table definitions with PK/FK and CHECK constraints |
| `sql/indexes.sql` | Performance indexes for common query paths |
| `sql/sample_data.sql` | Realistic test dataset |
| `sql/queries.sql` | Core operational and analytical queries |
| `sql/advanced_queries.sql` | Phase 2 reporting and analytics |
| `sql/triggers.sql` | Inventory and order automation |
| `sql/procedures.sql` | Reusable business operations |
| `sql/views.sql` | Manager-friendly reporting views |
| `sql/setup.sql` | One-command database bootstrap |

### 2.4 Automation Features
**Triggers:**
- Validate stock before order line insertion
- Auto-calculate line totals
- Auto-update order totals
- Auto-adjust inventory on order line changes
- Sync order status with payment updates

**Stored procedures:**
- `sp_add_to_cart` - add/update cart items with stock validation
- `sp_view_cart` - view customer cart details
- `sp_create_order_from_cart` - convert cart to order transactionally
- `sp_record_payment` - record/update payment against order
- `sp_get_low_stock_products` - inventory reorder monitoring
- `sp_get_sales_summary` - date-range sales reporting

**Views:**
- `vw_product_catalog` - products with stock, supplier, and ratings
- `vw_order_summary` - consolidated order and payment status
- `vw_inventory_alerts` - low/out-of-stock monitoring
- `vw_customer_activity` - customer engagement metrics

## 3. Technology Stack
- **Database:** Relational DBMS (MySQL 8.x compatible)
- **Language:** SQL
- **Design:** ER modeling, normalization up to 3NF
- **Automation:** Triggers, stored procedures, views, indexes

## 4. How to Run
```powershell
# From project root (enter MySQL password when prompted)
.\scripts\setup.ps1 -User root -Password your_password
```

Manual setup:
```sql
CREATE DATABASE smartcart_db;
USE smartcart_db;
-- Run sql files in order: schema, indexes, sample_data, triggers, procedures, views
```

## 5. Sample Business Scenarios Tested
1. Product listing with category, stock, and supplier details
2. Keyword and category-based product search
3. Low-stock and reorder monitoring
4. Customer order history and order breakdown
5. Payment status tracking and completion reporting
6. Sales/revenue analytics by month and category
7. Shopping cart management and checkout workflow
8. Product review aggregation and top-rated products
9. Supplier inventory value reporting
10. Customer activity and lifetime spend analysis

## 6. GitHub Repository
`https://github.com/<your-username>/SmartCart-Database`

## 7. Conclusion
The SmartCart project is complete according to the approved proposal. It implements a normalized e-commerce database with core and optional modules, automated business rules, optimized query support, and reporting capabilities suitable for academic evaluation and real-world retail simulation.
