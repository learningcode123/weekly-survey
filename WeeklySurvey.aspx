<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" Trace="False" %>
<!--#include File="~/Globals/Globals.aspx" --> 
<%
PageDetails.Add("Title", "Survey")
PageDetails.Add("Header", "Weekly Survey")

' Check if the user has an incomplete survey to fill out
Dim surveyId As Integer = 0
ACHESS.Request.GetInteger("SurveyID", surveyId, surveyId)

If surveyId <= 0 Then
	Dim lastSurveyDetails As Dictionary(Of String, String) = GetLastWeeklySurveyDetails(UserData.UserId)
	
	If lastSurveyDetails.Item("lastSurveyId") <> "0" AndAlso lastSurveyDetails.Item("weeklySurveyFeedbackUrl").ToString() <> "" Then
		Response.Redirect(lastSurveyDetails.Item("weeklySurveyFeedbackUrl").ToString())
	End If
	
	If lastSurveyDetails.Item("lastSurveyId") <> "0" AndAlso lastSurveyDetails.Item("weeklySurveyUrl").ToString() <> "" Then
		Response.Redirect(lastSurveyDetails.Item("weeklySurveyUrl").ToString())
	End If
End If

Dim UserWeeklySurvey As New ACHESS.UserWeeklySurvey(ACHESSApp, UserData.UserId, GetSessionUserProject())

Dim pageId As String = ""
ACHESS.Request.GetString("PageID", pageId, pageId)

If pageId = "" Or pageId = "0" Then
	pageId = UserWeeklySurvey.GetWeeklySurveyFirstPageNo()
End If

UserWeeklySurvey.SurveyId = surveyId
UserWeeklySurvey.sPageID = pageId

If pageId = UserWeeklySurvey.GetWeeklySurveyFirstPageNo() Then
	UserWeeklySurvey.UpdateUserMedicationInfo()
End If

Dim WeeklySurveyQuestionList As List(Of ACHESS.WeeklySurveyQuestion) = UserWeeklySurvey.GetQuestionsOnPage(pageId)
Dim GUIDList As New List(Of String)

For Each WeeklySurveyQuestion In WeeklySurveyQuestionList
	If Not WeeklySurveyQuestion.HasSubQues Then
		GUIDList.Add(WeeklySurveyQuestion.GUID)
		
		'Dim showQuestion As Boolean = True
		'If WeeklySurveyQuestion.Survey_Period.Contains("monthly") Then
		'	showQuestion = UserWeeklySurvey.hasToTakeMonthlyQuestion(WeeklySurveyQuestion.GUID)
		'End If

		'If Not showQuestion OrElse (WeeklySurveyQuestion.hasQuestionDependee() AndAlso Not UserWeeklySurvey.CheckToShowQuestionDependencies(WeeklySurveyQuestion)) Then
		If WeeklySurveyQuestion.hasQuestionDependee() AndAlso Not UserWeeklySurvey.CheckToShowQuestionDependencies(WeeklySurveyQuestion) Then
			Dim NextPageNo As String = UserWeeklySurvey.GetWeeklySurveyNextPageNo()
			
			If NextPageNo.ToString() <> "" AndAlso NextPageNo.ToString() <> "-100" Then
				Response.Redirect("WeeklySurvey.aspx?GUID=" & B64UserID & "&PageID=" & NextPageNo & "&SurveyID=" & surveyId & "&From=WS")
				
			Else
				SetApplicationPage("", "Survey", "Saved Survey Page", "SurveyID:" & surveyId & ",PageID:,SurveyStatus:Complete", True)
				Response.Redirect("WeeklySurveyResults.aspx?GUID=" & B64UserID & "&SurveyID=" & PageHelper.EncodeIntegerToString(surveyId))
			End If
		End If
	End If
Next
%>

<!--#include file="~/Include-V2/PageTop.aspx" -->
<!--#include file="~/Include-V2/Nav-NoMenu.aspx" -->

<form name="WeeklySurveyForm" action="WeeklySurveySave.aspx" id="WeeklySurveyForm" method="post" autocomplete="false">
	<input type="hidden" name="GUID" value="<%=B64UserID%>" />
	<input type="hidden" name="SurveyID" value="<%=surveyId%>" />
	<input type="hidden" name="PageID" value="<%=pageId%>" />
	<% 
	For Each WeeklySurveyQuestion In WeeklySurveyQuestionList
		If WeeklySurveyQuestion.HasSubQues Then 
		%>
			<h4><%=WeeklySurveyQuestion.Question%></h4>
		<% 
		Else
		%>
			<fieldset class="well survey">
			
			<p class="survey-question text-left">
				<%=WeeklySurveyQuestion.Question%>
			</p>
			
			<%
			If WeeklySurveyQuestion.QuestionType = "YN" Then 
			%>
				<div style="text-align:center" class="clearfix">
					<div class="btn-group" data-toggle="buttons">
						<label class="btn btn-default" for="Question<%=WeeklySurveyQuestion.QuestionId%>">
							<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="Question<%=WeeklySurveyQuestion.QuestionId%>" value="Yes" />Yes
						</label>
						
						<label class="btn btn-default" for="NotQuestion<%=WeeklySurveyQuestion.QuestionId%>">
							<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="NotQuestion<%=WeeklySurveyQuestion.QuestionId%>" value="No" />No
						</label>
					</div>
				</div>
				
			<%
			Else If WeeklySurveyQuestion.QuestionType.Contains("scale") Then 
			%> 
				<div style="text-align:center" class="clearfix">
					<div class="btn-group" data-toggle="buttons">

					<% 
					If WeeklySurveyQuestion.QuestionType = "0scale" Then 
						%>
						<label class="btn btn-default" for="0Question<%=WeeklySurveyQuestion.QuestionId%>">
							<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="1Question<%=WeeklySurveyQuestion.QuestionId%>" value="0" />0
						</label>
						<% 
					End If
					%>

					<label class="btn btn-default" for="1Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="1Question<%=WeeklySurveyQuestion.QuestionId%>" value="1" />1
					</label>
					
					<label class="btn btn-default" for="2Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="2Question<%=WeeklySurveyQuestion.QuestionId%>" value="2" />2
					</label>
					
					<label class="btn btn-default" for="3Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="3Question<%=WeeklySurveyQuestion.QuestionId%>" value="3" />3
					</label>
					
					<label class="btn btn-default" for="4Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="4Question<%=WeeklySurveyQuestion.QuestionId%>" value="4" />4
					</label>
					
					<label class="btn btn-default" for="5Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="5Question<%=WeeklySurveyQuestion.QuestionId%>" value="5" />5
					</label>
					
					<label class="btn btn-default" for="6Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="6Question<%=WeeklySurveyQuestion.QuestionId%>" value="6" />6
					</label>
					
					<label class="btn btn-default" for="7Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="7Question<%=WeeklySurveyQuestion.QuestionId%>" value="7" />7
					</label>
			
					</div>
				</div>
			
				<p class="<%=WeeklySurveyQuestion.CSSClass%>">
					<span class="good">
						<%=WeeklySurveyQuestion.OneTextAnchor%>
					</span>
					
					<span class="bad pull-right">
						<%=WeeklySurveyQuestion.SevenTextAnchor%>
					</span>
				</p>
			
			<% 
			Else If WeeklySurveyQuestion.QuestionType = "choice"  Then 
				Dim choiceText() As String = WeeklySurveyQuestion.ChoiceText.Split(";")
				For k = 0 To choiceText.Length - 1
					Dim key As String = choiceText(k).Split(":")(1)
					Dim value As String = choiceText(k).Split(":")(0)
					
					%>
					<label class="radio-inline" for="<%=k+1%>Question<%=WeeklySurveyQuestion.QuestionId%>">
						<input type="radio" name="Question<%=WeeklySurveyQuestion.GUID%>" id="<%=k+1%>Question<%=WeeklySurveyQuestion.QuestionId%>" value="<%=key%>" /> <%=value%>
					</label>
					<%
					
				Next k
				
			Else If WeeklySurveyQuestion.QuestionType = "checkbox" Then 
				If WeeklySurveyQuestion.ChoiceText = "{lastSevenDays}" Then
					Dim UserWeeklySurveyAnswer As New ACHESS.UserWeeklySurveyAnswer(ACHESSApp, UserData.UserId, surveyId)
					Dim prevQuesAns As String = UserWeeklySurveyAnswer.GetUserWeeklySurveyAnswerByGUID(WeeklySurveyQuestion.QuesDependee)
					
					%>
					<input type="hidden" name="PrevQuesAns<%=WeeklySurveyQuestion.GUID%>" value="<%=prevQuesAns%>" />
					<%
					
					For k = 1 To 7
						Dim weekday As Date = Date.Today.AddDays(-1 * k)
						
						%>
						<div class="checkbox">
							<label class="checkbox" for="q-<%=WeeklySurveyQuestion.GUID%>-<%=k%>">
								<input type="checkbox" name="Question<%=WeeklySurveyQuestion.GUID%>[]" id="q-<%=WeeklySurveyQuestion.GUID%>-<%=k%>" value="<%=weekday%>" /> <%=weekday.ToString("dddd, MMM d")%>
							</label>  
						</div>
						<%
						
					Next k
					
				Else
					For k = 0 To WeeklySurveyQuestion.ChoiceText.Split(";").Length - 1
						Dim value As String = WeeklySurveyQuestion.ChoiceText.Split(";")(k).Split(":")(0)
						
						%>
						<div class="checkbox">
							<label class="checkbox" for="<%=k+1%>Question<%=WeeklySurveyQuestion.QuestionId%>">
								<input type="checkbox" name="Question<%=WeeklySurveyQuestion.GUID%>[]" id="<%=k+1%>Question<%=WeeklySurveyQuestion.QuestionId%>" value="<%=value%>" /><%=value%>
							</label>  
						</div>
						<%
						
					Next k
				End If
			End If
			%>
		
			</fieldset>
		
			<% 
		End If 
	Next
	%>
	
	<input type="hidden" name="GUIDIDs" value="<%=String.Join(",", GUIDList)%>" />
	<p class="clearfix">    
		<button type="button" onClick="submitPage();" class="btn btn-info pull-right" value="Continue">
			Continue <span class="glyphicon glyphicon-arrow-right"></span>
		</button>
	</p>
</form>

<script type="text/javascript" src="WeeklySurvey.js"></script>
<script type="text/javascript">
window.onload = (function() {
	initVars(document.WeeklySurveyForm, "<%=pageId%>");
});
</script>

<%
' This is required for saving a visit to this page
SetApplicationPage("", "Survey", "View Survey Page", "SurveyID:" & surveyId & ",PageID:" & pageId)
%>
<!--#include file="~/Include-V2/PageBottom.aspx" -->