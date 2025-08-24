@echo off
setlocal EnableExtensions

rem --- ensure VS2022 dev environment (adjust Edition if needed) ---
if not defined VSCMD_ARG_TGT_ARCH (
  call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64
)

echo ==========================================================
echo                BUILDING LIBREBOX ENGINE
echo ==========================================================

set "CMAKE_GENERATOR=Visual Studio 17 2022"
rem set "CMAKE_TOOLSET=v143"          rem --- force the toolset
set "CMAKE_BUILD_TYPE=Release"
set "SCRIPT_DIR=%~dp0"

set "PROJECT_ROOT=%SCRIPT_DIR%"
set "BUILD_DIR=%PROJECT_ROOT%build"
set "DIST_DIR=%PROJECT_ROOT%dist"
set "CMAKE_PREFIX_PATH=%PROJECT_ROOT%third_party\vendor"

set "NO_CLEAN=0"
if /i "%~1"=="-no-clean" set "NO_CLEAN=1"

echo.
if "%NO_CLEAN%"=="0" (
  echo [1/4] Cleaning build directory only...
  if exist "%BUILD_DIR%" rd /s /q "%BUILD_DIR%"
) else (
  echo [1/4] Skipping clean (because -no-clean was specified)
)

echo.
echo [2/4] Configuring Librebox...
echo      Build Dir: %BUILD_DIR%
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
pushd "%BUILD_DIR%"

rem --- force toolset here (-T v143) ---
cmake .. -G "%CMAKE_GENERATOR%" -A x64 -T v143 -DCMAKE_PREFIX_PATH="%CMAKE_PREFIX_PATH%"
if %errorlevel% neq 0 ( echo.[ERROR] CMake configuration failed. & popd & exit /b 1 )

echo.
echo [3/4] Building Librebox (%CMAKE_BUILD_TYPE%)...
cmake --build . --config %CMAKE_BUILD_TYPE%
if %errorlevel% neq 0 ( echo.[ERROR] Librebox build failed. & popd & exit /b 1 )

echo.
echo [4/4] Installing to 'dist'...
DESTDIR="$DIST_DIR" cmake --install . --config "${CMAKE_BUILD_TYPE}"
if %errorlevel% neq 0 ( echo.[ERROR] Installation failed. & popd & exit /b 1 )

popd
echo.
echo ==========================================================
echo                BUILD SUCCESSFUL
echo ==========================================================
