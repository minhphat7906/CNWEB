# PowerShell Build Script for QuizMaster
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " BUILD PROJECT: QUIZMASTER (SERVLET / JSP - MVC)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$jdkBin = "C:\Program Files\Java\jdk-25\bin"
$cp = "C:\Users\Acer\.m2\repository\javax\servlet\javax.servlet-api\4.0.1\javax.servlet-api-4.0.1.jar;C:\Users\Acer\.m2\repository\org\mindrot\jbcrypt\0.4\jbcrypt-0.4.jar;C:\Users\Acer\.m2\repository\com\google\code\gson\gson\2.10.1\gson-2.10.1.jar;C:\Users\Acer\.m2\repository\com\mysql\mysql-connector-j\8.0.33\mysql-connector-j-8.0.33.jar"

Write-Host "[1/3] Compiling Java classes..." -ForegroundColor Yellow
if (!(Test-Path -Path "target\classes")) { New-Item -ItemType Directory -Path "target\classes" -Force | Out-Null }
$sources = (Get-ChildItem -Recurse -Filter "*.java" src\main\java).FullName
& "$jdkBin\javac.exe" -encoding UTF-8 -cp $cp -d target\classes $sources

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Java compilation failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[2/3] Preparing Webapp resources and libraries..." -ForegroundColor Yellow
$warDir = "target\QuizMaster"
if (Test-Path -Path $warDir) { Remove-Item -Recurse -Force $warDir }
New-Item -ItemType Directory -Path $warDir -Force | Out-Null

Copy-Item -Recurse -Force "src\main\webapp\*" $warDir
New-Item -ItemType Directory -Path "$warDir\WEB-INF\classes" -Force | Out-Null
New-Item -ItemType Directory -Path "$warDir\WEB-INF\lib" -Force | Out-Null

Copy-Item -Recurse -Force "target\classes\*" "$warDir\WEB-INF\classes\"
Copy-Item -Force "src\main\resources\db.properties" "$warDir\WEB-INF\classes\"

Copy-Item -Force "C:\Users\Acer\.m2\repository\org\mindrot\jbcrypt\0.4\jbcrypt-0.4.jar" "$warDir\WEB-INF\lib\"
Copy-Item -Force "C:\Users\Acer\.m2\repository\com\google\code\gson\gson\2.10.1\gson-2.10.1.jar" "$warDir\WEB-INF\lib\"
Copy-Item -Force "C:\Users\Acer\.m2\repository\com\mysql\mysql-connector-j\8.0.33\mysql-connector-j-8.0.33.jar" "$warDir\WEB-INF\lib\"
Copy-Item -Force "C:\Users\Acer\.m2\repository\javax\servlet\jstl\1.2\jstl-1.2.jar" "$warDir\WEB-INF\lib\"

Write-Host "[3/3] Packaging target\QuizMaster.war archive..." -ForegroundColor Yellow
& "$jdkBin\jar.exe" -cvf "target\QuizMaster.war" -C $warDir . | Out-Null

Write-Host "========================================================" -ForegroundColor Green
Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host " WAR File: target\QuizMaster.war" -ForegroundColor Green
Write-Host " Ready to deploy to Apache Tomcat webapps/ folder." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
