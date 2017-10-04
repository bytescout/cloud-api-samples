# Cloud API asynchronous "Split PDF" job example.
# Allows to avoid timeout errors when processing huge or scanned PDF documents.

# (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

# The authentication key (API Key).
# Get your own by registering at https://secure.bytescout.com/users/sign_up
$API_KEY = "***********************************"

# Source PDF file to split
$SourceFileUrl = "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-split/sample.pdf"
# Comma-separated list of page numbers (or ranges) to process. Example: '1,3-5,7-'.
$Pages = "1-2,3-"
# (!) Make asynchronous job
$Async = $true


# Prepare URL for `Split PDF` API call
$query = "https://bytescout.io/v1/pdf/split?pages=$($Pages)&url=$($SourceFileUrl)&async=$($Async)"
$query = [System.Uri]::EscapeUriString($query)

try {
    # Execute request
    $jsonResponse = Invoke-RestMethod -Method Get -Headers @{ "x-api-key" = $API_KEY } -Uri $query

    if ($jsonResponse.error -eq $false) {
        # Asynchronous job ID
        $jobId = $jsonResponse.jobId
        # URL of generated JSON file available after the job completion; it will contain URLs of result PDF files.
        $resultJsonFileUrl = $jsonResponse.url

        # Check the job status in a loop. 
        do {
            $statusCheckUrl = "https://bytescout.io/v1/job/check?jobid=" + $jobId
            $jsonStatus = Invoke-RestMethod -Method Get -Uri $statusCheckUrl

            # Display timestamp and status (for demo purposes)
            Write-Host "$(Get-date): $($jsonStatus.Status)"

            if ($jsonStatus.Status -eq "Finished") {
                # Download JSON file with URLs of result PDF files
                $jsonPdfUrls = Invoke-RestMethod -Method Get -Uri $resultJsonFileUrl

                # Download generated PDF files
                $part = 1;
                foreach ($url in $jsonPdfUrls) {
                    $localFileName = ".\part$($part).pdf"

                    # Download PDF file
                    Invoke-WebRequest -Headers @{ "x-api-key" = $API_KEY } -OutFile $localFileName -Uri $url

                    Write-Host "Downloaded `"$($localFileName)`""
                    $part++
                }
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
