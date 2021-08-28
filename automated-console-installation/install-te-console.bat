@echo off
:: Check provisioning programs for console binary
if exist "C:\provisioning-programs\installer-server-windows-amd64.exe" (
  "C:\provisioning-programs\installer-server-windows-amd64.exe" --unattendedmodeui none --mode unattended --ServerSettings_teServicesPassphrase my-plaintext-services-passphrase --AgentSettings_InstallRTM true --noStartServices true
)

:: Delete TE_ROOT/server/data/install.new - This file marks this as a new install and TE will run fasttrack.
del "C:\program files\tripwire\te\server\data\install.new"

:: Create licenses directory
mkdir "C:\program files\tripwire\te\server\data\licenses"

:: Copy license file
copy "C:\provisioning-programs\*license*.cert" "C:\program files\tripwire\te\server\data\licenses\"

:: Copy MySQL connector
copy "C:\provisioning-programs\mysql-connector-java*.jar" "C:\program files\tripwire\te\server\lib\jdbc\"

:: set tw_java_home
:::: This is dumb, iterates over every directory in the java dir, and hopefully the last one found is the desired JRE!
for /D %%a in ("C:\program files\java\*") do set TW_JAVA_HOME_TMP=%%a
set TW_JAVA_HOME=%TW_JAVA_HOME_TMP%
setx TW_JAVA_HOME "%TW_JAVA_HOME_TMP%"

:: Set db password
call "C:\program files\tripwire\te\server\bin\tetool.cmd" setdatabasepass my-plaintext-services-passphrase my-plaintext-db-password

:: Generate keystores?
call "C:\program files\tripwire\te\server\bin\tetool.cmd" setchannelpass my-plaintext-services-passphrase my-plaintext-services-passphrase
call "C:\program files\tripwire\te\agent\bin\tetool.cmd" setchannelpass my-plaintext-services-passphrase my-plaintext-services-passphrase

:: Don't require the administrator password be changed before the console is usable
echo tw.password.allowAdministratorDefaultPassword=true >> "C:\program files\tripwire\te\server\data\config\server.properties"
