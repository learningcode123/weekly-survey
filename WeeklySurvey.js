// Initially set the score of every question to 0
// Will be set by the script in caller
var wsForm = null;
var pageID = 0;

function initVars(frm, pgid) 
{
	wsForm = frm;
	pageID = pgid;
}

function submitPage() 
{
	var valid =  false;
	var GUIDList = wsForm.GUIDIDs.value.split(",");
	
	for (var i=0; i< GUIDList.length; i++) {
		var eleName = "Question"+GUIDList[i];
		
		if (!($('input[name='+ eleName+']:checked').length > 0) && !($('input[name="'+ eleName+'[]"]:checked').length > 0)) {
			alert('Please answer all questions');
			return false;
		}
		
		if($('input[name=PrevQuesAns'+ GUIDList[i]+']').length > 0 && ($('input[name=PrevQuesAns'+ GUIDList[i]+']').val() != $('input[name="'+ eleName+'[]"]:checked').length))
		{ 
			alert('Please check ' + $('input[name=PrevQuesAns'+ GUIDList[i]+']').val() + ' days');
			return false;
		}
		
	}
	
	wsForm.submit(); 
}

function checkAns(sName) 
{
	var rb = wsForm[sName+""];
	var valid = false;
	
	for (var i=0; i < 8; i++) { 
		if (rb[i].checked) {
			valid = true;
			break;
		} 
	}
	
	if (valid) { 
		wsForm.submit();
		
	} else { 
		alert("Please select one of the choices"); 
	}
}
