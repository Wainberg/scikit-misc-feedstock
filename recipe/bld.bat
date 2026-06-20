@echo off
mkdir builddir

:: Conda-forge's flang 5.0.0 is too old to accept the "legacy" standard flag
set "MESON_ARGS=%MESON_ARGS% -Dfortran_std=none"

:: Meson passes -fms-runtime-lib=dll to Fortran, which Flang 5.0.0 doesn't support.
:: Use a small Python wrapper to intercept and remove this flag.
echo import sys, subprocess > "%SRC_DIR%\flang_wrapper.py"
echo args = [a for a in sys.argv[1:] if a != '-fms-runtime-lib=dll'] >> "%SRC_DIR%\flang_wrapper.py"
echo sys.exit(subprocess.run(['flang.exe'] + args).returncode) >> "%SRC_DIR%\flang_wrapper.py"

echo @echo off > "%SRC_DIR%\flang_wrapper.bat"
echo "%PYTHON%" "%SRC_DIR%\flang_wrapper.py" %%* >> "%SRC_DIR%\flang_wrapper.bat"

:: Replace backslashes with forward slashes to avoid Python unicode escape errors in __config__.py
set "FC_WRAPPER=%SRC_DIR%\flang_wrapper.bat"
set "FC=%FC_WRAPPER:\=/%"

:: Build and install the wheel
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Csetup-args=%MESON_ARGS: = -Csetup-args=%

if errorlevel 1 (
    type builddir\meson-logs\meson-log.txt
    exit /b 1
)

for %%f in (dist\*.whl) do (
    %PYTHON% -m pip install -vvv "%%f"
)