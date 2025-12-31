@echo off
setlocal enabledelayedexpansion
REM Generate protobuf C# code (Windows) - Supports nested directory structure
REM Recursively finds and generates all .proto files

set SCRIPT_DIR=%~dp0
set PROTO_DIR=%SCRIPT_DIR%proto
set OUT_DIR=%SCRIPT_DIR%pb\csharp

REM Unity project paths
set UNITY_PROTOS_ROOT=D:\Company\UnityPitayaGamePro\Assets\Scripts\Protocol\protos
set UNITY_PROTO_DIR=%UNITY_PROTOS_ROOT%\pb\csharp
set UNITY_PROTO_SRC_DIR=%UNITY_PROTOS_ROOT%\proto

echo ==========================================
echo   Protobuf C# Code Generator
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
    
    REM Extract directory path (remove file name)
    for %%p in ("!rel_path!") do set "dir_path=%%~dpp"
    set "dir_path=!dir_path:~0,-1!"
    set "dir_path=!dir_path:%PROTO_DIR%\=!"
    
    echo [!total_files!] Generating: !rel_path!
    echo     Output Dir: !dir_path!
    
    REM Create output directory matching proto structure
    if not exist "%OUT_DIR%\!dir_path!" mkdir "%OUT_DIR%\!dir_path!"
    
    REM Generate proto file to matching directory structure
    protoc --proto_path=. --csharp_out="%OUT_DIR%\!dir_path!" "!rel_path!" 2>nul
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

REM Check results and copy to Unity
if %error_count% gtr 0 (
    echo [ERROR] Some files failed to generate, please check errors above
    goto :end
)

if %total_files% equ 0 (
    echo [WARNING] No .proto files found
    goto :end
)

echo [SUCCESS] All Protobuf C# files generated successfully!
echo Output: %OUT_DIR%
echo.

REM Copy to Unity project
echo ==========================================
echo   Copying to Unity Project
echo ==========================================
echo Target pb/csharp: %UNITY_PROTO_DIR%
echo Target proto:     %UNITY_PROTO_SRC_DIR%
echo.

REM Check if Unity project directory exists
if not exist "%UNITY_PROTOS_ROOT%" (
    echo [ERROR] Unity project directory not found!
    echo Please check the path: %UNITY_PROTOS_ROOT%
    echo.
    goto :end
)

REM Clean target pb/csharp directory
if exist "%UNITY_PROTO_DIR%" (
    echo Cleaning pb/csharp directory...
    rd /s /q "%UNITY_PROTO_DIR%" 2>nul
    if errorlevel 1 (
        echo [WARNING] Failed to clean pb/csharp directory, it may be in use
        echo Attempting to continue...
    ) else (
        echo [OK] pb/csharp directory cleaned
    )
)

REM Clean target proto directory
if exist "%UNITY_PROTO_SRC_DIR%" (
    echo Cleaning proto directory...
    rd /s /q "%UNITY_PROTO_SRC_DIR%" 2>nul
    if errorlevel 1 (
        echo [WARNING] Failed to clean proto directory, it may be in use
        echo Attempting to continue...
    ) else (
        echo [OK] proto directory cleaned
    )
)

REM Create target directories
mkdir "%UNITY_PROTO_DIR%" 2>nul
mkdir "%UNITY_PROTO_SRC_DIR%" 2>nul

REM Copy pb/csharp files (generated C# files)
echo Copying pb/csharp files...
xcopy "%OUT_DIR%\*" "%UNITY_PROTO_DIR%\" /E /I /Y /Q
if errorlevel 1 (
    echo [ERROR] Failed to copy pb/csharp files to Unity project
    goto :end
)
echo [OK] pb/csharp files copied successfully

REM Copy proto files (source .proto files)
echo Copying proto files...
xcopy "%PROTO_DIR%\*" "%UNITY_PROTO_SRC_DIR%\" /E /I /Y /Q
if errorlevel 1 (
    echo [ERROR] Failed to copy proto files to Unity project
    goto :end
)
echo [OK] proto files copied successfully

echo.
echo [SUCCESS] All files copied to Unity project!
echo   - pb/csharp/ (generated C# files)
echo   - proto/     (source .proto files)
echo.

:end
echo.
pause
