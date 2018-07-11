<%--

  importsetcons.jsp
 
  ChemAxon Ltd., 2002
 
  Connects fields from structure files with columns in structure tables at import.
 
--%> 
<%@ page import="chemaxon.jchem.file.*,java.util.zip.*,java.util.*,java.io.*,chemaxon.jchem.db.*,chemaxon.util.*, java.sql.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Import set connects</title>
</head>
<body bgcolor="#e1e1e1">
<form name="connectsForm" method="post">
<%
//If possible get the ConnectionHandler from the session 

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

//Get posted parameters.
String tableName = request.getParameter("tableName");
String path = request.getParameter("filePath");
String lineCh = request.getParameter("lineCheck");
String skip = request.getParameter("skip");
String fileOldName = request.getParameter("fileOldName");
String haltOnError = request.getParameter("haltOnError");

int format=FileInfo.getFormat(fileOldName);
java.util.List<String> fileFieldNames = null;
boolean showConnectDialog=false;
if (format==FileInfo.SDFILE || format==FileInfo.RDFILE
        || format==FileInfo.SMILES){
    //Set linecheck parameter.
    int lineCheck = 0;
    try {
    	lineCheck = Integer.parseInt(lineCh);
    } catch (NumberFormatException e) {}

    //Get fields name from file.
    //FileInfo fileInfo = null;
    try {
    	FileInputStream inFile = new FileInputStream(path); 	
    	//fileInfo = ImportFileHandler.collectFileInfo(inFile, pw, lineCheck);
  	fileFieldNames = Importer.getFieldNameList(inFile, lineCheck);
    } finally {}
    if (fileFieldNames!=null && fileFieldNames.size()>0) {
        showConnectDialog=true;
    }
}

if (showConnectDialog) {
    //Gets fields names from the table.
    java.util.List<String> typeList = new ArrayList<String>();
    java.util.List<String> fieldList = DatabaseTools.getFieldNames(ch,
						 tableName, typeList);
    java.util.List tableFieldsList = new ArrayList();
    for(int i=0;i<fieldList.size();i++) {
	String[] field = new String[2];
 	field[0] = (String)fieldList.get(i);
	field[1] = (String)typeList.get(i);
	tableFieldsList.add(field);
    }

    java.util.List sortedList = new ArrayList();

    //Sort the table fields.
    for(int i=0;i<tableFieldsList.size();i++) {
    	String[] field = (String[])tableFieldsList.get(i);
    	if(!field[0].toUpperCase().startsWith("CD_")) sortedList.add(field);
    }

    for(int i=0;i<tableFieldsList.size();i++) {
    	String[] field = (String[])tableFieldsList.get(i);
    	if(field[0].toUpperCase().startsWith("CD_")) sortedList.add(field);
    }

    int selectFieldsCount = 0;

    session.removeAttribute(sessionVarPrefix+"ImportThreadFinished");
    %>
    <!-- Display fields -->
    <table width="100%" cellspacing='10'>
      <tr>	
	<td><font size=+2 face="helvetica">Field in table</td>
	<td><font size=+2 face="helvetica">Field type</td>
	<td><font size=+2 face="helvetica">Field in file</font></td>
	<td><input type="button" value=" OK " onClick="startImport();"></td>    
      </tr><tr>
	<td colspan=3><hr width='100%' size='1'></td>
	<td><input type="button" value="Cancel" onClick="cancel();"></td>
      </tr>
      <%
    for(int j=0;j<sortedList.size();j++) {
	String[] field = (String[])sortedList.get(j);
	out.println("<tr><td>"+field[0].toUpperCase()+"</td><td>"+
		field[1]+"</td>");
	if(field[0].toUpperCase().equals("CD_ID")) {
	    out.println("<td><select name='Sel"+selectFieldsCount+"'>"+
		"<option value='CD_ID'> [Auto incrementing]</option>");
	    for(int i=0;i<fileFieldNames.size();i++)
		out.println("<option value='CD_ID'>"+
			fileFieldNames.get(i)+"</option>");
	    out.println("</select></td></tr>");
	    selectFieldsCount++;
	} else if(field[0].toUpperCase().startsWith("CD_FP"))
	    out.println("<td>[Fingerprint]</td></tr>");
	else if(field[0].toUpperCase().startsWith("CD_"))
	    out.println("<td>["+field[0].toUpperCase().substring(3)+"]</td></tr>");
	else {
	    out.println("<td><select name='Sel"+selectFieldsCount+
		"'>"+"<option value='"+field[0].toUpperCase()+
		"'>[Not connected]</option>");
	    for(int i=0;i<fileFieldNames.size();i++)
		out.println("<option value='"+field[0]+"'"+
		    ((((String)fileFieldNames.get(i)).toUpperCase().equals(field[0].toUpperCase()))?"selected":"")
		+">"+fileFieldNames.get(i)+"</option>");
	    out.println("</select></td></tr>");
	    selectFieldsCount++;
	} 
    }
    %>
    <tr>
      <td>
        <input type="button" value=" OK " onClick="startImport();">
      </td>
      <td>
 	<input type="button" value="Cancel" onClick="cancel();">
      </td>
    </tr>
    </table>

    <!--Hidden variables contains import parameters-->

    <input type="hidden" name="tableName">
    <input type="hidden" name="filePath">
    <input type="hidden" name="connects">
    <input type="hidden" name="skip">
    <input type="hidden" name="fileOldName">
    <input type='hidden' name='haltOnError'>
    <input type='hidden' name='lineCheck' value='<%=lineCh%>'>
    </form>
    <script language="javascript">
    <!--

    function cancel() {
    	var w = window.open("","threadcancel"+location.search,"resizable=no,width=300,height=150, scrollbars=no,menubar=no,location=no");
    	w.document.writeln("<html><body bgcolor='#e1e1e1'><head>");
    	w.document.writeln("<title>Cancel import</title></head>");  
    	w.document.writeln("<form name='cancelForm' method='post' action='threadcancel.jsp'>");
    	w.document.writeln("<font face='helvetica' size='+1' color='red'>");
    	w.document.writeln("Please wait... Page loading.</font>");
    	w.document.writeln("<input type='hidden' name='cancelFromCon'>");
    	w.document.writeln("</body></html>");
    	w.document.close();
    	w.document.forms[0].cancelFromCon='true';
    	w.document.forms[0].submit();
    	window.close();
    }

    // Sets parameters, submits the form to import.jsp, starts import.
    // Opens a progress window for monitoring the import progress.

    function startImport() {
    	var form = document.connectsForm;

    	var con = new String("");
    	for(var i=0;i<<%=selectFieldsCount%>;i++) {
	    var index = 'form.Sel'+i+'.selectedIndex';
	    var fieldName = 'form.Sel'+i+'.options['+eval(index)+'].value';
	    var fileFieldName = 'form.Sel'+i+'.options['+eval(index)+'].text';
  	    if((eval(fileFieldName)!='[Auto incrementing]')&&(eval(fileFieldName)!='[Not connected]'))
	    con = con + eval(fieldName) + '=' + eval(fileFieldName) + ';';
        }
        if(con.length>0) con = con.substr(0,con.length-1);
        form.tableName.value = "<%=tableName%>";
    	form.filePath.value = "<%=HTMLTools.convertForJavaScript(path)%>";
    	form.connects.value = con;
    	form.skip.value = "<%=skip%>";
    	form.fileOldName.value = "<%=fileOldName%>";
    	form.haltOnError.value = "<%=haltOnError%>";
    	var w = window.open("importprogress.jsp"+location.search,"progress","resizable=no,width=300,height=150, scrollbars=no,menubar=no,location=no,dependent=yes");
        form.action="import.jsp"+location.search;
      	form.submit();
    }
    //-->
    </script>
    <%
} else {
    %>

    <input type="hidden" name="tableName">
    <input type="hidden" name="filePath">
    <input type="hidden" name="connects">
    <input type="hidden" name="skip">
    <input type="hidden" name="fileOldName">
    <input type='hidden' name='haltOnError'>
    <input type='hidden' name='lineCheck' value='<%=lineCh%>'>
    </form>

    <script language="javascript">
    <!--

    // Submits the form to import.jsp, starts import.
    // Opens a progress window for monitoring the import progress.

    var form = document.connectsForm;

    form.tableName.value = "<%=tableName%>";
    form.filePath.value = "<%=HTMLTools.convertForJavaScript(path)%>";
    form.connects.value = '';
    form.skip.value = "<%=skip%>";
    form.fileOldName.value = "<%=fileOldName%>";
    form.haltOnError.value = "<%=haltOnError%>";
    var w = window.open("importprogress.jsp"+location.search,"progress","resizable=no,width=300,height=150, scrollbars=no,menubar=no,location=no,dependent=yes");
    form.action="import.jsp"+location.search;
    form.submit();
    //-->
    </script>

    <%
}
%>
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

