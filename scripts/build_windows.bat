@echo off
REM Builds the sellable UNOPOS for Windows:
REM   1. the release app folder  (build\windows\x64\runner\Release)
REM   2. a one-file installer    (build\installer\UNOPOS-Setup-<version>.exe)
REM The installer step needs Inno Setup 6 (https://jrsoftware.org/isdl.php).
setlocal
cd /d "%~dp0.."

for /f "tokens=2 delims=: " %%v in ('findstr /b "version:" pubspec.yaml') do set FULLVER=%%v
for /f "tokens=1 delims=+" %%v in ("%FULLVER%") do set APPVER=%%v
echo Building UNOPOS %APPVER% ...

call flutter pub get || goto :fail
call flutter build windows --release || goto :fail

set REL=build\windows\x64\runner\Release
REM Ship the Visual C++ runtime next to the app so it starts on PCs that
REM never installed it.
for %%d in (msvcp140.dll vcruntime140.dll vcruntime140_1.dll) do (
  if exist "%WINDIR%\System32\%%d" copy /y "%WINDIR%\System32\%%d" "%REL%\" >nul
)

set ISCC=
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set ISCC="%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set ISCC="%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set ISCC="%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
if not defined ISCC (
  echo.
  echo App built at %REL%
  echo Inno Setup 6 not found - install it from https://jrsoftware.org/isdl.php to also get the installer.
  goto :done
)
call %ISCC% /DAppVersion=%APPVER% installer\unopos.iss || goto :fail
echo.
echo Installer ready: build\installer\UNOPOS-Setup-%APPVER%.exe
goto :done

:fail
echo.
echo BUILD FAILED - send the messages above.
:done
pause
