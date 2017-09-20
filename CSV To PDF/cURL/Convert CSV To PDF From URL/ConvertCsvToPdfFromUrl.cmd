:: (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

@echo off

:: Path of the cURL executable
set CURL="curl.exe"

:: The authentication key (API Key).
:: Get your own by registering at https://secure.bytescout.com/users/sign_up
set API_KEY=***********************************

:: Direct URL of source CSV file.
set SOURCE_FILE_URL=https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/csv-to-pdf/sample.csv
:: Result PDF file name
set RESULT_FILE_NAME=result.pdf


:: Prepare URL for `CSV To PDF` API call
set QUERY="https://bytescout.io/v1/pdf/convert/from/csv?name=%RESULT_FILE_NAME%&pages=%PAGES%&url=%SOURCE_FILE_URL%"

:: Perform request and save response to a file
%CURL% -# -X GET -H "x-api-key: %API_KEY%" %QUERY% >response.json

:: Display the response
type response.json

:: Use any convenient way to parse JSON response and get URL of generated file(s)


echo.
pause