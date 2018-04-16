'*****************************************************************************************'
'                                                                                         '
' Download offline evaluation version (DLL): https://bytescout.com/download/web-installer '
'                                                                                         '
' Signup Web API free trial: https://secure.bytescout.com/users/sign_up                   '
'                                                                                         '
' Copyright © 2017-2018 ByteScout Inc. All rights reserved.                               '
' http://www.bytescout.com                                                                '
'                                                                                         '
'*****************************************************************************************'


Imports System.IO
Imports System.Net
Imports Newtonsoft.Json.Linq

Module Module1

	' (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

	' The authentication key (API Key).
	' Get your own by registering at https://secure.bytescout.com/users/sign_up
	Const API_KEY As String = "***********************************"

	' Direct URL of source PDF file.
	Const SourceFileUrl As String = "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-to-text/sample.pdf"
	' Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
	const Pages as String = ""
	' PDF document password. Leave empty for unprotected documents.
	const Password As string = ""
	' Destination TXT file name
	const DestinationFile as string = ".\result.txt"

	Sub Main()

		' Create standard .NET web client instance
		Dim webClient As WebClient = New WebClient()

		' Set API Key
		webClient.Headers.Add("x-api-key", API_KEY)

		' Prepare URL for `PDF To TXT` API call
		Dim query As String = Uri.EscapeUriString(String.Format(
			"https://bytescout.io/v1/pdf/convert/to/text?name={0}&password={1}&pages={2}&url={3}", 
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

				' Get URL of generated TXT file
				Dim resultFileUrl As String = json("url").ToString()

				' Download TXT file
				webClient.DownloadFile(resultFileUrl, DestinationFile)

				Console.WriteLine("Generated TXT file saved as ""{0}"" file.", DestinationFile)

			Else
				Console.WriteLine(json("message").ToString())
			End If

		Catch ex As WebException
			Console.WriteLine(ex.ToString())
		End Try

		webClient.Dispose()


		Console.WriteLine()
		Console.WriteLine("Press any key...")
		Console.ReadKey()

	End Sub

End Module
