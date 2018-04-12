<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="~/Globals/Globals.aspx" -->
<%
If Not (UserIsSuperAdmin() OR UserIsSiteAdmin() ) Then
    Response.Redirect(GetUrl("Admin-Home"))
End If

Response.ContentType = "application/vnd.ms-excel; charset=UTF-8"
Response.AppendHeader( "content-disposition", "attachment; filename=WeeklySurveyData.xls")
Server.ScriptTimeout = 60*10

Dim siteId As Integer = -1
ACHESS.Request.GetInteger("siteId", siteId, siteId)

' Super Admin can see any data
If Not UserIsSuperAdmin Then
    siteId = UserIntegerValue("SiteID")
End If

' Create a lookup table for each field
Dim questions As New Dictionary(Of string, string)
Dim dr1 As SqlDataReader = ExecuteReader("SELECT DISTINCT q.SurveyType, q.FieldName, q.Question FROM WeeklySurveyQuestions q WHERE q.FieldName <> 'MissedDoseAntiRetroViralMed' ORDER BY q.SurveyType, q.FieldName")
While dr1.Read()
	Dim key As String = dr1("SurveyType").ToString() & ": " & dr1("FieldName").ToString()
	Dim val As String = dr1("Question").ToString()
	If Not questions.ContainsKey(key) Then
		questions.Add(key, val)
	End If
End While
dr1.Close()

' Create a lookup table for each survey
Dim surveys As New Dictionary(Of string, Dictionary(Of string, string))
Dim dr As SqlDataReader = ExecuteReader("SELECT m.StudyID, m.CodeName, m.UserID, (SELECT CASE WHEN COUNT(*) > 0 THEN 'True' ELSE 'False' END FROM UserPermissions up WHERE up.userId = m.UserID AND up.permissionGuid = 'hiv-user-avenir' AND up.isEnabled = 'True' AND up.deleteDate IS NULL) AS AvenirParticipant, mm.MedicationName, s.surveyId, s.status, s.finishDate, q.PageNo, q.QuestionId, q.SurveyType, q.FieldName, q.Question, a.Answer, a.CreateDate FROM UserWeeklySurveys s LEFT JOIN MobileUsers m ON m.UserId = s.UserId LEFT JOIN UserMedicationInfo um ON um.UserId = m.UserId AND um.KeyName = 'MedicationId' LEFT JOIN MedicationList mm ON mm.MedicationId = um.Value LEFT JOIN UserWeeklySurveyAnswers a ON s.surveyId = a.surveyId LEFT JOIN WeeklySurveyQuestions q ON q.GUID = a.GUID WHERE (m.SiteID = @SiteID1 OR @SiteID2 = '-1') AND s.DeleteDate IS NULL ORDER BY m.CodeName, s.surveyId DESC, q.PageNo ASC", siteId, siteId)
While dr.Read()
	Dim surveyId As String = dr("SurveyId").ToString()
	Dim surveyFields As New Dictionary(Of string, string)
	If Not surveys.ContainsKey(surveyId) Then
		surveyFields.Add("Survey ID", "")
		surveyFields.Add("UserName", "")
		surveyFields.Add("User ID", "")
		surveyFields.Add("Project", "")
		surveyFields.Add("Study ID", "")
		surveyFields.Add("User Medication", "")
		surveyFields.Add("Survey Status", "")
		surveyFields.Add("Survey Finish Date", "")
		
		surveys.Add(surveyId, surveyFields)
	End If
	
	surveyFields = surveys.Item(surveyId)
	surveyFields.Item("Survey ID") = dr("SurveyID").ToString()
	surveyFields.Item("Username") = dr("CodeName").ToString()
	surveyFields.Item("User ID") = dr("UserID").ToString()
	
	If Convert.ToBoolean(dr("AvenirParticipant").ToString()) Then
		surveyFields.Item("Project") = "Avenir"
	Else
		surveyFields.Item("Project") = "Bundling"
	End If
	
	surveyFields.Item("Study ID") = dr("StudyID").ToString()
	surveyFields.Item("User Medication") = dr("MedicationName").ToString()
	surveyFields.Item("Survey Status") = dr("status").ToString()
	surveyFields.Item("Survey Finish Date") = dr("finishDate").ToString()
	
	Dim key As String = dr("SurveyType").ToString() & ": " & dr("FieldName").ToString() 
	If Not surveyFields.ContainsKey(key) Then
		surveyFields.Add(key, dr("Answer").ToString())
	End If
	
	surveys.Item(surveyId) = surveyFields
End While
dr.Close()

' Look through the data and create an excel file to output
Dim rows As New List(Of List(Of String))
Dim fields As New List(Of String)
fields.Add(GetStr("Admin-WeeklySurveys-Table-SurveyID"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-Username"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-UserID"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-Project"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-StudyID"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-UserMedication"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-SurveyStatus"))
fields.Add(GetStr("Admin-WeeklySurveys-Table-SurveyFinishDate"))
For Each question in questions.Keys
	fields.Add(question)
Next

' Add each survey to the rows
For Each surveyId In surveys.Keys
	Dim surveyFields As Dictionary(Of string, string) = surveys.Item(surveyId)
	Dim cols As New List(Of String)
	
	For Each field in fields
		If surveyFields.ContainsKey(field) Then
			cols.Add(surveyFields.Item(field).ToString())
		Else
			cols.Add("")
		End If
	Next
	
	rows.Add(cols)
Next

' Store the data in a stringbuilder
Dim sb As New StringBuilder()
sb.Append("<table border=""1"">")

' Output the excel file of data
sb.Append("<tr>")
For Each field in fields
	sb.Append("<th style=""background-color:#CCC; text-align:left;"">" & field & "</th>")
Next
sb.Append("</tr>")

For Each row in rows
	sb.Append("<tr>")
	For Each col in row
		sb.Append("<td>" & col & "</td>")
	Next
	sb.Append("</tr>")
Next

' Output spacing between the body and the legend
sb.Append("<tr></tr>")
sb.Append("<tr></tr>")

' Output the question legend
sb.Append("<tr>")
sb.Append("<th style=""background-color:#CCC; text-align:left;"">Field Name</th>")
sb.Append("<th colspan=""" & fields.Count - 1 & """ style=""background-color:#CCC; text-align:left;"">Question</th>")
sb.Append("</tr>")
For Each question in questions.Keys
	sb.Append("<tr>")
	sb.Append("<td>" & question & "</td>")
	sb.Append("<td colspan=""" & fields.Count - 1 & """>" & questions.Item(question) & "</td>")
	sb.Append("</tr>")
Next

sb.Append("</table>")

' This is required for saving a visit to this page
SetApplicationPage("", "Admin", "Export Weekly Survey Report", "SiteID:" & siteId.ToString())

Response.Write(sb.ToString())
%>