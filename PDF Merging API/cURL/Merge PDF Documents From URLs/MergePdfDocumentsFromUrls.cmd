:: (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

@echo off

:: Path of the cURL executable
set CURL="curl.exe"

:: The authentication key (API Key).
:: Get your own by registering at https://secure.bytescout.com/users/sign_up
set API_KEY=***********************************

:: Direct URLs of PDF documents to merge
set SOURCE_FILE_URL1=https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-merge/sample1.pdf
set SOURCE_FILE_URL2=https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-merge/sample2.pdf
:: Result PDF file name
set RESULT_FILE_NAME=result.pdf


:: Prepare URL for `Merge PDF` API call
set QUERY="https://bytescout.io/v1/pdf/merge?name=%RESULT_FILE_NAME%&url=%SOURCE_FILE_URL1%,%SOURCE_FILE_URL2%"

:: Perform request and save response to a file
%CURL% -# -X GET -H "x-api-key: %API_KEY%" %QUERY% >response.json

:: Display the response
type response.json

:: Use any convenient way to parse JSON response and get URL of generated file(s)


echo.
pause