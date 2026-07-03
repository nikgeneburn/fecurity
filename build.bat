@echo off
setlocal

set "ROOT=%~dp0"
set "DARKLUA=%ROOT%bin\darklua.exe"
set "ENTRY=%ROOT%src\main.luau"

if not exist "%DARKLUA%" (
    echo [build] darklua.exe not found at %DARKLUA%
    exit /b 1
)

if not exist "%ROOT%dist" mkdir "%ROOT%dist"

echo [build] Release: dist\Fecurity.lua
"%DARKLUA%" process --config "%ROOT%.darklua.json" "%ENTRY%" "%ROOT%dist\Fecurity.lua"
if errorlevel 1 exit /b 1

echo [build] Dev:     dist\Fecurity.dev.lua
"%DARKLUA%" process --config "%ROOT%.darklua.dev.json" "%ENTRY%" "%ROOT%dist\Fecurity.dev.lua"
if errorlevel 1 exit /b 1

echo [build] done.
endlocal

