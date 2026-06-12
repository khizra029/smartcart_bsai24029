@echo off
echo Installing Python packages...
pip install -r requirements.txt

echo.
echo Starting SmartCart website...
echo Open http://127.0.0.1:5000 in your browser
echo.
echo Demo login: khizra@example.com / password123
echo.
python app.py
