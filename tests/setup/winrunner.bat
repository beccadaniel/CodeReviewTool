@REM This is the installer tool for Dufuna Code Reviews

set project_working_directory="%~dp0..\.."
set test_folder="%project_working_directory:"=%\tests"
set home_directory="%userprofile%"

cd %home_directory%

For /F "usebackq" %%v IN (`curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE`) DO set chrome_driver_version=%%v

set path_to_driver="%home_directory:"=%\..\..\Program Files (x86)"
set path_to_chrome_driver="%homedrive%\bin"

For /F "usebackq" %%v IN (`node -v`) DO set node_version=%%v

For /F "usebackq" %%v IN (`mocha --version`) DO set mocha_version=%%v
For /F "usebackq" %%v IN (`systeminfo ^| find "x86" /c`) DO set pc_bit_size=%%v

set no_format='\033[00m'
set bold='\x1b[1m'
set underline='\033[4m'
set italic='\x1b[3m'

:: Node check & Installation
IF [%node_version%]==[] (
    IF %pc_bit_size% LSS 1 (
        curl -o node.msi https://nodejs.org/dist/v14.15.5/node-v14.15.5-x86.msi
    ) ELSE (
        curl -o node.msi https://nodejs.org/dist/v14.15.5/node-v14.15.5-x64.msi
    )
    msiexec.exe /i node.msi /qn /norestart
    @REM powershell -Command "Start-Process cmd -Verb RunAs"
) else (
    echo "node is available"
)

cd %test_folder%

:: selenium web-driver check & installation
FOR /F "usebackq" %%i IN (`npm ls --depth=0 ^| find "selenium-webdriver" /c`) DO set /A selenium_wc=%%i

cd %home_directory%

IF %selenium_wc% GTR 0 (
    echo "selenium-webdriver is available"
) ELSE (
    npm install --prefix %test_folder% selenium-webdriver
)

FOR /F "usebackq" %%i IN (`dir %path_to_chrome_driver% ^| find "chromedriver.exe" /c`) DO set /A chromedriver_wc=%%i

:: chromedriver check & installation
IF %chromedriver_wc% GTR 0 (
    echo "chromedriver is available"
) ELSE (
    curl -S -o chromedriver_win32.zip https://chromedriver.storage.googleapis.com/%chrome_driver_version%/chromedriver_win32.zip
    if not EXIST %path_to_chrome_driver% mkdir %path_to_chrome_driver:"=%

    @REM only works with Windows 10. TO DO: get a more inclusive method
    tar -zxvf chromedriver_win32.zip -C "%path_to_chrome_driver:"=%"
    del chromedriver_win32.zip
)

set PATH=%PATH%;%path_to_chrome_driver:"=%

:: mocha check & installation
IF [%mocha_version%] == [] (
    npm install --global mocha
    npm install --global mochawesome

    cd "%APPDATA%\npm\"
    copy /Y "%test_folder:"=%\setup\file.cmd" mocha.cmd

) ELSE (
    echo "mocha is available"
)
@doskey mocha="%APPDATA%\npm\mocha.cmd"

cd %home_directory%

:: Running Tests
set customReportFilename=logfile

echo %customReportFilename%

:: write out to console the location of the report file

"%APPDATA:"=%\npm\mocha.cmd" "%test_folder:"=%\example-test.js" --reporter mochawesome --reporter-options reportDir=%test_folder%,reportFilename=%customReportFilename%,quiet=true