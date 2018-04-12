<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" Trace="False" %>
<!--#include File="~/Globals/Globals.aspx" --> 
<%
Dim surveyId As Integer = 0
ACHESS.Request.GetInteger("SurveyID", surveyId, surveyId)
Dim haveNewSurvey As Boolean = (surveyId <= 0)

Dim pageId As String = ""
ACHESS.Request.GetString("PageID", pageId, pageId)

Dim UserWeeklySurvey As New ACHESS.UserWeeklySurvey(ACHESSApp, UserData.UserId, GetSessionUserProject())
UserWeeklySurvey.SurveyId = surveyId
UserWeeklySurvey.sPageID = pageId

If haveNewSurvey Then
	surveyId = UserWeeklySurvey.SaveUserWeeklySurveyStatus("incomplete")
	UserWeeklySurvey.SurveyId = surveyId
	
	If UserWeeklySurvey.UserMedicationInfo.CheckUserHIVHCVEnable("HIV") Then
		Dim TempWeeklySurveyQuestion As New ACHESS.WeeklySurveyQuestion(ACHESSApp, "8F3FCF08-C04E-4684-A70B-401D8CF2927C")
		
		Dim TempUserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, surveyId)
		TempUserWeeklySurveyAnswer.GUID = TempWeeklySurveyQuestion.GUID
		TempUserWeeklySurveyAnswer.QuestionID = TempWeeklySurveyQuestion.QuestionId
		TempUserWeeklySurveyAnswer.PageNo = TempWeeklySurveyQuestion.PageNo
		TempUserWeeklySurveyAnswer.Answer = UserWeeklySurvey.UserMedicationInfo.GetKeyValue("HIVStage")
		TempUserWeeklySurveyAnswer.AnswerType = ""
		TempUserWeeklySurveyAnswer.save()
	End If
	
	If UserWeeklySurvey.UserMedicationInfo.CheckUserHIVHCVEnable("HCV") Then
		Dim TempWeeklySurveyQuestion As New ACHESS.WeeklySurveyQuestion(ACHESSApp, "3F2CD112-78A8-4879-B042-028ED3117400")
		
		Dim TempUserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, surveyId)
		TempUserWeeklySurveyAnswer.GUID = TempWeeklySurveyQuestion.GUID
		TempUserWeeklySurveyAnswer.QuestionID = TempWeeklySurveyQuestion.QuestionId
		TempUserWeeklySurveyAnswer.PageNo = TempWeeklySurveyQuestion.PageNo
		TempUserWeeklySurveyAnswer.Answer = UserWeeklySurvey.UserMedicationInfo.GetKeyValue("HCVStage")
		TempUserWeeklySurveyAnswer.AnswerType = ""
		TempUserWeeklySurveyAnswer.save()
	End If
End If

Dim guidIds As String = ""
ACHESS.Request.GetString("GUIDIDs", guidIds, guidIds)
guidIds = String.Concat("'", String.Join("','", guidIds.Split(",")), "'")

For Each WeeklySurveyQuestion In UserWeeklySurvey.GetQuestionsByGUIDs(guidIds)
	Dim Answer As String = Nothing
	Dim AnswerType As String = ""
	
	If Request("Question" & WeeklySurveyQuestion.GUID) IsNot Nothing Then
		Answer = Request("Question" & WeeklySurveyQuestion.GUID).ToString()
	End If
	
	If Request("Question" & WeeklySurveyQuestion.GUID & "[]") IsNot Nothing Then
		Answer = String.Join(";", Request.Form.GetValues("Question" & WeeklySurveyQuestion.GUID & "[]"))
		AnswerType = "checkbox"
	End If

	Dim UserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, surveyId)
	UserWeeklySurveyAnswer.GUID = WeeklySurveyQuestion.GUID
	UserWeeklySurveyAnswer.QuestionID = WeeklySurveyQuestion.QuestionId
	UserWeeklySurveyAnswer.PageNo = WeeklySurveyQuestion.PageNo
	UserWeeklySurveyAnswer.Answer = Answer
	UserWeeklySurveyAnswer.AnswerType = AnswerType
	UserWeeklySurveyAnswer.save()
	
	Dim userMedInfo As String = WeeklySurveyQuestion.UpdateUserMedInfo.ToString()
	If userMedInfo <> "" Then
		If userMedInfo.Contains("|") Then
			Dim UpdateUserMedInfo_Array() As String = userMedInfo.Split("|")
			Dim CheckValueToUpdateUserMedInfo_Array() As String = WeeklySurveyQuestion.CheckValueToUpdateUserMedInfo.Split("|")
			
			If UpdateUserMedInfo_Array.Length = CheckValueToUpdateUserMedInfo_Array.Length Then
				Dim i As Integer = 0
				While i < UpdateUserMedInfo_Array.Length
					UserWeeklySurvey.UserMedicationInfo.SaveUserMedicationInfoFromSurvey(UpdateUserMedInfo_Array(i), CheckValueToUpdateUserMedInfo_Array(i).Split(":")(1))
					i = i + 1
				End While
			End If
		Else
			For Each arr_value in WeeklySurveyQuestion.CheckValueToUpdateUserMedInfo.Split(";")
				Dim key As String = arr_value.Split(":")(0)
				Dim val As String = arr_value.Split(":")(1)
				
				If Answer.ToString() = key.ToString() Then
					UserWeeklySurvey.UserMedicationInfo.SaveUserMedicationInfoFromSurvey(userMedInfo, val)
				End If
			Next
		End If
   End If
Next

' Get the next page to go to
Dim nextPageId As String = UserWeeklySurvey.GetWeeklySurveyNextPageNo()
If nextPageId.ToString() <> "" And nextPageId <> "-100" Then
	' Required for saving a visit to this page
	SetApplicationPage("", "Survey", "Saved Survey Page", "SurveyID:" & surveyId & ",PageID:" & pageId & ",NextPageID:" & nextPageId & ",SurveyStatus:In Progress", True)
	
	Response.Redirect(GetUrl("WeeklySurveys-GUID", "GUID", B64UserID, "PageID", nextPageId, "SurveyID", surveyId, "From", "WS"))
Else
	' Required for saving a visit to this page
	SetApplicationPage("", "Survey", "Saved Survey Page", "SurveyID:" & surveyId & ",PageID:" & pageId & ",SurveyStatus:Complete", True)
	Response.Redirect(GetUrl("WeeklySurveys-Results", "GUID", B64UserID, "SurveyID", PageHelper.EncodeIntegerToString(surveyId)))
End If
%>