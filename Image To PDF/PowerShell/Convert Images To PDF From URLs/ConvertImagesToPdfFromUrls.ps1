# (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

# The authentication key (API Key).
# Get your own by registering at https://secure.bytescout.com/users/sign_up
$API_KEY = "***********************************"

# Direct URLs of image files to convert to PDF document
$SourceFiles = @(
    "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/image-to-pdf/image1.png",
    "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/image-to-pdf/image2.jpg"
)
# Destination PDF file name
$DestinationFile = ".\result.pdf"


# Prepare URL for `Image To PDF` API call
$query = "https://bytescout.io/v1/pdf/convert/from/image?name=$(Split-Path $DestinationFile -Leaf)&url=$($SourceFiles -join ",")"
$query = [System.Uri]::EscapeUriString($query)

try {
    # Execute request
    $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query

    if ($jsonResponse.error -eq $false) {
        # Get URL of generated PDF file
        $resultFileUrl = $jsonResponse.url;
        
        # Download PDF file
        Invoke-WebRequest -Headers @{ "x-api-key" = $API_KEY } -OutFile $DestinationFile -Uri $resultFileUrl

        Write-Host "Generated PDF file saved as `"$($DestinationFile)`" file."
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
