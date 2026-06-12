# SmartCart database setup (Windows PowerShell)
# Usage: .\scripts\setup.ps1 [-User root] [-Password your_password]

param(
    [string]$User = "root",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SqlDir = Join-Path $ProjectRoot "sql"

$mysqlArgs = @("-u", $User)
if ($Password) {
    $mysqlArgs += @("-p$Password")
}

Write-Host "Creating SmartCart database..."
& mysql @mysqlArgs -e "DROP DATABASE IF EXISTS smartcart_db; CREATE DATABASE smartcart_db;"

$files = @(
    "schema.sql",
    "indexes.sql",
    "sample_data.sql",
    "triggers.sql",
    "procedures.sql",
    "views.sql"
)

foreach ($file in $files) {
    $path = Join-Path $SqlDir $file
    Write-Host "Running $file..."
    Get-Content $path -Raw | & mysql @mysqlArgs smartcart_db
    if ($LASTEXITCODE -ne 0) {
        throw "Failed while running $file"
    }
}

Write-Host "SmartCart setup completed successfully."
Write-Host "Run queries with: mysql -u $User -p smartcart_db < sql/queries.sql"
