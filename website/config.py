import os

from pathlib import Path

try:
    from dotenv import load_dotenv

    load_dotenv(Path(__file__).parent / ".env")
except ImportError:
    pass

DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST") or os.getenv("MYSQLHOST", "localhost"),
    "user": os.getenv("MYSQL_USER") or os.getenv("MYSQLUSER", "root"),
    "password": os.getenv("MYSQL_PASSWORD") or os.getenv("MYSQLPASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE") or os.getenv("MYSQLDATABASE", "smartcart_db"),
    "port": int(os.getenv("MYSQL_PORT") or os.getenv("MYSQLPORT", "3306")),
    "charset": "utf8mb4",
    "autocommit": False,
}

try:
    from config_local import DB_OVERRIDES

    DB_CONFIG.update(DB_OVERRIDES)
except ImportError:
    pass

SECRET_KEY = os.getenv("SECRET_KEY", "smartcart-dev-secret-change-in-production")
