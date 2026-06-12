import os

from pathlib import Path

try:
    from dotenv import load_dotenv

    load_dotenv(Path(__file__).parent / ".env")
except ImportError:
    pass

DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "smartcart_db"),
    "port": int(os.getenv("MYSQL_PORT", "3306")),
    "charset": "utf8mb4",
    "autocommit": False,
}

try:
    from config_local import DB_OVERRIDES

    DB_CONFIG.update(DB_OVERRIDES)
except ImportError:
    pass

SECRET_KEY = os.getenv("SECRET_KEY", "smartcart-dev-secret-change-in-production")
