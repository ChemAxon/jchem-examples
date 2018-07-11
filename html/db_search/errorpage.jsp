<%
/* 
 * In case of error, the script displays the error message(s)
 * and returns.
 */
%>
<%@ page import="java.io.*,chemaxon.util.*"%>
<html><head>
<title>Error Page</title>
<script language="JavaScript">
<!--
function popupMessage() {
    var errorPage = '<%
    String exceptionHTML=
    "<HTML>\n"+
    "<HEAD>\n"+
    "<title>Stack Trace</title>\n"+
    "</HEAD>\n"+
    "<BODY>\n"+
    "<PRE>\n"+
    "JChem version : "+chemaxon.jchem.version.VersionInfo.getJChemTableVersion()+"\n"+
    "JVM : "+System.getProperty("java.vendor")+" "+System.getProperty("java.version")+"\n"+
    "OS  : "+System.getProperty("os.arch")+" "+System.getProperty("os.name")+" "+System.getProperty("os.version")+"\n"+
    "\n\nStack trace:\n"+
    "------------\n\n\n"+
    stackToString(exception)+"\n"+
    "</PRE>\n"+
    "</BODY>\n"+
    "</HTML>\n";
    out.print(HTMLTools.convertForJavaScript(exceptionHTML));
    %>';
    var oWin=window.open("","NULL","statusbar=0, scrollbars=1");
    oWin.document.open();
    oWin.document.write(errorPage);
    oWin.document.close();
}
-->
</script>
</head>
<%@ page isErrorPage="true" %> 
<%!
static public String stackToString(Throwable e) {
    try {
	StringWriter sw = new StringWriter();
	PrintWriter pw = new PrintWriter(sw);
	e.printStackTrace(pw);
	return sw.toString();
    } catch(Exception e2) {
	return "stackToString error";
    }
}
%>

<body bgcolor="#e0e0e0"> 

<% 
exception.printStackTrace(); // send the stack trace to the server's error log
if(exception.getMessage()!=null) {
    try {
        %><%= HTMLTools.exceptionToString(exception) %><%
    } catch(Exception nf) {
        %>Error: JChem repository not found<%
    }
} else {
    %>An unknown error occured<%
}
%>

<br><br>
<input type="button" value="View stack trace" onClick="popupMessage()">
<pre>
<!--
<%= stackToString(exception) %>
-->
</pre>
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
