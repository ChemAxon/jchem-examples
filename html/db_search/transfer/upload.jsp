<%--

 upload.jsp
 
 ChemAxon Ltd., 2001
 
 Upload the selected file and save it on the server with a 
 random generated name.
 The file posted by a HTML form (uploader.jsp). 
--%> 

<%@ page import="chemaxon.jchem.db.*,chemaxon.util.*,chemaxon.jchem.file.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Import</title>
</head>
<body bgcolor="#e1e1e1">
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-453558-10', 'auto');
  ga('send', 'pageview');

</script>
<%

int rnd = (new java.util.Random()).nextInt();
rnd = rnd<0 ? -rnd : rnd;
String tmpFileName = "tmp" + rnd;

//The file will be saved in the $HOME/chemaxon/temp directory with the generated name.
String tmpDir=chemDir+fileSep+"temp";
String path = tmpDir+fileSep+tmpFileName;

//Creating temp directory if not exists
File dir = new File(tmpDir);
dir.mkdir();

//New thread to reads the inputstream of the request and saves the file.
UploadThread uh = new UploadThread();

uh.setParams(request.getContentType(), request.getContentLength(),
 	request.getInputStream(), tmpDir, tmpFileName);

session.setAttribute(sessionVarPrefix+"tmpFile",tmpDir+fileSep+tmpFileName);
session.setAttribute(sessionVarPrefix+"UploadThread",uh);

//Starts the thread, wait until finished.
uh.start();

while(!uh.isFinished()) {
    Thread.sleep(200);
}


session.removeAttribute(sessionVarPrefix+"UploadThread");
session.setAttribute(sessionVarPrefix+"UploadThreadFinished","true");

if(uh.getPercent() != 100) {
    %>
    <script language="javascript">
    <!--
        window.close();
    //-->
    </script>
    </html>
    <%
} else {
    //Gets the original name of the file
    String oldFileName = uh.getDefaultFileName();

    //If the file is not correct opens an error window.

    if(uh.getFileSize() == 0) {
        session.removeAttribute(sessionVarPrefix+"UploadThreadFinished");
    	%>
    	</body>
    	</html>
    	<script language="javascript">
    	<!--
            alert("The <%=oldFileName%> file doesn't exist or its size equals zero.")
    	    window.close();
    	//-->
    	</script>
    	<%
    } else {
    	//Gets posted parameters.
    	String tableName = uh.getParameter("tableName");
    	String lineCheck = uh.getParameter("lineCheck");
    	String skip = uh.getParameter("skip");
    	String haltOnError = uh.getParameter("haltOnError");
    	%>
    	</body>
    	</html>
    	<script language="javascript">
    	<!--
    	//Opens a new window for setting field connections.    
    	//window.close();
    	var w;
        <%
        int format=FileInfo.getFormat(oldFileName);
        if (format!=FileInfo.SDFILE && format!=FileInfo.RDFILE) { %>
	    w = window.open("","import","resizable=yes,width=300,height=150,scrollbars=yes,menubar=no,location=false");
    	    w.document.writeln("<html><body bgcolor='#e1e1e1'>");
	    w.document.writeln("<font size=+2 face=helvetica>");
            w.document.writeln("<form method=post action='importconnects.jsp"+location.search+"'>");
	    w.document.writeln("Importing ... Please wait.");
    	<%} else {%>
	    w = window.open("","setconnects","resizable=yes,width=600,height=500,scrollbars=yes,menubar=no,location=false");
    	    w.document.writeln("<html><body bgcolor='#e1e1e1'>");
	    w.document.writeln("<font size=+2 face=helvetica>");
            w.document.writeln("<form method=post action='importconnects.jsp"+location.search+"'>");
	    w.document.writeln("Page loading ... Please wait.");
    	<%}%>
    	w.document.writeln("<input type=hidden name='filePath'>");
    	w.document.writeln("<input type=hidden name='tableName'>");
    	w.document.writeln("<input type=hidden name='lineCheck'>");
    	w.document.writeln("<input type=hidden name='fileOldName'>");
    	w.document.writeln("<input type=hidden name='skip'>");
    	w.document.writeln("<input type=hidden name='haltOnError'>");
    	w.document.writeln("</form>");
    	w.document.writeln("</font></body></html>");
    	w.document.close();
    	var form=w.document.forms[0];

    	form.filePath.value="<%=HTMLTools.convertForJavaScript(path)%>";
    	form.tableName.value="<%=tableName%>";
    	form.lineCheck.value = "<%=lineCheck%>";
    	form.skip.value = "<%=skip%>";
    	form.fileOldName.value ="<%=oldFileName%>";
    	form.haltOnError.value = '<%=haltOnError%>';
    	form.submit();

    	window.close();
    	//-->
    	</script>
    	<%
    }
}
%>
