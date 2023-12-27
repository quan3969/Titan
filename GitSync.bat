@echo off

rem By Q3aN, 231227
set ver=v01

echo.
echo =====================================================
echo  Welcome to GitSync %ver%, syncing up now:
echo.

call :Git_Sync_Up "D:\Git\0_ADL_Venus2_15"
call :Git_Sync_Up "D:\Git\0_RPL_Venus3_16"
call :Git_Sync_Up "D:\Git\0_TGL_Venus_13"
call :Git_Sync_Up "D:\Git\0_TGL_Venus_15"
call :Git_Sync_Dn "D:\Git\1_LNL_AMI_CORE" "main"
call :Git_Sync_Dn "D:\Git\1_LNL_Venus5_14" "main"
call :Git_Sync_Dn "D:\Git\1_MTL_Mars4_16" "main"
call :Git_Sync_Dn "D:\Git\1_MTL_Venus4_14" "main"
call :Git_Sync_Dn "D:\Git\1_MTL_Venus4_16" "main"
call :Git_Sync_Dn "D:\Git\1_MTL_Venus4_16E" "main"

echo.
echo =====================================================
echo.

pause
exit

:: Sync the local repo form remote repo
:: %~1: repo directory
:: %~2: default branch
:Git_Sync_Dn
setLocal enableDelayedExpansion
echo.
echo  -- Syncing: %~1
echo.
cd %~1
git fetch -Pp
git checkout %~1 > nul 2>&1
git reset --hard origin/%~1 > nul 2>&1
@REM git pull
@REM for /f "usebackq" %%I in (`git branch -vv ^| find /v "gone"`) do (
for /f "usebackq" %%I in (`git branch -vv ^| find /v "[origin/main]"`) do (
    git branch -D %%I > nul 2>&1
)
for /f "tokens=1,* delims=/" %%I in ('git branch -r ^| findstr /v %~2') do (
    set "BranchName=!BranchName!%%J:%%J "
)
git fetch origin %BranchName% > nul 2>&1
endLocal
exit /b 0

:: Push the local bare repo to remote repo
:: %~1: repo directory
:Git_Sync_Up
setLocal enableDelayedExpansion
echo.
echo  -- Pushing: %~1
echo.
cd %~1
git push --mirror
endLocal
exit /b 0
