@echo off
git add .
set /p message=What did you change? 
git commit -m "%message%"
git push
pause