# (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

# The authentication key (API Key).
# Get your own by registering at https://secure.bytescout.com/users/sign_up
$API_KEY = "***********************************"

# Direct URL of source file to search barcodes in.
$SourceFileURL = "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/barcode-reader/sample.pdf"
# Comma-separated list of barcode types to search. 
# See valid barcode types in the documentation https://secure.bytescout.com/cloudapi.html#api-Default-barcodeReadFromUrlGet
$BarcodeTypes = "Code128,Code39,Interleaved2of5,EAN13"
# Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
$Pages = ""


# Prepare URL for `Barcode Reader` API call
$query = "https://bytescout.io/v1/barcode/read/from/url?types=$($BarcodeTypes)&pages=$($Pages)&url=$($SourceFileURL)"
$query = [System.Uri]::EscapeUriString($query)

try {
    # Execute request
    $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query

    if ($jsonResponse.error -eq $false) {
        # Display found barcodes in console
        foreach ($barcode in $jsonResponse.barcodes)
        {
            Write-Host "Found barcode:"
            Write-Host "  Type: " $barcode.TypeName
            Write-Host "  Value: " $barcode."Value"
            Write-Host "  Document Page Index: " $barcode."Page"
            Write-Host "  Rectangle: " $barcode."Rect"
            Write-Host "  Confidence: " $barcode."Confidence"
            Write-Host ""
        }
    }
    else {
        # Display service reported error
        Write-Host $jsonResponse.message
    }
}
catch {
    # Display request error
    Write-Host $_.Exception
}
