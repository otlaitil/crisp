*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported SeleniumLibrary.
Library           SeleniumLibrary

*** Variables ***
${SELENIUM}          http://hub:4444/wd/hub
${APPLICATION}       http://web:4000
${BROWSER}           Firefox
${DELAY}             0
${VALID USER}        demo
${VALID PASSWORD}    mode
${BASE URL}          ${APPLICATION}/


*** Keywords ***
Open Browser To Landing Page
    Open Browser    ${BASE URL}    browser=${BROWSER}    remote_url=${SELENIUM}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}

Landing Page Should Be Open
    Location Should Be    ${BASE URL}
    Title Should Be    Crisp · Phoenix Framework
