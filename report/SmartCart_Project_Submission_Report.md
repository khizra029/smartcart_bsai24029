# SmartCart — Project Submission Report

**Advanced Database Project**

| Field | Detail |
|-------|--------|
| **Student Name** | Khizra Bilal |
| **Roll Number** | BSAI 24029 |
| **Project Title** | SmartCart — A Generalized E-Commerce Database System |
| **Course** | Advanced Database |
| **Database** | MySQL 8.x (RDBMS) |
| **GitHub Repository** | _Add your link here after pushing_ |

---

## 1. Project Title and Description

### Title
**SmartCart — A Generalized E-Commerce Database System**

### Description
SmartCart is an academic e-commerce database system designed for small and medium retail businesses. It provides a centralized platform to manage online shopping operations including product catalog, inventory, customer accounts, shopping cart, orders, payments, suppliers, and product reviews.

The project includes:
- A **normalized relational database** (MySQL) with constraints, triggers, stored procedures, views, and indexes
- A **simple shopping website** (Python/Flask) connected to the database for browsing products, adding to cart, checkout, and order tracking

The system supports multiple product types such as electronics, clothing, footwear, accessories, and household items, making it suitable for various retail scenarios.

### Problem Statement
Many small retailers still use manual or unorganized records, leading to data errors, poor inventory control, and inefficient order management. SmartCart addresses this by providing a structured, automated, and scalable database solution for e-commerce operations.

---

## 2. Objectives and Scope

### Objectives
1. Design and implement a generalized e-commerce database
2. Apply SQL concepts: tables, relationships, keys, and constraints
3. Ensure accurate and secure storage of business data
4. Reduce redundancy through normalization (up to 3NF)
5. Provide a scalable system suitable for different retail industries
6. Simulate real-world online shopping operations for academic learning

### Scope — Included
| Area | Details |
|------|---------|
| User management | Admin, customer, and manager roles |
| Product management | Categories, products, suppliers, inventory |
| Shopping workflow | Cart, orders, order details, payments |
| Optional modules | Suppliers, reviews, shopping cart |
| Database automation | Triggers, stored procedures, views, indexes |
| Reporting | Sales, inventory, customer activity queries |
| Web interface | Browse, search, cart, checkout, order history |

### Scope — Excluded
- Mobile application
- Real payment gateway integration (Stripe, JazzCash, etc.)
- Production-grade security hardening
- Multi-vendor marketplace features

---

## 3. Implementation Details

### 3.1 Technology Stack

| Component | Technology |
|-----------|------------|
| Database | MySQL 8.x (RDBMS) |
| Query Language | SQL |
| Design Method | Entity-Relationship (ER) Modeling |
| Normalization | Up to Third Normal Form (3NF) |
| Website Backend | Python 3, Flask |
| Website Frontend | HTML, CSS |
| Database Driver | PyMySQL |

### 3.2 Database Schema (12 Tables)

**Core tables:**
- `users` — authentication and roles (admin, customer, manager)
- `customers` — customer profile linked to users
- `categories` — product categories
- `products` — product catalog with price and supplier link
- `inventory` — stock quantity and reorder levels
- `orders` — customer orders with status tracking
- `order_details` — line items per order
- `payments` — payment records per order

**Extended tables:**
- `suppliers` — vendor/supplier information
- `shopping_cart` — pre-checkout cart items
- `reviews` — customer product ratings (1–5 stars)

### 3.3 Normalization
- **1NF:** Atomic values; order items in separate `order_details` table; cart items in `shopping_cart`
- **2NF:** All attributes depend on full primary key in junction tables
- **3NF:** Categories, inventory, payments, and suppliers separated to avoid transitive dependencies

See `docs/normalization_notes.md` and `docs/er_diagram_notes.md` in the repository.

### 3.4 Database Objects

**Triggers (`sql/triggers.sql`):**
- Validate stock before inserting order line items
- Auto-calculate line totals
- Update order totals when order details change
- Adjust inventory on insert/update/delete of order details
- Sync order status when payment status changes

**Stored Procedures (`sql/procedures.sql`):**
- `sp_add_to_cart` — add item to cart with stock validation
- `sp_view_cart` — view customer cart
- `sp_create_order_from_cart` — checkout cart into order
- `sp_record_payment` — record payment against order
- `sp_get_low_stock_products` — inventory reorder report
- `sp_get_sales_summary` — date-range sales report

**Views (`sql/views.sql`):**
- `vw_product_catalog` — products with stock, supplier, ratings
- `vw_order_summary` — orders with payment and item counts
- `vw_inventory_alerts` — low/out-of-stock monitoring
- `vw_customer_activity` — customer engagement metrics

**Indexes (`sql/indexes.sql`):** Performance indexes on frequently queried columns (category, product name, order status, payment status, etc.)

### 3.5 Website Implementation
The Flask website (`website/`) connects to `smartcart_db` and provides:
- Product listing with category filter and search
- Product detail pages with reviews
- Add to Cart and Buy Now
- Shopping cart management
- Checkout with payment method selection
- Order confirmation and order history
- Customer login and registration

---

## 4. Features and Functionalities

### 4.1 Database Features
| Feature | Description |
|---------|-------------|
| Product management | Add, categorize, and price products |
| Category management | Organize products by type |
| Customer management | Store customer profiles and contact info |
| Inventory management | Track stock levels and reorder alerts |
| Order management | Create and track order status (pending → paid → shipped → delivered) |
| Payment records | Record payment method and status |
| Shopping cart | Store items before checkout |
| Reviews | Customer ratings and feedback |
| Supplier tracking | Link products to suppliers |
| Search & filter | SQL queries by keyword and category |
| Reports & analytics | Revenue, top products, low stock, customer spending |

### 4.2 Website Features
| Feature | Description |
|---------|-------------|
| Home page | Product grid with categories and search |
| Product detail | Price, stock, description, reviews |
| Add to Cart | Adds item using `sp_add_to_cart` |
| Buy Now | Direct order placement |
| Cart | View, update quantity, remove items |
| Checkout | Shipping address and payment method |
| My Orders | View past orders and status |
| Login / Register | Customer authentication |

### 4.3 Demo Accounts
| Email | Password |
|-------|----------|
| khizra@example.com | password123 |
| ali@example.com | password123 |

---

## 5. Instructions for Running the Project

### 5.1 Prerequisites
- MySQL 8.x installed and running
- MySQL Workbench (recommended)
- Python 3.10 or higher
- Git (for GitHub submission)

### 5.2 Database Setup (MySQL Workbench)

**Step 1:** Connect to Local instance MySQL80 in Workbench

**Step 2:** Run SQL files in this order:

| Order | File |
|-------|------|
| 1 | `sql/00_create_database.sql` |
| 2 | `sql/schema.sql` |
| 3 | `sql/indexes.sql` |
| 4 | `sql/sample_data.sql` |
| 5 | `sql/triggers.sql` |
| 6 | `sql/procedures.sql` |
| 7 | `sql/views.sql` |
| 8 | `sql/create_web_user.sql` |

**Step 3:** Verify:
```sql
USE smartcart_db;
SHOW TABLES;
SELECT COUNT(*) FROM products;
```

### 5.3 Website Setup

**Step 1:** Copy config file:
```
website/config_local.example.py  →  website/config_local.py
```

**Step 2:** Set database credentials in `config_local.py`:
```python
DB_OVERRIDES = {
    "user": "smartcart",
    "password": "SmartCart123!",
    "database": "smartcart_db",
}
```

**Step 3:** Install dependencies and run:
```powershell
cd website
pip install -r requirements.txt
python test_db.py
python app.py
```

**Step 4:** Open browser: **http://127.0.0.1:5000**

### 5.4 Run Sample Queries (Optional)
In Workbench, execute:
- `sql/queries.sql` — core business queries
- `sql/advanced_queries.sql` — reporting and analytics

Example stored procedure calls:
```sql
CALL sp_view_cart(2);
CALL sp_get_low_stock_products();
```

---

## 6. Screenshots

_Add the following screenshots to this section before exporting to PDF._

### Screenshot 1: GitHub Repository
**Caption:** Project repository structure on GitHub showing folders (`sql/`, `website/`, `docs/`, `report/`).

_[Insert screenshot here]_

---

### Screenshot 2: Database Tables in MySQL Workbench
**Caption:** `smartcart_db` schema with all 12 tables visible in the Schemas panel.

_[Insert screenshot here]_

---

### Screenshot 3: Sample Data / Query Results
**Caption:** Query result showing products with categories and stock, e.g.:
```sql
SELECT * FROM vw_product_catalog;
```

_[Insert screenshot here]_

---

### Screenshot 4: Stored Procedure / Trigger
**Caption:** Execution of a stored procedure or view, e.g.:
```sql
CALL sp_get_low_stock_products();
```

_[Insert screenshot here]_

---

### Screenshot 5: Website Home Page
**Caption:** SmartCart shopping website home page with product listings.

_[Insert screenshot here]_

---

### Screenshot 6: Add to Cart / Product Page
**Caption:** Product detail page or cart showing Add to Cart and Buy Now buttons.

_[Insert screenshot here]_

---

### Screenshot 7: Checkout / Order Success
**Caption:** Checkout page or order confirmation after placing an order.

_[Insert screenshot here]_

---

### Screenshot 8: My Orders Page
**Caption:** Customer order history showing order status and amounts.

_[Insert screenshot here]_

---

## 7. Repository Structure

```
DATABASE/
├── sql/                    # Database scripts
│   ├── 00_create_database.sql
│   ├── schema.sql
│   ├── indexes.sql
│   ├── sample_data.sql
│   ├── triggers.sql
│   ├── procedures.sql
│   ├── views.sql
│   ├── queries.sql
│   ├── advanced_queries.sql
│   └── create_web_user.sql
├── website/                # Shopping website
│   ├── app.py
│   ├── config.py
│   ├── db.py
│   ├── templates/
│   └── static/css/
├── docs/                   # Design documentation
├── report/                 # Project reports
├── requirements.md
└── README.md
```

---

## 8. Testing and Validation

The following scenarios were tested successfully:

1. Database creation and table loading
2. Sample data insertion (users, products, orders, cart, reviews)
3. Product search and category filtering
4. Low-stock inventory alerts
5. Shopping cart add/update/remove via website
6. Order placement (cart checkout and buy now)
7. Payment recording and order status update
8. Customer login and registration
9. Order history display
10. Stored procedures and views execution

---

## 9. Conclusion

SmartCart successfully implements a complete e-commerce database system aligned with the approved project proposal. The project demonstrates relational database design, normalization, SQL implementation, automation through triggers and procedures, and practical application through a functional shopping website connected to MySQL.

The system is suitable for academic evaluation and demonstrates how database concepts support real-world online retail operations.

---

## 10. References

- Project Proposal: `BSAI242029_ProjectProposal (1).pdf`
- MySQL 8.0 Documentation: https://dev.mysql.com/doc/
- Flask Documentation: https://flask.palletsprojects.com/

---

**Submitted by:** Khizra Bilal (BSAI 24029)
