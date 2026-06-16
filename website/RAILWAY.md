# Railway deployment — auto database setup (Option 2)

## What this does
When deployed on Railway, the website **automatically creates all tables and sample data** on first start.
You do **NOT** need MySQL Workbench or Public Network connection.

## Railway setup (simplified)

### 1. Add MySQL service
- New Project → **+ New** → **Database** → **MySQL**

### 2. Add website from GitHub
- **+ New** → **GitHub Repo** → `BSAI24029_SMARTCART`
- **Settings** → **Root Directory:** `website`

### 3. Link MySQL variables to web service
On the **web service** → **Variables** → **Add Reference** (or add manually):

| Variable | Value |
|----------|--------|
| `MYSQL_HOST` | Reference MySQL → `MYSQLHOST` (will be `mysql.railway.internal`) |
| `MYSQL_PORT` | Reference MySQL → `MYSQLPORT` |
| `MYSQL_USER` | Reference MySQL → `MYSQLUSER` |
| `MYSQL_PASSWORD` | Reference MySQL → `MYSQLPASSWORD` |
| `MYSQL_DATABASE` | Reference MySQL → `MYSQLDATABASE` |
| `SECRET_KEY` | any random string |

Railway sets `RAILWAY_ENVIRONMENT` automatically — this enables auto-init.

### 4. Generate domain
- Web service → **Settings** → **Networking** → **Generate Domain**

### 5. Wait for deploy
First deploy takes 1–2 minutes while SQL files run automatically.
Check **Deployments** → **View Logs** for "Database initialization completed."

### 6. Open your live site
Login: `khizra@example.com` / `password123`

## Push latest code first
```powershell
cd C:\Users\Hp\OneDrive\DATABASE
git add website/
git commit -m "Add Railway auto database initialization"
git push origin main
```

## Troubleshooting
| Issue | Fix |
|-------|-----|
| Empty site / DB error | Check Variables are linked to MySQL service |
| Init failed in logs | Redeploy web service after MySQL is running |
| Still empty after deploy | Add variable `AUTO_INIT_DB=true` and redeploy |
