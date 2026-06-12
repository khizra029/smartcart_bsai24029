# SmartCart Normalization Notes

## First Normal Form (1NF)
- Each table has atomic values.
- No repeating groups or multi-valued attributes.
- Example: order items are stored in `order_details` instead of repeated columns in `orders`.
- Example: cart items are stored in `shopping_cart` as separate rows per product.

## Second Normal Form (2NF)
- All non-key attributes fully depend on the whole primary key.
- In `order_details`, fields like `quantity` and `unit_price` depend on the order-product row identity (surrogate key with FK references).
- In `shopping_cart`, quantity depends on the unique `(customer_id, product_id)` business key.

## Third Normal Form (3NF)
- No transitive dependency between non-key attributes.
- Category attributes are separated into `categories`.
- Product data and stock quantities are separated into `products` and `inventory`.
- Payment-specific information is separated into `payments`.
- Supplier contact details are separated into `suppliers` rather than duplicated in `products`.
- Customer profile attributes are separated from authentication data in `users`.

## Optional Module Normalization
- `reviews` stores one review per customer-product pair, preventing duplicate feedback rows.
- `suppliers` centralizes vendor data used by multiple products.

## Result
The schema minimizes redundancy, improves consistency, and supports maintainable growth for reporting, automation, and future application integration.
