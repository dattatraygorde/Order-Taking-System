@echo off
echo ========================================
echo Order Taking Application - Tomcat 9 Deployment
echo ========================================
echo.

set TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0
set APP_NAME=order-taking-0.0.1-SNAPSHOT
set PROJECT_DIR=E:\Order Taking System

echo Step 1: Building WAR file...
cd /d "%PROJECT_DIR%"
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Build successful!
echo.

echo Step 2: Stopping Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat"
timeout /t 5 /nobreak > nul
echo.

echo Step 3: Cleaning old deployment...
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%.war" (
    del /F /Q "%TOMCAT_HOME%\webapps\%APP_NAME%.war"
    echo Deleted old WAR file
)
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%" (
    rmdir /S /Q "%TOMCAT_HOME%\webapps\%APP_NAME%"
    echo Deleted old deployment folder
)
echo.

echo Step 4: Deploying new WAR file...
copy /Y "%PROJECT_DIR%\target\%APP_NAME%.war" "%TOMCAT_HOME%\webapps\"
if errorlevel 1 (
    echo ERROR: Failed to copy WAR file!
    pause
    exit /b 1
)
echo WAR file copied successfully!
echo.

echo Step 5: Setting Java 17 environment and starting Tomcat...
set JAVA_HOME=C:\Program Files\Java\jdk-17
set JRE_HOME=C:\Program Files\Java\jdk-17
echo Using Java from: %JAVA_HOME%
start "" "%TOMCAT_HOME%\bin\startup.bat"
echo.

echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo The application is being deployed...
echo Wait 10-15 seconds for Tomcat to start and deploy the application.
echo.
echo Then access the application at:
echo   http://localhost:8080/%APP_NAME%/
echo.
echo Login credentials:
echo   Username: admin
echo   Password: admin123
echo.
echo Check deployment status in Tomcat logs:
echo   %TOMCAT_HOME%\logs\catalina.2025-11-16.log
echo.
pause

