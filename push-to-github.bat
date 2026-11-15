@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo        GK Hemanth Portfolio - Push to GitHub
echo ========================================================
echo.

set /p REPO_URL="Enter your GitHub Repository URL (e.g. https://github.com/hemanthgadivemula-byte/portfolio.git): "

if "%REPO_URL%"=="" (
    echo Error: No repository URL provided.
    pause
    exit /b 1
)

echo.
echo Adding remote origin: %REPO_URL%
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git branch -M main

echo.
echo Pushing to GitHub main branch...
git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo SUCCESS: Portfolio successfully pushed to GitHub!
    echo ========================================================
) else (
    echo.
    echo Error during push. Please check your GitHub repository permissions or credentials.
)

pause
