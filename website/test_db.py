"""Test database connection for SmartCart website."""
from config import DB_CONFIG
from db import get_connection

print("Testing MySQL connection...")
print(f"  User: {DB_CONFIG['user']}")
print(f"  Database: {DB_CONFIG['database']}")
print(f"  Host: {DB_CONFIG['host']}")

try:
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) AS c FROM products")
        count = cur.fetchone()["c"]
    conn.close()
    print(f"SUCCESS: Connected. Found {count} products.")
except Exception as exc:
    print(f"FAILED: {exc}")
    print("\nRun sql/create_web_user.sql in MySQL Workbench, then try again.")
