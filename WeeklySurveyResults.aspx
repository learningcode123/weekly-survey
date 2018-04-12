<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="~/Globals/Globals.aspx" -->
<%
PageDetails.Add("Title", "Survey")
PageDetails.Add("Header", "Weekly Survey")
PageDetails.Add("IncludeJS-shortcodes", True)

' Since we come to this page from a lot of potential redirects, close any open Weekly Survey Notifications on the user's phone
'SendNotificationToAndroidDevice(UserData.UserId, "CLEAR_WEEKLY_SURVEY_NOTIFICATION", New Dictionary(Of String, Object))

Dim sSurveyID As String = PageHelper.DecodeStringToInteger(Request("SurveyID"), 0)
Dim nSurveyID As Integer = 0

If Not Int32.TryParse(sSurveyID, nSurveyID) OrElse nSurveyID <= 0 Then
	Response.Redirect(GetUrl("Home"))
End If

Dim UserWeeklySurvey As New ACHESS.UserWeeklySurvey(ACHESSApp, UserData.UserId, GetSessionUserProject())
UserWeeklySurvey.SurveyId = nSurveyID

' They are done with the survey, update the database (if the finish date hasn't been updated already)
If UserWeeklySurvey.getStatus() <> "complete" Then
	UserWeeklySurvey.SaveUserWeeklySurveyStatus("complete")
	UserWeeklySurvey.UpdateHIVHCVFinal()
	
	If UserWeeklySurvey.UserMedicationInfo.CheckUserHIVHCVEnable("HIV") Then
		Dim TempWeeklySurveyQuestion As New ACHESS.WeeklySurveyQuestion(ACHESSApp, "E66B43EA-E5C1-423B-BD34-ADD2C7EF454E")
		
		Dim TempUserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, nSurveyID)
		TempUserWeeklySurveyAnswer.GUID = TempWeeklySurveyQuestion.GUID
		TempUserWeeklySurveyAnswer.QuestionID = TempWeeklySurveyQuestion.QuestionId
		TempUserWeeklySurveyAnswer.PageNo = TempWeeklySurveyQuestion.PageNo
		TempUserWeeklySurveyAnswer.Answer = UserWeeklySurvey.UserMedicationInfo.GetKeyValue("HIVStage")
		TempUserWeeklySurveyAnswer.AnswerType = ""
		TempUserWeeklySurveyAnswer.save()
	End If

	If UserWeeklySurvey.UserMedicationInfo.CheckUserHIVHCVEnable("HCV") Then
		Dim TempWeeklySurveyQuestion As New ACHESS.WeeklySurveyQuestion(ACHESSApp, "9F83E250-27E5-4CC3-9D29-C4CCD1E9A499")
		
		Dim TempUserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, nSurveyID)
		TempUserWeeklySurveyAnswer.GUID = TempWeeklySurveyQuestion.GUID
		TempUserWeeklySurveyAnswer.QuestionID = TempWeeklySurveyQuestion.QuestionId
		TempUserWeeklySurveyAnswer.PageNo = TempWeeklySurveyQuestion.PageNo
		TempUserWeeklySurveyAnswer.Answer = UserWeeklySurvey.UserMedicationInfo.GetKeyValue("HCVStage")
		TempUserWeeklySurveyAnswer.AnswerType = ""
		TempUserWeeklySurveyAnswer.save()
	End If
End If

' Loads the feedback if it already exists
UserWeeklySurvey.UserMedicationInfo.DetermineFeedback(sSurveyID)
%>
<!--#include file="~/Include-V2/PageTop.aspx" -->
<!--#include file="~/Include-V2/Nav-NoLocalNav-Menu.aspx" -->

<h4>Hi <%=UserStringValue("ScreenName")%>, </h4>

<div class="renderShortcodes">
	<%=UserWeeklySurvey.UserMedicationInfo.finalFeedback%>
</div>

<div class="text-center" style="margin-top:50px;">
	<a href="<%=GetUrl("Home")%>" class="btn btn-info"><span class="glyphicon glyphicon-home"></span> Go to Main Menu</a>
</div>
<%
' This is required for saving a visit to this page
SetApplicationPage("", "Survey", "View Results", "SurveyID:" & sSurveyID)
%>
<!--#include file="~/Include-V2/PageBottom.aspx" -->