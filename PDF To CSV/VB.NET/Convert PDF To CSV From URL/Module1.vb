﻿Imports System.IO
Imports System.Net
Imports Newtonsoft.Json.Linq

Module Module1

	' (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

	' The authentication key (API Key).
	' Get your own by registering at https://secure.bytescout.com/users/sign_up
	Const API_KEY As String = "***********************************"

	' Direct URL of source PDF file.
	Const SourceFileUrl As String = "https://github.com/bytescout/ByteScout-SDK-SourceCode/raw/master/PDF%20Extractor%20SDK/Invoice.pdf"
	' Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
	const Pages as String = ""
	' PDF document password. Leave empty for unprotected documents.
	const Password As string = ""
	' Destination CSV file name
	const DestinationFile as string = ".\result.csv"

	Sub Main()

		' Create standard .NET web client instance
		Dim webClient As WebClient = New WebClient()

		' Set API Key
		webClient.Headers.Add("x-api-key", API_KEY)

		' Prepare URL for `PDF To CSV` API call
		Dim query As String = Uri.EscapeUriString(String.Format(
			"https://bytescout.io/v1/pdf/convert/to/csv?name={0}&password={1}&pages={2}&url={3}", 
			Path.GetFileName(DestinationFile),
			Password,
			Pages,
			SourceFileUrl))

		Try
			' Execute request
			Dim response As String = webClient.DownloadString(query)

			' Parse JSON response
			Dim json As JObject = JObject.Parse(response)

			If json("error").ToObject(Of Boolean) = False Then

				' Get URL of generated CSV file
				Dim resultFileUrl As String = json("url").ToString()

				' Download CSV file
				webClient.DownloadFile(resultFileUrl, DestinationFile)

				Console.WriteLine("Generated CSV file saved as ""{0}"" file.", DestinationFile)

			Else
				Console.WriteLine(json("message").ToString())
			End If

		Catch ex As WebException
			Console.WriteLine(ex.ToString())
		End Try


		Console.WriteLine()
		Console.WriteLine("Press any key...")
		Console.ReadKey()

	End Sub

End Module