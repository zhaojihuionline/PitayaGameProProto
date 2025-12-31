@echo off
setlocal enabledelayedexpansion
REM Generate protobuf Go code (Windows) - Supports nested directory structure
REM Recursively finds and generates all .proto files

set SCRIPT_DIR=%~dp0
set PROTO_DIR=%SCRIPT_DIR%proto
set OUT_DIR=%SCRIPT_DIR%pb\golang

echo ==========================================
echo   Protobuf Go Code Generator
echo ==========================================
echo Proto Directory: %PROTO_DIR%
echo Output Directory: %OUT_DIR%
echo.

REM Create output directory
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

REM Change to proto directory
cd /d "%PROTO_DIR%"

REM Generation counters
set /a total_files=0
set /a success_count=0
set /a error_count=0

REM Find all .proto files recursively
echo Searching for .proto files...
echo.

for /r %%f in (*.proto) do (
    set /a total_files+=1
    
    REM Get relative path from proto directory
    set "full_path=%%f"
    set "rel_path=!full_path:%PROTO_DIR%\=!"
    
    echo [!total_files!] Generating: !rel_path!
    
    REM Generate proto file
    protoc --proto_path=. --go_out="%OUT_DIR%" --go_opt=paths=source_relative "!rel_path!" 2>nul
    if errorlevel 1 (
        echo     [FAILED]
        set /a error_count+=1
    ) else (
        echo     [OK]
        set /a success_count+=1
    )
    echo.
)

REM Check if any files were found
if %total_files% equ 0 (
    echo [WARNING] No .proto files found in %PROTO_DIR%
    echo.
)

REM Output statistics
echo ==========================================
echo   Generation Complete
echo ==========================================
echo Total Files: %total_files%
echo Succeeded: %success_count%
echo Failed: %error_count%
echo.

if %error_count% equ 0 (
    if %total_files% gtr 0 (
        echo [SUCCESS] All Protobuf files generated successfully!
        echo Output: %OUT_DIR%
    ) else (
        echo [WARNING] No files to generate
    )
) else (
    echo [ERROR] Some files failed to generate, please check errors
)

echo.
pause
