'****************************************************************************'
'                                                                            '
' Download evaluation version: https://bytescout.com/download/web-installer  '
'                                                                            '
' Signup Cloud API free trial: https://secure.bytescout.com/users/sign_up    '
'                                                                            '
' Copyright © 2017 ByteScout Inc. All rights reserved.                       '
' http://www.bytescout.com                                                   '
'                                                                            '
'****************************************************************************'


Imports System.IO
Imports System.Net
Imports Newtonsoft.Json.Linq

Module Module1

	' (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

	' The authentication key (API Key).
	' Get your own by registering at https://secure.bytescout.com/users/sign_up
	Const API_KEY As String = "***********************************"

	' Source PDF file
	Const SourceFileUrl As String = "https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-to-image/sample.pdf"
	' Comma-separated list of page indices (or ranges) to process. Leave empty for all pages. Example: '0,2-5,7-'.
	const Pages as String = ""
	' PDF document password. Leave empty for unprotected documents.
	const Password as String = ""
	
	Sub Main()

		' Create standard .NET web client instance
		Dim webClient As WebClient = New WebClient()

		' Set API Key
		webClient.Headers.Add("x-api-key", API_KEY)

		' Prepare URL for `PDF To PNG` API call
		Dim query As String = Uri.EscapeUriString(String.Format(
			"https://bytescout.io/v1/pdf/convert/to/png?password={0}&pages={1}&url={2}",
			Password,
			Pages,
			SourceFileUrl))

		Try
			' Execute request
			Dim response As String = webClient.DownloadString(query)

			' Parse JSON response
			Dim json As JObject = JObject.Parse(response)

			If json("error").ToObject(Of Boolean) = False Then

				' Download generated PNG files
				Dim page As Integer = 1
				For Each token As JToken In json("urls")
					
					Dim resultFileUrl As string = token.ToString()
					Dim localFileName As String = String.Format(".\page{0}.png", page)

					webClient.DownloadFile(resultFileUrl, localFileName)

					Console.WriteLine("Downloaded ""{0}"".", localFileName)
					page = page + 1

				Next

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
