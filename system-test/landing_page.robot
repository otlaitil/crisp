*** Settings ***
Documentation     A test suite to test opening the landing page.
...
...               This test has a workflow that is created using keywords in
...               the imported resource file.
Resource          resource.robot

*** Test Cases ***
Landing Page
    Open Browser To Landing Page
    Landing Page Should Be Open
    [Teardown]    Close Browser
