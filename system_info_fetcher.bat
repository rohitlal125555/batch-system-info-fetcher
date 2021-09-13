
@echo off
if %os%==Windows_NT goto WINNT
goto NOCON

:WINNT
echo INFO: Please wait ...
echo INFO: Windows based system detected
echo INFO: Computer Name: %computername%

REM Windows Batch File to collect information about system
REM - useful for debugging issues
REM Written by Rohit Lal
setlocal

rem ----------------------------------------------------------------------------------------------------------------------
rem SETTING UP CONFIG VARIABLES
rem ----------------------------------------------------------------------------------------------------------------------
REM Get the current directory name
set "curpath=%cd%"
set SaveFolderName=%curpath%
set saveFileEncoding="log"
set filePointer="%SaveFolderName%\systeminfo.%saveFileEncoding%"
set filePointer_softlist="%SaveFolderName%\systeminfo.%saveFileEncoding%"
set checksum_filePointer="%SaveFolderName%\key.%saveFileEncoding%"
set tempFilePointer="%SaveFolderName%\temp.datafilexyz"

set delimiter_string=--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo INFO: Saving output to files in: "%SaveFolderName%"
if NOT EXIST "%SaveFolderName%" mkdir "%SaveFolderName%"
if NOT EXIST "%SaveFolderName%" (
  echo ERROR: Could not create directory "%SaveFolderName%"
  goto :end
)


echo. > %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem PRINTING SYSTEM NAME & CURRENT DATETIME FOR RECORD PURPOSES
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string% >> %filePointer%
echo RECORD-SECTION-A : SYSTEM NAME and CURRENT DATE TIME >> %filePointer%
echo %delimiter_string% >> %filePointer%

echo System Info for Computer:- %COMPUTERNAME% >> %filePointer%
echo Current Date and Time:- %DATE% %TIME% >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING CORE SYSTEM INFO
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string% >> %filePointer%
echo RECORD-SECTION-B : CORE SYSTEM INFORMATION >> %filePointer%
echo %delimiter_string% >> %filePointer%

echo INFO: Getting system info ...
systeminfo >> %filePointer%
REM Get Computer Serial Number
FOR /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do SET serialnumber=%%A
echo Serial Number:             %serialnumber% >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING PROCESSOR INFORMATION
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-C : PROCESSOR INFORMATION >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting Processor info ...
rem wmic cpu list full | more >> %filePointer%
wmic cpu get caption, deviceid, name, numberofcores, NumberOfLogicalProcessors, maxclockspeed, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed, status /format:list | more >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING IP ADDRESS INFORMATION
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-D : IP ADDRESS INFORMATION >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting IP address info ...
ipconfig >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING MAC ADDRESS INFORMATION
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-E : MAC ADDRESS INFORMATION >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting MAC address info ...
getmac >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING INTERNET EXPLORER INFO
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-F : INTERNET EXPLORER VERSION >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Looking up IE Version
REM See http://support.microsoft.com/kb/969393
REM Test if svcVersion key is present. If it is present, then it is IE10 or
REM later.  Otherwise rely on Version key
%windir%\system32\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer" /v svcVersion >NUL 2>NUL
if not ErrorLevel 1 (
  for /f "usebackq tokens=3" %%i in (`%windir%\system32\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer" /v svcVersion ^| %windir%\system32\findstr /i /l /c:"REG_SZ"`) do set _IEVersion=%%i
) else (
  REM svcVersion KEY NOT Found. Must be IE9 or earlier so use Version Key
  for /f "usebackq tokens=3" %%i in (`%windir%\system32\reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer" /v Version ^| %windir%\system32\findstr /i /l /c:"REG_SZ"`) do set _IEVersion=%%i
)
echo Found IE Version=%_IEVersion%>> %filePointer%
REM Get IE major version
for /f "tokens=1 Delims=." %%i in ("%_IEVERSION%") do set _IEMajorVersion=%%i
echo IE Major version: %_IEMajorVersion%>> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING USERS LIST
rem ----------------------------------------------------------------------------------------------------------------------
echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-G : USERS LIST >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting users list ...
rem wmic ComputerSystem Get UserName /value | more >> %filePointer%
query user >> %filePointer%
echo List of All Users: >> %filePointer%
dir /b C:\Users >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING RUNNING PROCESSES INFO
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-H : RUNNING PROCESSES >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting current task list ...
tasklist /v >> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING INSTALLED SOFTWARES
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-H : SOFTWARE LIST >> %filePointer%
echo %delimiter_string%>> %filePointer%

echo INFO: Getting Softwares list ...
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s >>  %filePointer_softlist%
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s >>  %filePointer_softlist%


rem ----------------------------------------------------------------------------------------------------------------------
rem GETTING DISK USAGE INFORMATION
rem ----------------------------------------------------------------------------------------------------------------------


echo %delimiter_string%>> %filePointer%
echo RECORD-SECTION-I : DISK USAGE >> %filePointer%
echo %delimiter_string%>> %filePointer%

wmic logicaldisk get size, freespace, caption /value | more >> %filePointer%

echo %delimiter_string%>> %filePointer%
echo END OF FILE >> %filePointer%
echo %delimiter_string%>> %filePointer%


rem ----------------------------------------------------------------------------------------------------------------------
rem GENERATING CHECKSUM
rem ----------------------------------------------------------------------------------------------------------------------


rem Creating HASH of the output & appending it to the end to detect if output file is manually altered.
CertUtil -hashfile %filePointer% MD5 >> %tempFilePointer%
for %%f in (%tempFilePointer%) do type %%f >> %filePointer%
del %tempFilePointer%



goto END

rem ----------------------------------------------------------------------------------------------------------------------
rem ERROR HANDLING FOR NON-WINDOWS SYSTEM
rem ----------------------------------------------------------------------------------------------------------------------
:NOCON
echo Error...Invalid Operating System...
echo Error...No actions were made...
goto END

:END
