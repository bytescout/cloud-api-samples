﻿using System;
using System.IO;
using System.Net;
using Newtonsoft.Json.Linq;

namespace ByteScoutWebApiExample
{
	class Program
	{
		// (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY
		
		// The authentication key (API Key).
		// Get your own by registering at https://secure.bytescout.com/users/sign_up
		const String API_KEY = "***********************************";

		static void Main(string[] args)
		{
			// HTML template
			string template = File.ReadAllText(@".\invoice_template.html");
			// Data to fill the template
			string templateData = File.ReadAllText(@".\invoice_data.json");
			// Destination PDF file name
			string destinationFile = @".\result.pdf";

			// Create standard .NET web client instance
			WebClient webClient = new WebClient();

			// Set API Key
			webClient.Headers.Add("x-api-key", API_KEY);

            try
            {
                // Prepare URL for HTML to PDF API call
				string request = Uri.EscapeUriString(string.Format(
					"https://bytescout.io/v1/pdf/convert/from/html?name={0}", 
					Path.GetFileName(destinationFile)));

                // Prepare request body in JSON format
                JObject jsonObject = new JObject(
                    new JProperty("html", template),
                    new JProperty("templateData", templateData));

                webClient.Headers.Add("Content-Type", "application/json");

                // Execute request
				string response = webClient.UploadString(request, jsonObject.ToString());

	            // Parse JSON response
	            JObject json = JObject.Parse(response);

	            if (json["error"].ToObject<bool>() == false)
	            {
		            // Get URL of generated PDF file
		            string resultFileUrl = json["url"].ToString();

		            webClient.Headers.Remove("Content-Type"); // remove the header required for only the previous request

		            // Download the PDF file
					webClient.DownloadFile(resultFileUrl, destinationFile);

					Console.WriteLine("Generated PDF document saved as \"{0}\" file.", destinationFile);
	            }
	            else
	            {
		            Console.WriteLine(json["message"].ToString());
	            }
            }
            catch (WebException e)
            {
	            Console.WriteLine(e.ToString());
            }


            Console.WriteLine();
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
		}
	}
}
