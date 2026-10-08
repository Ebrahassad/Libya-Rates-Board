@echo off
setlocal
set APP_HOME=%~dp0
set JAR=%APP_HOME%gradle\wrapper\gradle-wrapper.jar
set URL=https://raw.githubusercontent.com/gradle/gradle/v9.3.1/gradle/wrapper/gradle-wrapper.jar

if not exist "%JAR%" (
  echo Gradle wrapper JAR not found. Downloading...
  powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%JAR%'"
)

if not exist "%JAR%" (
  echo ERROR: Could not obtain gradle-wrapper.jar
  exit /b 1
)

java %JAVA_OPTS% -Dorg.gradle.appname=gradlew -classpath "%JAR%" org.gradle.wrapper.GradleWrapperMain %*
endlocal
