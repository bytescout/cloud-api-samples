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
		
		// Direct URLs of image files to convert to PDF document
		static string[] SourceFiles = {
			"https://github.com/bytescout/ByteScout-SDK-SourceCode/tree/master/Cloud%20API/Image%20To%20PDF/C#/Convert%20Images%20To%20PDF%20From%20Uploaded%20Files/image1.png",
			"https://github.com/bytescout/ByteScout-SDK-SourceCode/tree/master/Cloud%20API/Image%20To%20PDF/C#/Convert%20Images%20To%20PDF%20From%20Uploaded%20Files/image2.jpg" };
		// Destination PDF file name
		const string DestinationFile = @".\result.pdf";

		static void Main(string[] args)
		{
			// Create standard .NET web client instance
			WebClient webClient = new WebClient();

			// Set API Key
			webClient.Headers.Add("x-api-key", API_KEY);

			// Prepare URL for `Image To PDF` API call
			string query = Uri.EscapeUriString(string.Format(
				"https://bytescout.io/v1/pdf/convert/from/image?name={0}&url={1}",
				Path.GetFileName(DestinationFile),
				string.Join(",", SourceFiles)));

			try
			{
				// Execute request
				string response = webClient.DownloadString(query);

				// Parse JSON response
				JObject json = JObject.Parse(response);

				if (json["error"].ToObject<bool>() == false)
				{
					// Get URL of generated PDF file
					string resultFileUrl = json["url"].ToString();

					// Download PDF file
					webClient.DownloadFile(resultFileUrl, DestinationFile);

					Console.WriteLine("Generated PDF file saved as \"{0}\" file.", DestinationFile);
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
			Console.WriteLine("Press any key...");
			Console.ReadKey();
		}
	}
}
