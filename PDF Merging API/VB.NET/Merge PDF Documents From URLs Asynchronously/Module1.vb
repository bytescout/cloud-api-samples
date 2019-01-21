'*******************************************************************************************'
'                                                                                           '
' Download Free Evaluation Version From:     https://bytescout.com/download/web-installer   '
'                                                                                           '
' Also available as Web API! Free Trial Sign Up: https://secure.bytescout.com/users/sign_up '
'                                                                                           '
' Copyright © 2017-2018 ByteScout Inc. All rights reserved.                                 '
' http://www.bytescout.com                                                                  '
'                                                                                           '
'*******************************************************************************************'


Imports System.IO
Imports System.Net
Imports System.Threading
Imports Newtonsoft.Json.Linq


' Cloud API asynchronous "Merge PDF" job example.
' Allows to avoid timeout errors when processing huge or scanned PDF documents.

Module Module1

	' (!) If you are getting '(403) Forbidden' error please ensure you have set the correct API_KEY

	' The authentication key (API Key).
	' Get your own by registering at https://secure.bytescout.com/users/sign_up
	Const API_KEY As String = "***********************************"

	' Direct URLs of PDF files to merge
	Dim SourceFiles As String() = {
		"https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-merge/sample1.pdf",
		"https://s3-us-west-2.amazonaws.com/bytescout-com/files/demo-files/cloud-api/pdf-merge/sample2.pdf"}
	' Destination PDF file name
	Const DestinationFile As String = ".\result.pdf"
	' (!) Make asynchronous job
	Const Async As Boolean = True


	Sub Main()

		' Create standard .NET web client instance
		Dim webClient As WebClient = New WebClient()

		' Set API Key
		webClient.Headers.Add("x-api-key", API_KEY)

		' Prepare URL for `Merge PDF` API call
		Dim query As String = Uri.EscapeUriString(String.Format(
			"https://bytescout.io/v1/pdf/merge?name={0}&url={1}&async={2}",
			Path.GetFileName(DestinationFile),
			String.Join(",", SourceFiles),
			Async))

		Try
			' Execute request
			Dim response As String = webClient.DownloadString(query)

			' Parse JSON response
			Dim json As JObject = JObject.Parse(response)

			If json("error").ToObject(Of Boolean) = False Then

				' Asynchronous job ID
				Dim jobId As String = json("jobId").ToString()
				' URL of generated PDF file that will available after the job completion
				Dim resultFileUrl As String = json("url").ToString()

				' Check the job status in a loop. 
				' If you don't want to pause the main thread you can rework the code 
				' to use a separate thread for the status checking and completion.
				Do
					Dim status As String = CheckJobStatus(jobId) ' Possible statuses: "InProgress", "Failed", "Aborted", "Finished".

					' Display timestamp and status (for demo purposes)
					Console.WriteLine(DateTime.Now.ToLongTimeString() + ": " + status)

					If status = "Finished" Then

						' Download PDF file
						webClient.DownloadFile(resultFileUrl, DestinationFile)

						Console.WriteLine("Generated PDF file saved as ""{0}"" file.", DestinationFile)
						Exit Do

					ElseIf status = "InProgress" Then

						' Pause for a few seconds
						Thread.Sleep(3000)

					Else

						Console.WriteLine(status)
						Exit Do

					End If

				Loop

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

	Function CheckJobStatus(jobId As String) As String

		Using webClient As WebClient = New WebClient()

			Dim url As String = "https://bytescout.io/v1/job/check?jobid=" + jobId

			Dim response As String = webClient.DownloadString(url)
			Dim json As JObject = JObject.Parse(response)

			return Convert.ToString(json("Status"))

		End Using

	End Function

End Module
