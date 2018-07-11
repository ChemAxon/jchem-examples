<%--

 import.jsp
 
 ChemAxon Ltd., 2002
 
 Importing from structure file into database tables.
 
--%> 

<%@ page import="java.io.*,java.util.zip.*,java.sql.*,chemaxon.jchem.db.*,chemaxon.jchem.file.*,chemaxon.util.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Import</title>
</head>
<body bgcolor="#e0e0e0" onload="resize()">
<form name=impForm>
<%

//There is limitation for importing molecules on the site.

boolean isLimitation = @FORSITE@;
int molsToImportLimit = 50;

//If possible gets the ConnectionHandler object from the session 
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

//Gets posted parameters.
String tableName = request.getParameter("tableName");
String filePath = request.getParameter("filePath");
String connects = request.getParameter("connects");
int skip = 0;
try {
    skip=Integer.parseInt(request.getParameter("skip"));
} catch (NumberFormatException e) {}
String haltOnError = request.getParameter("haltOnError");
String lineCheck = request.getParameter("lineCheck");

//Sets parameters for import.
//Creates a ProgressWriter for monitoring.
ProgressWriter pw = new ProgressWriter("Initialization and skipping", 1, 10000);

Importer ithread = new Importer();

if(connects==null) connects="";

int linesToCheck = 0;
try {
    linesToCheck = Integer.parseInt(lineCheck);
} catch (Exception e) {}


//Sets the importthread's parameters.
try {

    File file = new File(filePath);

    ithread.setConnectionHandler(ch);
    ithread.setInput(file);
    ithread.setTableName(tableName);
    ithread.setFieldConnections(connects);
    ithread.setHaltOnError(new Boolean(haltOnError).booleanValue());
    ithread.setRecordsToCheck(linesToCheck);
    ithread.setProgressWriter(pw);
    ithread.setSkip(skip);

    session.setAttribute(sessionVarPrefix+"ImportThread",ithread);

    //Starts importing, stops if imported structures number reaches the limit.
    ithread.start();
    while(!ithread.isFinished()) {
        Thread.sleep(200);
	if(isLimitation) {
	    int limit = (int)pw.getProgress();
	    if(limit >= molsToImportLimit) {
		ithread.cancel(); //stops importing at a given limit	  			
	    }
	}
    }

} catch (Throwable e) {
    //In case of Exception prints the message.
    e.printStackTrace();

    %>
    <script language="javascript">
    <!--
    var w = window.open("","SQLError","resizable=no,width=300,height=200, scrollbars=no,menubar=no,location=no");
    w.document.writeln();
    w.document.writeln("<html><body bgcolor='#e0e0e0'><head>");
    
    w.document.writeln("<title>Exception</title></head>");  
    w.document.writeln("<font color='red' face='helvetica' size='+1'>Error:<br></font>");
    w.document.writeln("<font face='helvetica' size='+1'><b><%=e.getMessage()%></b></font>");
    w.document.writeln("<input type=button value=Ok onClick='window.close(); align=right'>");
    w.document.writeln("</body></html>");
    w.document.close();
    window.close();
    //-->
    </script>
    <%

} finally {    
    session.removeAttribute(sessionVarPrefix+"ImportThread");
    session.setAttribute(sessionVarPrefix+"ImportThreadFinished","true");
}

//Imported structures number.
int importedStrunctNumb = ithread.getImportedNumber();

// All Structures number 
int allStructNumb = ithread.getStructCount();

// Failured Structures number
int failedStrunctNumb = allStructNumb - importedStrunctNumb;


// If limit number is set.
String tmp = "";
if(isLimitation) tmp = "You are not allowed to import more structures.";

//In case of error during import open a window, prints the message.
if(!(ithread.getErrorMessage()==null || ithread.getErrorMessage().equals(""))) {
    if((!ithread.getErrorMessage().equals("Import cancelled."))&&(importedStrunctNumb==0)) {
	importedStrunctNumb =  allStructNumb - 1;
	failedStrunctNumb = allStructNumb - importedStrunctNumb;
    }
    %>
    <script language="javascript">
    <!--
    var isError = '<%=(ithread.getErrorMessage().equals("Import cancelled.")?"false":"true")%>';
    var w = window.open("","threadCancelled","resizable=yes,width=350,height=200, scrollbars=yes menubar=no,location=no");
    w.document.writeln();
    w.document.writeln("<html><body bgcolor='#e0e0e0'><head>");
    w.document.writeln("<title>Cancel</title></head>");  
    w.document.writeln("<form><font face='helvetica'>");
    w.document.writeln("<table width='100%'><tr><td><b>Imported</b> structures : <%=importedStrunctNumb%></td></tr>");
    w.document.writeln("<tr><td><b>Failed</b> structures : <%=failedStrunctNumb%></td></tr>");
    w.document.writeln("<tr><td align='left'><hr align='left' width='80%'></td></tr>");
    if(isError=="true") {
	w.document.writeln("<tr><td><font color='red' face='helvetica'>");
    	w.document.writeln("Error:</font></td></tr>");
        w.document.writeln("<tr><td><b><%=ithread.getErrorMessage()%></b></td></tr>");
    } else {
        w.document.writeln("<tr><td><b><%=tmp%></b></td></tr></font>");
    }
    w.document.writeln("<tr><td align='right'><input type=button value=Ok onClick='window.close();'></td></tr>");
    w.document.writeln("</table></form></body></html>");
    w.document.close();
    window.close();
    //-->
    </script>
    <%
 
} else {
//In case of succesfully import prints the imported structures number.
%>
<table width='100%'>
  <tr>
    <td>
      	<font face='helvetica'>
      	<b>Imported</b> structures: <%=importedStrunctNumb%></font>
    </td>
  </tr>
  <tr>
    <td>
	<font face='helvetica'>
      	<b>Failed</b> structures: <%=failedStrunctNumb%></font>
    </td>
  </tr>
  <tr>
    <td align='left'>
	<hr align='left' width='80%'>		
    </td>
  </tr> 
  <tr>
    <td>
	<font face='helvetica'>
      	<b>Import finished.</b></font>
    </td>
  </tr>

  <tr>
    <td align='right'>
      <input type=button value=Ok onClick='window.close();'>
    </td>
  <tr>
</table>
<%
}
//Deletes the temporary file from the server.
try {
    //first trying to delete old files:
    File f  = new File(filePath);
    File dir=f.getParentFile();
    File[] files=dir.listFiles(new FileFilter() {
        public boolean accept(File file) {
            boolean old=(System.currentTimeMillis()-file.lastModified())
                    >1000*60*60*24;
            return (file.getName().startsWith("tmp") && old);
        }
    });
    if (files!=null) {
        for (int x=0; x<files.length; x++) {
            files[x].delete();
        }
    }
    f.delete();
} catch (Exception e) {
    e.printStackTrace();
}

%>
<script language="javascript">
<!--
function resize() {
    window.resizeTo(300,200);
}
//-->
</script>
</form>
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
