@echo off

:: Force clang-cl + lld-link for mixing MSVC C objects with flang Fortran objects
set "CC=clang-cl"

:: The Fortran runtime import lib lives in flang's clang resource dir.
:: Find it dynamically and add it to LIB so lld-link can find it.
for /f "delims=" %%d in ('dir /b /s "%BUILD_PREFIX%\flang_rt.runtime.dynamic.lib" 2^>nul') do set "LIB=%LIB%;%%~dpd"

:: Use pip's --config-settings to override the fortran_std=legacy setting in meson.build, which LLVM Flang does not recognize
%PYTHON% -m pip install . --no-deps --no-build-isolation -vvv --config-settings=setup-args="-Dfortran_std=none"