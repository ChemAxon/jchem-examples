<%--

 uploader.jsp

 ChemAxon Ltd., 2001

 Prepare uploading file from client side to server side.

--%> 

<%@ page import="
java.sql.*,
java.util.*,
java.text.DecimalFormat,
chemaxon.jchem.db.*, 
chemaxon.util.*"
errorPage="../errorpage.jsp"
%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Import</title>
<script language="JavaScript">
<!--
function checkIfOpened() {
    if (document.childOpened!="true") {
        alert("JChem has detected that popup windows are disabled."
                +" Please check your browser and internet security settings,"
                +" and restart your browser after the changes.");
        window.close();
    } else {
        document.uploadForm.OKButton.disabled = false;
    }

}

function openCheck() {
    setTimeout('checkIfOpened()',3000);
}
-->
</script>
</head>
<body bgcolor="#e1e1e1">
<script language="JavaScript">
<!--
opener.document.childOpened="true";  //For pop-up window check

//an other popup test for Mozilla:
document.childOpened="false";
window.open ('../popuptest.html','newWin','resizable=no,scrollbars=no,status=no,height=50,width=150');
openCheck();
-->
</script>
<%
//If possibles get the ConnectionHandler from the session 
ConnectionHandler ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");

if((ch==null)||(!ch.isConnected())) {
    Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
    if(v == null) {
        %>
        <script LANGUAGE="JavaScript">
        <!--
        opener.location.href="../expired.html";
        window.close();
        -->
        </script>
        <%
        return;
    }
    ch = new ConnectionHandler();
    ch.setDriver((String)v.elementAt(2));
    ch.setUrl((String)v.elementAt(3));
    ch.setLoginName((String)v.elementAt(0));
    ch.setPassword((String)v.elementAt(1));
    ch.setPropertyTable((String)v.elementAt(4));
    ch.connectToDatabase();
    session.setAttribute(sessionVarPrefix+"ch",ch);
}

session.removeAttribute(sessionVarPrefix+"UploadThreadFinished");

Vector allowedTables;

if(readOnlyTableNames != null) {
    Vector readOnlyTables = new Vector();
    try {
	String delim = ":";
	if(readOnlyTableNames.indexOf(":") == -1) {
	    delim = ";"; 
	}
	StringTokenizer importToken = 
				new StringTokenizer(readOnlyTableNames,delim);
	while(importToken.hasMoreTokens()) {	
	    readOnlyTables.add(importToken.nextToken());
	}
    } catch (NoSuchElementException e) {};
    allowedTables = new Vector();
    Vector strtables = (new DatabaseProperties(ch)).getStructureTableNames();
    for(int i=0;i<strtables.size();i++) {
	boolean readOnly = false;
	for(int j=0;j<readOnlyTables.size();j++) {
	    if(readOnlyTables.get(j).equals(strtables.get(i))) {
		readOnly = true;
	    }
	}
	if(!readOnly) {
	    allowedTables.add(strtables.get(i));
	}
    }
} else {
    allowedTables = (new DatabaseProperties(ch)).getStructureTableNames();
}

//If import is not allowed.
if(allowedTables.size() == 0) {
    %>
    <script language='javascript'>
    <!--
	alert("You are not allowed to import into any table.");
    //-->
    </script>
    <%
    return;
}
%>
<FORM name="uploadForm" ENCTYPE="multipart/form-data" method="post">
<table>
  <tr>
    <td>Database table:</td>
	<!--Select table for importing into.-->
    <td><select name="tableSelect">
	    <%
	    for(int i=0;i<allowedTables.size();i++) {
	      out.println("<option>"+allowedTables.get(i)+"</option>");
	    }
	    %>
      </select>
      <input type="hidden" name="tableName" value="">
    </td>
  </tr>
  <tr>
      <!-- Browse for file to upload and import.-->
    <td>Input file:</td><td><input type="file"  name="file" size="30"
        onInput="filenameChanged()"></td>
  </tr>
</table>
<br>

<!--Import parameters -->

<input type="checkbox" name="lineCheckBox" onClick="check()"> Check whole file for field names in selected file<br><br>
<table>
    <tr>
	<td>Number of lines to check:</td>
	<td><Input type="text" name="lineCheck" size="4" value="500"></td>
    </tr><tr>
	<td>Number of molecule to skip:</td>
	<td><Input type="text" name="skip" size="4" value="0"></td>
    </tr>
</table>
<table align='center' width='80%'>
    <tr>
	<td align='left'><input type="checkbox" name="errorCheckBox" >
	    Halt if an error occurs.</td>
	<td align='right'></td>
    </tr>
</table>
<table align='right'>
    <tr>
	<td>
	<input disabled="true" name="OKButton" align='right' size='15' type="button" value="Next" onClick="uploadFile();"></td>
	<td><input align='right' size='15' type="button" value="Cancel" onClick='window.close();'></td>
    </tr>
</table>
<input type='hidden' name='haltOnError'>
</form>
<script language="javascript">
<!--
//If the checkbox checked shows a confirm window.
function check() {
    if(document.uploadForm.lineCheckBox.checked) {
        document.uploadForm.lineCheck.disabled=true;
 	document.uploadForm.lineCheck.value='';
    } else {
	document.uploadForm.lineCheck.disabled=false;
	document.uploadForm.lineCheck.value='500';
    }
}

//Check the form if selected and entered data are proper.
function checkForm()
{
    form = document.uploadForm;
    if(form.file.value == "") {
 	alert("Select a file.");
	return false;
    } else if(form.skip.value!=null && form.skip.value!='') {
	    if(isNaN(parseInt(form.skip.value))) {
	    	alert("'" + form.skip.value + "' is not a valid integer value");
	    	return false;
	    }
    }
    if(!form.lineCheckBox.checked) {
	if(isNaN(parseInt(form.lineCheck.value))) {
	    alert("'" + form.lineCheck.value + "' is not a valid integer value");
	    return false;
	}
    }

    return true;
}

//Submit the form, open a new window for monitoring upload.
function uploadFile() {
    if(checkForm()) {
	var index = document.uploadForm.tableSelect.selectedIndex;
	document.uploadForm.tableName.value = document.uploadForm.tableSelect.options[index].text;
	if(document.uploadForm.skip.value == "") document.uploadForm.skip.value = "0";
	document.uploadForm.haltOnError.value = document.uploadForm.errorCheckBox.checked;
	var x = window.screenX + 10;
	var y = window.screenY + 10;
	var condition = new String("resizable=no,width=300,height=150, scrollbars=no,menubar=no,location=no,dependent=yes, screenX="+x+", screenY="+y);
    	var w = window.open("uploadprogress.jsp"+location.search,"progress",condition);
        document.uploadForm.action="upload.jsp"+location.search;
    	document.uploadForm.submit();
    }
}

function filenameChanged() {
    document.uploadForm.skip.disabled=false;
    var filename=document.uploadForm.file.value;
    var index=filename.lastIndexOf(".");
    if (index>0) {
        var extension=filename.substring(index);
        if (extension.substring(0,3)==".rd") {
            document.uploadForm.skip.value="0";
            document.uploadForm.skip.disabled=true;
        }
    }
}
//-->
</script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-453558-10', 'auto');
  ga('send', 'pageview');

</script>
</body>
</html>
