# (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

# The authentication key (API Key).
# Get your own by registering at https://secure.bytescout.com/users/sign_up
$API_KEY = "***********************************"

# Source image files
$ImageFiles = ".\image1.png", ".\image2.jpg"
# Destination PDF file name
$DestinationFile = ".\result.pdf"

$uploadedFiles = @()

try {
    foreach ($imageFile in $ImageFiles ) {
        # 1a. RETRIEVE THE PRESIGNED URL TO UPLOAD THE FILE.
        
        # Prepare URL for `Get Presigned URL` API call
        $query = "https://bytescout.io/v1/file/upload/get-presigned-url?contenttype=binary/octet-stream&name=" + `
            [IO.Path]::GetFileName($imageFile)
        $query = [System.Uri]::EscapeUriString($query)

        # Execute request
        $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query
    
        if ($jsonResponse.error -eq $false) {
            # Get URL to use for the file upload 
            $uploadUrl = $jsonResponse.presignedUrl
            # Get URL of uploaded file to use with later API calls
            $uploadedFileUrl = $jsonResponse.url
    
            # 1b. UPLOAD THE FILE TO CLOUD.
    
            $r = Invoke-WebRequest -Method Put -Headers @{ "x-api-key" = $API_KEY; "content-type" = "binary/octet-stream" } -InFile $imageFile -Uri $uploadUrl
            
            if ($r.StatusCode -eq 200) {
                # Keep uploaded file URL
                $uploadedFiles += $uploadedFileUrl
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

    if ($uploadedFiles.length -gt 0) {
        # 2. CREATE PDF DOCUMENT FROM UPLOADED IMAGE FILES
    
        # Prepare URL for `DOC To PDF` API call
        $query = "https://bytescout.io/v1/pdf/convert/from/image?name=$(Split-Path $DestinationFile -Leaf)&url=$($uploadedFiles -join ",")"
        $query = [System.Uri]::EscapeUriString($query)
        
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
}
catch {
    # Display request error
    Write-Host $_.Exception
}
