# SmartCart Database Project - Progress Report (Phase 1)

## Student Information
- **Name:** Khizra Bilal
- **Roll Number:** BSAI 24029
- **Project Title:** SmartCart - A Generalized E-Commerce Database System

## 1. Work Completed Till Now

### 1.1 Problem Analysis
The project problem was analyzed to address challenges in small and medium retail businesses, including manual record handling, inconsistent data storage, and inefficient order/inventory management.

### 1.2 Requirement Analysis
Core stakeholders and requirements were finalized:
- Customers (product browsing and purchasing)
- Administrators (catalog and transaction management)
- Business managers (sales/inventory monitoring)

Main functional areas identified:
- Product and category management
- Customer and user management
- Order and order details management
- Payments and inventory tracking

### 1.3 Database Design
An ER-based relational design was prepared and mapped to SQL schema.  
The following core entities were finalized:
- Users
- Customers
- Categories
- Products
- Inventory
- Orders
- Order Details
- Payments

Optional entities for later phase:
- Suppliers
- Reviews

### 1.4 SQL Implementation
Initial SQL implementation has been completed:
- Tables created with primary keys and foreign keys
- Domain checks applied (status, role, positive values)
- Referential integrity constraints enforced
- Structure designed to support normalization up to 3NF

### 1.5 Sample Data and Testing
Dummy data inserted for users, customers, products, orders, and payments.  
A set of operational and analytical SQL queries has been prepared and tested conceptually for:
- Product listing and filtering
- Stock/reorder monitoring
- Order history and details
- Payment status reporting
- Sales and revenue analysis

## 2. Database Type and Tools
- **Database Type:** Relational Database Management System (RDBMS)
- **Language:** SQL (MySQL-compatible)
- **Design Technique:** ER Modeling
- **Normalization Level:** Up to Third Normal Form (3NF)

## 3. Repository Deliverables (Phase 1)
- `requirements.md`
- `docs/normalization_notes.md`
- `sql/schema.sql`
- `sql/sample_data.sql`
- `sql/queries.sql`
- `README.md`

## 4. GitHub Repository Link
Add your GitHub link here after pushing:

`https://github.com/<your-username>/SmartCart-Database`

## 5. Planned Next Steps
1. Add optional entities (suppliers, reviews)
2. Implement triggers/procedures for automation
3. Add advanced reports and optimization indexes
4. Connect with front-end or console-based interface (if required)

## 6. Conclusion
Phase 1 successfully establishes the foundation of the SmartCart database system through requirement analysis, normalized relational schema design, initial SQL implementation, and query planning. The current progress is sufficient for initial project evaluation and provides a strong base for advanced implementation in the next phase.
