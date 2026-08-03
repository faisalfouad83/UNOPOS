@echo off
REM Builds the sellable Windows .exe for UNOPOS, pointed at the live Supabase project.
cd /d "%~dp0.."
flutter build windows --release --dart-define=UNOPOS_USE_SUPABASE=true --dart-define=SUPABASE_URL=https://ydfhhvkzasqvgqlsuxdh.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkZmhodmt6YXNxdmdxbHN1eGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2OTY0NDIsImV4cCI6MjEwMTI3MjQ0Mn0.IWC2u0OFYe6Re-6zdvzdcMe_W69qRGn-EAT8wvSSceo
echo.
echo Done. The app folder to zip and distribute is at:
echo build\windows\x64\runner\Release
pause
