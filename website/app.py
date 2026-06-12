from decimal import Decimal
from functools import wraps

import pymysql
from flask import (
    Flask,
    flash,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from werkzeug.security import check_password_hash, generate_password_hash

from config import DB_CONFIG, SECRET_KEY
from db import get_db, query_all, query_one

app = Flask(__name__)
app.secret_key = SECRET_KEY

DEMO_PASSWORD = "password123"


def login_required(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if "customer_id" not in session:
            flash("Please log in to continue.", "warning")
            return redirect(url_for("login", next=request.url))
        return view(*args, **kwargs)

    return wrapped


def verify_password(stored_hash, password):
    if stored_hash.startswith("hash_"):
        return password == DEMO_PASSWORD
    return check_password_hash(stored_hash, password)


def get_cart_count():
    if "customer_id" not in session:
        return 0
    try:
        row = query_one(
            "SELECT COALESCE(SUM(quantity), 0) AS total FROM shopping_cart WHERE customer_id = %s",
            (session["customer_id"],),
        )
        return int(row["total"]) if row else 0
    except pymysql.err.OperationalError:
        return 0


@app.errorhandler(pymysql.err.OperationalError)
def handle_db_error(exc):
    return render_template(
        "db_error.html",
        error=str(exc),
        db_user=DB_CONFIG.get("user"),
        db_name=DB_CONFIG.get("database"),
    ), 500


@app.context_processor
def inject_globals():
    return {"cart_count": get_cart_count()}


def fetch_products(category_id=None, search=None):
    sql = """
        SELECT
            p.product_id,
            p.product_name,
            p.description,
            p.unit_price,
            c.category_name,
            c.category_id,
            i.stock_qty,
            COALESCE(AVG(r.rating), 0) AS avg_rating,
            COUNT(r.review_id) AS review_count
        FROM products p
        JOIN categories c ON c.category_id = p.category_id
        JOIN inventory i ON i.product_id = p.product_id
        LEFT JOIN reviews r ON r.product_id = p.product_id
        WHERE p.is_active = TRUE
    """
    params = []

    if category_id:
        sql += " AND p.category_id = %s"
        params.append(category_id)

    if search:
        sql += " AND (p.product_name LIKE %s OR p.description LIKE %s OR c.category_name LIKE %s)"
        term = f"%{search}%"
        params.extend([term, term, term])

    sql += """
        GROUP BY p.product_id, p.product_name, p.description, p.unit_price,
                 c.category_name, c.category_id, i.stock_qty
        ORDER BY p.product_name
    """
    return query_all(sql, params)


@app.route("/")
def home():
    category_id = request.args.get("category", type=int)
    search = request.args.get("q", "").strip()
    products = fetch_products(category_id, search or None)
    categories = query_all("SELECT category_id, category_name FROM categories ORDER BY category_name")
    active_category_name = None
    if category_id:
        match = next((c for c in categories if c["category_id"] == category_id), None)
        active_category_name = match["category_name"] if match else None
    return render_template(
        "home.html",
        products=products,
        categories=categories,
        active_category=category_id,
        active_category_name=active_category_name,
        search=search,
    )


@app.route("/product/<int:product_id>")
def product_detail(product_id):
    product = query_one(
        """
        SELECT
            p.product_id,
            p.product_name,
            p.description,
            p.unit_price,
            c.category_name,
            i.stock_qty,
            COALESCE(AVG(r.rating), 0) AS avg_rating,
            COUNT(r.review_id) AS review_count
        FROM products p
        JOIN categories c ON c.category_id = p.category_id
        JOIN inventory i ON i.product_id = p.product_id
        LEFT JOIN reviews r ON r.product_id = p.product_id
        WHERE p.product_id = %s AND p.is_active = TRUE
        GROUP BY p.product_id, p.product_name, p.description, p.unit_price,
                 c.category_name, i.stock_qty
        """,
        (product_id,),
    )
    if not product:
        flash("Product not found.", "error")
        return redirect(url_for("home"))

    reviews = query_all(
        """
        SELECT u.full_name, r.rating, r.review_text, r.created_at
        FROM reviews r
        JOIN customers c ON c.customer_id = r.customer_id
        JOIN users u ON u.user_id = c.user_id
        WHERE r.product_id = %s
        ORDER BY r.created_at DESC
        """,
        (product_id,),
    )
    return render_template("product_detail.html", product=product, reviews=reviews)


@app.route("/cart/add/<int:product_id>", methods=["POST"])
@login_required
def add_to_cart(product_id):
    quantity = request.form.get("quantity", 1, type=int)
    if quantity < 1:
        flash("Invalid quantity.", "error")
        return redirect(request.referrer or url_for("home"))

    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.callproc("sp_add_to_cart", (session["customer_id"], product_id, quantity))
        flash("Item added to cart!", "success")
    except Exception as exc:
        flash(str(exc), "error")

    return redirect(request.referrer or url_for("cart"))


@app.route("/buy-now/<int:product_id>", methods=["POST"])
@login_required
def buy_now(product_id):
    quantity = request.form.get("quantity", 1, type=int)
    if quantity < 1:
        flash("Invalid quantity.", "error")
        return redirect(request.referrer or url_for("home"))

    customer = query_one(
        """
        SELECT c.customer_id, c.address_line, c.city, c.country
        FROM customers c
        WHERE c.customer_id = %s
        """,
        (session["customer_id"],),
    )
    shipping = ", ".join(
        part for part in [customer["address_line"], customer["city"], customer["country"]] if part
    )

    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO orders (customer_id, order_status, shipping_address, total_amount)
                    VALUES (%s, 'pending', %s, 0)
                    """,
                    (session["customer_id"], shipping or "Address not set"),
                )
                order_id = cur.lastrowid

                cur.execute(
                    "SELECT unit_price FROM products WHERE product_id = %s AND is_active = TRUE",
                    (product_id,),
                )
                product = cur.fetchone()
                if not product:
                    raise ValueError("Product not available")

                unit_price = product["unit_price"]
                line_total = Decimal(str(unit_price)) * quantity
                cur.execute(
                    """
                    INSERT INTO order_details (order_id, product_id, quantity, unit_price, line_total)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (order_id, product_id, quantity, unit_price, line_total),
                )

                cur.execute(
                    """
                    INSERT INTO payments (order_id, payment_method, payment_status, amount_paid, transaction_ref)
                    VALUES (%s, 'cash_on_delivery', 'pending', 0, %s)
                    """,
                    (order_id, f"TXN-WEB-{order_id}"),
                )

        flash("Order placed successfully!", "success")
        return redirect(url_for("order_success", order_id=order_id))
    except Exception as exc:
        flash(str(exc), "error")
        return redirect(request.referrer or url_for("home"))


def fetch_cart_items(customer_id):
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_view_cart(%s)", (customer_id,))
            return cur.fetchall()


@app.route("/cart")
@login_required
def cart():
    items = fetch_cart_items(session["customer_id"])
    total = sum(Decimal(str(item["line_total"])) for item in items)
    return render_template("cart.html", items=items, total=total)


@app.route("/cart/remove/<int:cart_item_id>", methods=["POST"])
@login_required
def remove_from_cart(cart_item_id):
    execute_remove = """
        DELETE FROM shopping_cart
        WHERE cart_item_id = %s AND customer_id = %s
    """
    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(execute_remove, (cart_item_id, session["customer_id"]))
    flash("Item removed from cart.", "info")
    return redirect(url_for("cart"))


@app.route("/cart/update/<int:cart_item_id>", methods=["POST"])
@login_required
def update_cart(cart_item_id):
    quantity = request.form.get("quantity", 1, type=int)
    if quantity < 1:
        flash("Quantity must be at least 1.", "error")
        return redirect(url_for("cart"))

    item = query_one(
        """
        SELECT sc.cart_item_id, i.stock_qty
        FROM shopping_cart sc
        JOIN inventory i ON i.product_id = sc.product_id
        WHERE sc.cart_item_id = %s AND sc.customer_id = %s
        """,
        (cart_item_id, session["customer_id"]),
    )
    if not item:
        flash("Cart item not found.", "error")
        return redirect(url_for("cart"))

    if quantity > item["stock_qty"]:
        flash(f"Only {item['stock_qty']} items in stock.", "error")
        return redirect(url_for("cart"))

    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE shopping_cart SET quantity = %s WHERE cart_item_id = %s AND customer_id = %s",
                (quantity, cart_item_id, session["customer_id"]),
            )
    flash("Cart updated.", "success")
    return redirect(url_for("cart"))


@app.route("/checkout", methods=["GET", "POST"])
@login_required
def checkout():
    items = fetch_cart_items(session["customer_id"])
    if not items:
        flash("Your cart is empty.", "warning")
        return redirect(url_for("home"))

    customer = query_one(
        """
        SELECT c.*, u.full_name, u.email
        FROM customers c
        JOIN users u ON u.user_id = c.user_id
        WHERE c.customer_id = %s
        """,
        (session["customer_id"],),
    )
    total = sum(Decimal(str(item["line_total"])) for item in items)

    if request.method == "POST":
        shipping_address = request.form.get("shipping_address", "").strip()
        payment_method = request.form.get("payment_method", "cash_on_delivery")

        if not shipping_address:
            flash("Please enter a shipping address.", "error")
            return render_template("checkout.html", items=items, total=total, customer=customer)

        try:
            with get_db() as conn:
                with conn.cursor() as cur:
                    cur.callproc(
                        "sp_create_order_from_cart",
                        (session["customer_id"], shipping_address, 0),
                    )
                    cur.execute("SELECT @_sp_create_order_from_cart_2 AS order_id")
                    result = cur.fetchone()
                    order_id = result["order_id"] if result else None
                    if not order_id:
                        raise ValueError("Failed to create order")

                    cur.callproc(
                        "sp_record_payment",
                        (order_id, payment_method, float(total), f"TXN-WEB-{order_id}"),
                    )

            flash("Order placed successfully!", "success")
            return redirect(url_for("order_success", order_id=order_id))
        except Exception as exc:
            flash(str(exc), "error")

    default_address = ", ".join(
        part
        for part in [customer["address_line"], customer["city"], customer["country"]]
        if part
    )
    return render_template(
        "checkout.html",
        items=items,
        total=total,
        customer=customer,
        default_address=default_address,
    )


@app.route("/order/<int:order_id>/success")
@login_required
def order_success(order_id):
    order = query_one(
        """
        SELECT o.*, u.full_name
        FROM orders o
        JOIN customers c ON c.customer_id = o.customer_id
        JOIN users u ON u.user_id = c.user_id
        WHERE o.order_id = %s AND o.customer_id = %s
        """,
        (order_id, session["customer_id"]),
    )
    if not order:
        flash("Order not found.", "error")
        return redirect(url_for("home"))

    details = query_all(
        """
        SELECT p.product_name, od.quantity, od.unit_price, od.line_total
        FROM order_details od
        JOIN products p ON p.product_id = od.product_id
        WHERE od.order_id = %s
        """,
        (order_id,),
    )
    return render_template("order_success.html", order=order, details=details)


@app.route("/orders")
@login_required
def orders():
    order_list = query_all(
        """
        SELECT o.order_id, o.order_date, o.order_status, o.total_amount, o.shipping_address
        FROM orders o
        WHERE o.customer_id = %s
        ORDER BY o.order_date DESC
        """,
        (session["customer_id"],),
    )
    return render_template("orders.html", orders=order_list)


@app.route("/login", methods=["GET", "POST"])
def login():
    if "customer_id" in session:
        return redirect(url_for("home"))

    next_url = request.args.get("next")
    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "")

        user = query_one(
            """
            SELECT u.user_id, u.full_name, u.email, u.password_hash, u.role, c.customer_id
            FROM users u
            LEFT JOIN customers c ON c.user_id = u.user_id
            WHERE u.email = %s AND u.role = 'customer'
            """,
            (email,),
        )

        if user and verify_password(user["password_hash"], password):
            session["user_id"] = user["user_id"]
            session["customer_id"] = user["customer_id"]
            session["full_name"] = user["full_name"]
            flash(f"Welcome back, {user['full_name']}!", "success")
            return redirect(next_url or url_for("home"))

        flash("Invalid email or password.", "error")

    return render_template("login.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if "customer_id" in session:
        return redirect(url_for("home"))

    if request.method == "POST":
        full_name = request.form.get("full_name", "").strip()
        email = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "")
        phone = request.form.get("phone", "").strip()
        address = request.form.get("address_line", "").strip()
        city = request.form.get("city", "").strip()

        if not all([full_name, email, password]):
            flash("Please fill in all required fields.", "error")
            return render_template("register.html")

        existing = query_one("SELECT user_id FROM users WHERE email = %s", (email,))
        if existing:
            flash("An account with this email already exists.", "error")
            return render_template("register.html")

        password_hash = generate_password_hash(password)
        try:
            with get_db() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        INSERT INTO users (full_name, email, password_hash, role)
                        VALUES (%s, %s, %s, 'customer')
                        """,
                        (full_name, email, password_hash),
                    )
                    user_id = cur.lastrowid
                    cur.execute(
                        """
                        INSERT INTO customers (user_id, phone, address_line, city, country)
                        VALUES (%s, %s, %s, %s, 'Pakistan')
                        """,
                        (user_id, phone, address, city),
                    )
                    customer_id = cur.lastrowid

            session["user_id"] = user_id
            session["customer_id"] = customer_id
            session["full_name"] = full_name
            flash("Account created successfully!", "success")
            return redirect(url_for("home"))
        except Exception as exc:
            flash(str(exc), "error")

    return render_template("register.html")


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("home"))


if __name__ == "__main__":
    app.run(debug=True, port=5000)
