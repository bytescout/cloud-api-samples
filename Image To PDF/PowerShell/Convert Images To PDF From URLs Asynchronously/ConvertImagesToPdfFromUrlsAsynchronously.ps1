# Cloud API asynchronous "Image To PDF" job example.
# Allows to avoid timeout errors when processing huge or scanned PDF documents.

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
# (!) Make asynchronous job
$Async = $true

# Prepare URL for `Image To PDF` API call
$query = "https://bytescout.io/v1/pdf/convert/from/image?name=$(Split-Path $DestinationFile -Leaf)&url=$($SourceFiles -join ",")&async=$($Async)"
$query = [System.Uri]::EscapeUriString($query)

try {
    # Execute request
    $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query

    if ($jsonResponse.error -eq $false) {
        # Asynchronous job ID
        $jobId = $jsonResponse.jobId
        # URL of generated PDF file that will available after the job completion
        $resultFileUrl = $jsonResponse.url

        # Check the job status in a loop. 
        do {
            $statusCheckUrl = "https://bytescout.io/v1/job/check?jobid=" + $jobId
            $jsonStatus = Invoke-RestMethod -Method Get -Uri $statusCheckUrl

            # Display timestamp and status (for demo purposes)
            Write-Host "$(Get-date): $($jsonStatus.Status)"

            if ($jsonStatus.Status -eq "Finished") {
                # Download PDF file
                Invoke-WebRequest -Headers @{ "x-api-key" = $API_KEY } -OutFile $DestinationFile -Uri $resultFileUrl
                Write-Host "Generated PDF file saved as `"$($DestinationFile)`" file."
                break
            }
            elseif ($jsonStatus.Status -eq "InProgress") {
                # Pause for a few seconds
                Start-Sleep -Seconds 3
            }
            else {
                Write-Host $jsonStatus.Status
                break
            }
        }
        while ($true)
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
