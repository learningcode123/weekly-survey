<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="~/Globals/Globals.aspx" -->
<%
If Not (UserIsSuperAdmin() OR UserIsSiteAdmin() ) Then
    Response.Redirect(GetUrl("Admin-Home"))
End If

Dim siteId As Integer = -1
ACHESS.Request.GetInteger("siteId", siteId, siteId)

' Super Admin can see any data
If Not UserIsSuperAdmin Then
    siteId = UserIntegerValue("SiteID")
End If

Dim dr1 As SqlDataReader = ExecuteReader("SELECT DISTINCT q.SurveyType, q.FieldName, q.Question FROM WeeklySurveyQuestions q ORDER BY q.FieldName")

Dim dr As SqlDataReader = ExecuteReader("SELECT m.StudyID, m.CodeName, (SELECT CASE WHEN COUNT(*) > 0 THEN 'True' ELSE 'False' END FROM UserPermissions up WHERE up.userId = m.UserID AND up.permissionGuid = 'hiv-user-avenir' AND up.isEnabled = 'True' AND up.deleteDate IS NULL) AS AvenirParticipant, mm.MedicationName, s.surveyId, s.status, s.finishDate, q.PageNo, q.QuestionId, q.SurveyType, q.FieldName, q.Question, a.Answer, a.CreateDate FROM UserWeeklySurveys s LEFT JOIN MobileUsers m ON m.UserId = s.UserId LEFT JOIN UserMedicationInfo um ON um.UserId = m.UserId AND um.KeyName = 'MedicationId' LEFT JOIN MedicationList mm ON mm.MedicationId = um.Value LEFT JOIN UserWeeklySurveyAnswers a ON s.surveyId = a.surveyId LEFT JOIN WeeklySurveyQuestions q ON q.GUID = a.GUID WHERE (m.SiteID = @SiteID1 OR @SiteID2 = '-1') AND s.finishDate > DATEADD(day, -90, GETDATE()) AND s.DeleteDate IS NULL ORDER BY m.CodeName, s.surveyId DESC, q.PageNo ASC", siteId, siteId)

sServiceTitle = GetStr("Admin-WeeklySurveys-Header")
%>
<!--#INCLUDE FILE="~/Include-V2/Header-Admin.aspx"-->

<a href="<%=GetURL("AppUrl")%>WeeklySurvey/WeeklySurvey-Export.aspx" style="float:right;"><strong><%=GetStr("Admin-WeeklySurveys-Download-Excel")%></strong></a>

<h1><%=sServiceTitle%></h1>
<%
OutputAlert()
%>

<%
' Output the legend, a table of field names and their associated questions
%>
<p class="showButton">
	<a href="#" onclick="$('.legend').show(); $('.showButton').hide(); return false;"><%=GetStr("Admin-WeeklySurveys-Legend-Show")%></a>
</p>

<div class="legend" style="display:none;">
<p>
	<a href="#" onclick="$('.showButton').show(); $('.legend').hide(); return false;"><%=GetStr("Admin-WeeklySurveys-Legend-Hide")%></a>
</p>

<table id="survey-results">
	<tr>
		<th><%=GetStr("Admin-WeeklySurveys-Legend-Table-Field")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Legend-Table-Question")%></th>
	</tr>
<%
While dr1.Read()
%>
	<tr>
		<td><%=dr1("SurveyType").ToString()%>: <%=dr1("FieldName").ToString()%></td>
		<td><%=dr1("Question").ToString()%></td>
	</tr>	
<%
End While
dr1.Close()
%>
</table>
</div>

<%
' Output the survey data for the past 60 days

If dr.HasRows Then
%>
<div style="margin-bottom:10px;">
	<input type="radio" name="show" id="show-all" value="all" checked="checked" onclick="filterResults('all');" autocomplete="off" /> <label for="show-all" class="inline"><%=GetStr("Admin-WeeklySurveys-Table-ShowAll")%></label> |
	
	<input type="radio" name="show" id="show-avenir" value="avenir" onclick="filterResults('avenir');" autocomplete="off" /> <label for="show-avenir" class="inline"><%=GetStr("Admin-WeeklySurveys-Table-ShowAvenir")%></label> |
	
	<input type="radio" name="show" id="show-bundling" value="bundling" onclick="filterResults('bundling');" autocomplete="off" /> <label for="show-bundling" class="inline"><%=GetStr("Admin-WeeklySurveys-Table-ShowBundling")%></label>
	
	<span style="display:none; color:red;" id="filtering">&nbsp; &nbsp; &nbsp; <%=GetStr("Admin-WeeklySurveys-Table-Filtering")%></span>
</div>

<p><%=GetStr("Admin-WeeklySurveys-Showing-Text")%></p>

<table class="table table-striped">
<thead>
	<tr>
		<th><%=GetStr("Admin-WeeklySurveys-Table-SurveyID")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-Username")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-Project")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-StudyID")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-UserMedication")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-SurveyStatus")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-SurveyFinishDate")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-Question")%></th>
		<th><%=GetStr("Admin-WeeklySurveys-Table-Answer")%></th>
	</tr>
</thead>

<tbody>
<%
While dr.Read()
%>
	<tr class="row <%=IIF(Convert.ToBoolean(dr("AvenirParticipant").ToString()), "row-avenir", "row-bundling")%>">
		<td><%=dr("SurveyID").ToString()%></td>
		<td><%=dr("CodeName").ToString()%></td>
		
		<td>
			<%
			If Convert.ToBoolean(dr("AvenirParticipant").ToString()) Then
				Response.write("Avenir")
			Else
				Response.write("Bundling")
			End If
			%>
		</td>
		
		<td><%=dr("StudyID").ToString()%></td>
		<td><%=dr("MedicationName").ToString()%></td>
		<td><%=dr("Status").ToString()%></td>
		<td><%
		If dr("FinishDate").ToString() <> "" Then
			Response.Write(Convert.ToDateTime(dr("FinishDate")).ToString(DefaultUrlDateFormat & " " &DefaultTimeFormat))
		End If
		%></td>
		<td><%=dr("SurveyType").ToString()%>: <%=dr("FieldName").ToString()%></td>
		<td><%=dr("Answer").ToString()%></td>
	</tr>
<%
End While
%>
</tbody>
</table>

<%
Else
%>
	No data available

<%
End If
dr.Close()
%>

<script type="text/javascript">
/**
 * Filter the results of the table by project
 *
 * @param string project
 *
 * @return null
 *
 * @since 1.0.5
 */
function filterResults(project)
{
	$("#filtering").show();
	
	var _project = project;
	setTimeout(function() {
		if (_project == "avenir") {
			avenir.show();
			bundling.hide();

		} else if (_project == "bundling") {
			avenir.hide();
			bundling.show();

		} else {
			all.show();
		}
		
		$("#filtering").hide();
		}, 60);
}

var all = null;
var avenir = null;
var bundling = null;

$(document).ready(function() {
	all = $(".row");
	avenir = all.filter(".row-avenir");
	bundling = all.filter(".row-bundling");
});
</script>

<%
' This is required for saving a visit to this page
SetApplicationPage("", "Admin", "View Weekly Survey Report", "SiteID:" & siteId.ToString())
%>
<!--#INCLUDE FILE="~/Include-V2/Footer-Admin.aspx"-->