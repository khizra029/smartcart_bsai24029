# SmartCart Entity-Relationship Overview

## Core Entities
- **Users** (1) — (0..1) **Customers**
- **Categories** (1) — (M) **Products**
- **Suppliers** (1) — (M) **Products**
- **Products** (1) — (1) **Inventory**
- **Customers** (1) — (M) **Orders**
- **Orders** (1) — (M) **Order Details**
- **Products** (1) — (M) **Order Details**
- **Orders** (1) — (1) **Payments**

## Extended Entities
- **Customers** (1) — (M) **Shopping Cart**
- **Products** (1) — (M) **Shopping Cart**
- **Customers** (1) — (M) **Reviews**
- **Products** (1) — (M) **Reviews**

## Relationship Summary
| Relationship | Cardinality | Description |
|---|---|---|
| User → Customer | 1:1 | Each customer account maps to one user profile |
| Category → Product | 1:M | One category contains many products |
| Supplier → Product | 1:M | One supplier can provide many products |
| Product → Inventory | 1:1 | Each product has one inventory record |
| Customer → Order | 1:M | A customer can place many orders |
| Order → Order Detail | 1:M | One order contains multiple line items |
| Order → Payment | 1:1 | Each order has one payment record |
| Customer → Cart Item | 1:M | Customer can hold multiple cart rows |
| Customer → Review | 1:M | Customer can review multiple products |

## Business Flow
1. Customer registers (`users` + `customers`).
2. Customer browses catalog (`products`, `categories`, `inventory`).
3. Customer adds items to cart (`shopping_cart`).
4. Checkout creates order (`orders`, `order_details`) via procedure.
5. Triggers validate stock and update inventory/order totals.
6. Payment is recorded (`payments`) and order status is synchronized.
7. Customer submits product feedback (`reviews`).
8. Manager monitors stock/supplier/sales through views and reports.
