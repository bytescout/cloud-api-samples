# (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

# The authentication key (API Key).
# Get your own by registering at https://secure.bytescout.com/users/sign_up
$API_KEY = "***********************************"

# Source PDF file to split
$SourceFile = ".\sample.pdf"
# Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
$Pages = ""
# PDF document password. Leave empty for unprotected documents.
$Password = ""


# 1. RETRIEVE THE PRESIGNED URL TO UPLOAD THE FILE.
# * If you already have a direct file URL, skip to the step 3.

# Prepare URL for `Get Presigned URL` API call
$query = "https://bytescout.io/v1/file/upload/get-presigned-url?contenttype=application/octet-stream&name=" + `
    [System.IO.Path]::GetFileName($SourceFile)
$query = [System.Uri]::EscapeUriString($query)

try {
    # Execute request
    $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query
    
    if ($jsonResponse.error -eq $false) {
        # Get URL to use for the file upload
        $uploadUrl = $jsonResponse.presignedUrl
        # Get URL of uploaded file to use with later API calls
        $uploadedFileUrl = $jsonResponse.url

        # 2. UPLOAD THE FILE TO CLOUD.

        $r = Invoke-WebRequest -Method Put -Headers @{ "x-api-key" = $API_KEY; "content-type" = "application/octet-stream" } -InFile $SourceFile -Uri $uploadUrl
        
        if ($r.StatusCode -eq 200) {
            
            # 3. CONVERT UPLOADED PDF FILE TO JPEG

            # Prepare URL for `PDF To JPEG` API call
            $query = "https://bytescout.io/v1/pdf/convert/to/jpg?password={0}&pages={1}&url={2}" -f `
                $Password, $Pages, $uploadedFileUrl
            $query = [System.Uri]::EscapeUriString($query)

            # Execute request
            $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query

            if ($jsonResponse.error -eq $false) {
                # Download generated JPEG files
                $part = 1;
                foreach ($url in $jsonResponse.urls) {
                    $localFileName = ".\page$($part).jpg"

                    Invoke-WebRequest -Headers @{ "x-api-key" = $API_KEY } -OutFile $localFileName -Uri $url

                    Write-Host "Downloaded `"$($localFileName)`""
                    $part++
                }
            }
            else {
                # Display service reported error
                Write-Host $jsonResponse.message
            }
        }
        else {
            # Display request error status
            Write-Host $r.StatusCode + " " + $r.StatusDescription
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
