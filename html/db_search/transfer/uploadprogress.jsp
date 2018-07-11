<%--

 uploadprogress.jsp
 
 ChemAxon Ltd., 2002
 
 Displaying progress and starts monitoring the upload process.
 User has chance to cancel the upload by a cancel buttom.
 
--%> 

<%@ page import="chemaxon.util.*,chemaxon.jchem.db.*,chemaxon.jchem.file.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Uploading</title>
</head>
<body bgcolor="#e1e1e1" onload="doLoad()">
<form name='progressForm' method='post'>
<font size=+2 color='red' face="helvetica">
<%
//Gets the UploadThread from the session.
UploadThread uh = (UploadThread)session.getAttribute(sessionVarPrefix+"UploadThread");

String uploadFinished = (String)session.getAttribute(sessionVarPrefix+"UploadThreadFinished");

if(uploadFinished==null) uploadFinished = "false";

if(uh!=null) { 
    //Write the progress on the page.
    int p = uh.getPercent();
    out.println("Uploading... Please Wait.<br>");
    out.println("<br><font size=-1 color='black'>Progress: "+p+"%");
    uploadFinished = "true";
} else {
    //if upload finished.
    if(uploadFinished.equals("true")) {  
    session.removeAttribute(sessionVarPrefix+"UploadThreadFinished");  	
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
  <!-- Cancel button to interrupt the uploading. -->
  <input type='button' value='Cancel' onClick='uploadCancel();'>
</td></tr></table>
<input type='hidden' name='finished' value='<%=uploadFinished%>'>
</form>
<script language="JavaScript">
<!--
//Interrupt the upload process.
function uploadCancel() {
    document.progressForm.action = 'threadcancel.jsp'+location.search;
    document.progressForm.submit();
}
function doLoad()
{
    document.progressForm.action = 'uploadprogress.jsp'+location.search;
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

