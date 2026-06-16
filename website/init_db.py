"""
Auto-initialize SmartCart database on Railway (private network only).
Runs once when the products table is missing or empty.
"""
import logging
import os
import re
from pathlib import Path

import pymysql

from db import get_connection

logger = logging.getLogger(__name__)

SQL_DIR = Path(__file__).resolve().parent / "sql"

INIT_FILES = [
    "schema.sql",
    "indexes.sql",
    "sample_data.sql",
    "triggers.sql",
    "procedures.sql",
    "views.sql",
]


def should_auto_init():
    return bool(os.getenv("RAILWAY_ENVIRONMENT")) or os.getenv(
        "AUTO_INIT_DB", ""
    ).lower() in ("1", "true", "yes")


def database_is_ready(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT COUNT(*) AS table_count
            FROM information_schema.tables
            WHERE table_schema = DATABASE()
              AND table_name = 'products'
            """
        )
        if cur.fetchone()["table_count"] == 0:
            return False

        cur.execute("SELECT COUNT(*) AS product_count FROM products")
        return cur.fetchone()["product_count"] > 0


def parse_sql_statements(content):
    """Parse SQL files, including DELIMITER blocks used by triggers/procedures."""
    content = re.sub(r"^\s*--.*$", "", content, flags=re.MULTILINE)

    if "DELIMITER" in content.upper():
        content = re.sub(r"^\s*DELIMITER\s+.*$", "", content, flags=re.MULTILINE)
        parts = [part.strip() for part in content.split("$$") if part.strip()]
        statements = []
        for part in parts:
            statement = part.strip()
            if statement.upper().startswith("CREATE"):
                if not statement.rstrip().endswith(";"):
                    statement += ";"
                statements.append(statement)
        return statements

    statements = []
    for chunk in content.split(";"):
        statement = chunk.strip()
        if statement and not statement.upper().startswith("DELIMITER"):
            statements.append(statement + ";")
    return statements


def execute_sql_file(cursor, filename):
    path = SQL_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"Missing SQL file: {path}")

    logger.info("Running %s", filename)
    statements = parse_sql_statements(path.read_text(encoding="utf-8"))

    for statement in statements:
        cursor.execute(statement)


def ensure_database_initialized():
    if not should_auto_init():
        return

    conn = get_connection()
    try:
        if database_is_ready(conn):
            logger.info("Database already initialized — skipping setup.")
            return

        logger.info("Initializing SmartCart database...")
        with conn.cursor() as cur:
            for filename in INIT_FILES:
                try:
                    execute_sql_file(cur, filename)
                except pymysql.err.OperationalError as exc:
                    code = exc.args[0] if exc.args else None
                    # Ignore duplicate object errors if another worker initialized first.
                    if code in (1050, 1051, 1060, 1061, 1304, 1359):
                        logger.warning("Skipping existing object in %s: %s", filename, exc)
                        continue
                    raise
        conn.commit()
        logger.info("Database initialization completed.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
