@echo off
setlocal EnableDelayedExpansion

:: ── Colors (via PowerShell) ──────────────────────────────────────────────────
call :info "Checking dependencies..."

:: ── Dependencies ─────────────────────────────────────────────────────────────
where git >nul 2>&1    || call :error "git is not installed. Install from https://git-scm.com"
where python >nul 2>&1 || call :error "python is not installed. Install from https://python.org"
call :success "Dependencies OK"

:: ── Clone or update ──────────────────────────────────────────────────────────
if exist "%USERPROFILE%\nxrsecrypt" (
    call :warn "~\nxrsecrypt already exists, pulling latest..."
    git -C "%USERPROFILE%\nxrsecrypt" pull || call :error "git pull failed"
) else (
    call :info "Cloning nxrsecrypt..."
    git clone https://github.com/nxrs3/nxrsecrypt "%USERPROFILE%\nxrsecrypt" || call :error "git clone failed"
    call :success "Cloned successfully"
)

:: ── Venv + deps ──────────────────────────────────────────────────────────────
call :info "Setting up virtual environment..."
cd /d "%USERPROFILE%\nxrsecrypt" || call :error "Could not enter nxrsecrypt directory"
python -m venv venv || call :error "Failed to create virtual environment"
call venv\Scripts\activate.bat

call :info "Upgrading pip..."
pip install --upgrade pip -q

call :info "Installing requirements..."
pip install -r requirements.txt -q || call :error "Failed to install requirements"
call deactivate
call :success "Dependencies installed"

:: ── Launcher .bat ────────────────────────────────────────────────────────────
call :info "Creating launcher script..."
set SCRIPT=%USERPROFILE%\nxrsecrypt\nxrsecrypt.bat
(
    echo @echo off
    echo cd /d %%USERPROFILE%%\nxrsecrypt
    echo call venv\Scripts\activate.bat
    echo python %%USERPROFILE%%\nxrsecrypt\main.py
    echo call deactivate
    echo call cd /d "%USERPROFILE%
) > "%SCRIPT%" || call :error "Failed to create launcher script"
call :success "Launcher created at %SCRIPT%"

:: ── PATH ─────────────────────────────────────────────────────────────────────
call :info "Updating PATH..."
echo !PATH! | findstr /i "%USERPROFILE%\nxrsecrypt" >nul
if errorlevel 1 (
    setx PATH "!PATH!;%USERPROFILE%\nxrsecrypt" >nul || call :warn "Could not update PATH. You may need to add %USERPROFILE%\nxrsecrypt manually."
    call :success "PATH updated"
) else (
    call :warn "PATH already contains nxrsecrypt, skipping"
)

:: ── Done ─────────────────────────────────────────────────────────────────────
cd /d "%USERPROFILE%
echo.
powershell -Command "Write-Host 'Install complete! ' -ForegroundColor Green -NoNewline; Write-Host 'Restart your terminal and run: ' -NoNewline; Write-Host 'nxrsecrypt' -ForegroundColor Cyan"
exit /b 0

:: ── Helpers ──────────────────────────────────────────────────────────────────
:info
    powershell -Command "Write-Host '[*] ' -ForegroundColor Cyan -NoNewline; Write-Host '%~1'"
    exit /b 0
:success
    powershell -Command "Write-Host '[^checkmark] ' -ForegroundColor Green -NoNewline; Write-Host '%~1'"
    exit /b 0
:warn
    powershell -Command "Write-Host '[!] ' -ForegroundColor Yellow -NoNewline; Write-Host '%~1'"
    exit /b 0
:error
    powershell -Command "Write-Host '[X] ' -ForegroundColor Red -NoNewline; Write-Host '%~1'"
    exit /b 1
