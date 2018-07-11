<%--

 importprogress.jsp
 
 ChemAxon Ltd., 2002
 
 Displaying progress and starts monitoring the imported molecules' number.
 User has chance to cancel the import by a cancel buttom.
 
--%> 

<%@ page import="chemaxon.util.*,chemaxon.jchem.db.*,chemaxon.jchem.file.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Importing</title>
</head>
<body bgcolor="#e0e0e0" onload="doLoad()">
<form name='progressForm' method='post'>
<%
//Gets importer from the session.
Importer it = (Importer)session.getAttribute(sessionVarPrefix+"ImportThread");

String importFinished = (String)session.getAttribute(sessionVarPrefix+"ImportThreadFinished");

if(importFinished==null) importFinished = "false";


if(it!=null) {
    // Writes the progress to the page.
    out.println("<font size=+2 color='red' face='helvetica'>");
    out.println("Importing... Please Wait.<br>");
    out.println("<br><font size=-1 color='black'>Progress: "+it.getNote());	
    importFinished = "true";
} else {
    // If import has finished removes the importer from the session.
    if(importFinished.equals("true")) {
	session.removeAttribute(sessionVarPrefix+"ImportThreadFinished");
	%>
	<script language="javascript">
	<!--
	window.close();
	//-->
	</script>
	<%
    }
}

%>
<br><br>
<table width='100%'>
<tr><td align='right'>
  <!-- Cancel buttom for interrupting the import progress. -->
  <input type='button' value='Cancel' onClick='importCancel();'>
</td></tr></table>
<input type='hidden' name='importFinished' value='<%=importFinished%>'>

</form>
<script language="JavaScript">
<!--
// Interrupt the import with calling threadcancel.jsp
function importCancel() {
    document.progressForm.importFinished.value='true';
    document.progressForm.action = 'threadcancel.jsp'+location.search;
}
function doLoad()
{
    document.progressForm.action='importprogress.jsp'+location.search;
    setTimeout('document.progressForm.submit()', 1000 );
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

