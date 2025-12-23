@echo off
echo ========================================
echo Starting Tomcat 9 with Java 17
echo ========================================
echo.

set CATALINA_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0
set JAVA_HOME=C:\Program Files\Java\jdk-17
set JRE_HOME=C:\Program Files\Java\jdk-17

echo Java Home: %JAVA_HOME%
echo Tomcat Home: %CATALINA_HOME%
echo.

echo Verifying Java version...
"%JAVA_HOME%\bin\java.exe" -version
echo.

echo Starting Tomcat...
cd /d "%CATALINA_HOME%\bin"
call startup.bat

echo.
echo Tomcat startup command executed.
echo Wait 10-15 seconds for the application to deploy.
echo.
echo Then access: http://localhost:8080/order-taking-0.0.1-SNAPSHOT/
echo.
echo To view logs in real-time, run:
echo   tail -f "%CATALINA_HOME%\logs\catalina.2025-11-16.log"
echo.
pause

