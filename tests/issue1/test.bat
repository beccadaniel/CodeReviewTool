@REM This is Dufuna CodeCamp's Issue 1 test

@ECHO off

SETLOCAL

SET /P first_name="Enter First Name: "
SET /P last_name="Enter Last Name: "

SET submission_directory="%~dp0../../submissions"
SET path_to_log="%submission_directory:"=%/../tests/logfile.json"

@REM get appropriate folder name

CALL :TrimFirstName
CALL :TrimLastName
CALL :LoCase first_name

SET first_letter=%last_name:~0,1%
SET remainder=%last_name:~1%

CALL :UpCase first_letter
CALL :LoCase remainder

SET last_name=%first_letter%%remainder%
SET folder_name=%first_name%%last_name%

SET path_to_folder="%submission_directory:"=%/%folder_name:"=%"
SET path_to_aboutMe_folder="%path_to_folder:"=%/aboutMe"
SET path_to_file="%path_to_aboutMe_folder:"=%/aboutMe"
SET /A no_of_passes=0
SET /A no_of_failures=0


@REM check folder existence

FOR /F "usebackq" %%i IN (`dir %submission_directory% ^| find "%folder_name:"=%" /c`) DO SET /A folder_count=%%i

IF %folder_count% EQU 1 (
    call :FolderExistence "1"
) ELSE (
    call :FolderExistence "0"
    ECHO . && ECHO Suggestions && ECHO 1. Your folder should be named in camel case with your First and Last name. && ECHO 2. Ensure your folder is located in the submissions directory.
)

@REM check aboutMe folder existence

FOR /F "usebackq" %%i IN (`dir %path_to_folder% ^| find "aboutMe" /c`) DO SET /A aboutMe_folder_count=%%i

IF %aboutMe_folder_count% EQU 1 (
    call :AboutMeFolderExistence "1"
) ELSE (
    call :AboutMeFolderExistence "0"
    ECHO . && ECHO Suggestions && ECHO 1. Your folder should be named 'aboutMe' and located in the folder with your First and Last name.
)

@REM check file existence

FOR /F "usebackq" %%i IN (`dir %path_to_aboutMe_folder% ^| find "aboutMe" /c`) DO SET /A aboutMe_file_count=%%i
IF %aboutMe_file_count% EQU 2 (
    call :FileExistence "1"
) ELSE (
    call :FileExistence "0"
    ECHO . && ECHO Suggestions && ECHO 1. You should create a text file named 'aboutMe'. && ECHO 2. Ensure your file is located in the 'aboutMe' folder you have created. && ECHO 3. Ensure your text file contains text.
)

IF %folder_exists% GTR 0 (
    call :NoOfPasses
) ELSE (
    call :NoOfFailures
)

IF %aboutMe_folder_exists% GTR 0 (
    call :NoOfPasses
) ELSE (
    call :NoOfFailures
)

IF %file_exists% GTR 0 (
    call :NoOfPasses
) ELSE (
    call :NoOfFailures
)
SET /A total_tests=%no_of_passes%+%no_of_failures%

@REM write JSON response
ECHO { > %path_to_log%
ECHO   "stats": { >> %path_to_log%
ECHO     "tests": %total_tests%, >> %path_to_log%
ECHO     "passes": %no_of_passes%, >> %path_to_log%
ECHO     "failures": %no_of_failures% >> %path_to_log%
ECHO   } >> %path_to_log%
ECHO } >> %path_to_log%

@REM write output to cmd
ECHO . && ECHO Total number of tests: %total_tests% && ECHO Passed tests: %no_of_passes% && ECHO Failed tests: %no_of_failures%

:NoOfPasses
    SET /A no_of_passes+=1
EXIT /B

:NoOfFailures
    SET /A no_of_failures+=1
EXIT /B

:FolderExistence
    SET "folder_exists=%~1"
EXIT /B

:AboutMeFolderExistence
    SET "aboutMe_folder_exists=%~1"
EXIT /B

:FileExistence
    SET "file_exists=%~1"
EXIT /B

:TrimFirstName
:: trim left whitespace
FOR /F "tokens=* delims= " %%a in ("%first_name%") DO CALL SET first_name=%%a
:: trim right whitespace
FOR /F "tokens=1 delims= " %%a in ("%first_name%") DO CALL SET first_name=%%a
EXIT /B

:TrimLastName
:: trim left whitespace
FOR /F "tokens=* delims= " %%a in ("%last_name%") DO CALL SET last_name=%%a
:: trim right whitespace
FOR /F "tokens=1 delims= " %%a in ("%last_name%") DO CALL SET last_name=%%a
EXIT /B

:LoCase
:: Subroutine to convert a variable VALUE to all lower case.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
EXIT /B

:UpCase
:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
EXIT /B

ENDLOCAL