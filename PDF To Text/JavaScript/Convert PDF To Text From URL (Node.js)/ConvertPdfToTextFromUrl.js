//*******************************************************************************************//
//                                                                                           //
// Download Free Evaluation Version From: https://bytescout.com/download/web-installer       //
//                                                                                           //
// Also available as Web API! Free Trial Sign Up: https://secure.bytescout.com/users/sign_up //
//                                                                                           //
// Copyright © 2017-2018 ByteScout Inc. All rights reserved.                                 //
// http://www.bytescout.com                                                                  //
//                                                                                           //
//*******************************************************************************************//


// (!) If you are getting "(403) Forbidden" error please ensure you have set the correct API_KEY

var https = require("https");
var path = require("path");
var fs = require("fs");


// The authentication key (API Key).
// Get your own by registering at https://secure.bytescout.com/users/sign_up
const API_KEY = "***********************************";


// Direct URL of source PDF file.
const SourceFileUrl = "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-to-text/sample.pdf";
// Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
const Pages = "";
// PDF document password. Leave empty for unprotected documents.
const Password = "";
// Destination TXT file name
const DestinationFile = "./result.txt";


// Prepare request to `PDF To Text` API endpoint
var queryPath = `/v1/pdf/convert/to/text?name=${path.basename(DestinationFile)}&password=${Password}&pages=${Pages}&url=${SourceFileUrl}`;
var reqOptions = {
    host: "bytescout.io",
    path: encodeURI(queryPath),
    headers: {
        "x-api-key": API_KEY
    }
};
// Send request
https.get(reqOptions, (response) => {
    response.on("data", (d) => {
        // Parse JSON response
        var data = JSON.parse(d);        
        if (data.error == false) {
            // Download TXT file
            var file = fs.createWriteStream(DestinationFile);
            https.get(data.url, (response2) => {
                response2.pipe(file)
                .on("close", () => {
                    console.log(`Generated TXT file saved as "${DestinationFile}" file.`);
                });
            });
        }
        else {
            // Service reported error
            console.log(data.message);
        }
    });
}).on("error", (e) => {
    // Request error
    console.log(e);
});
