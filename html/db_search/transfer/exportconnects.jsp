<%
/*
 * exportconnects.jsp
 *
 * ChemAxon Ltd., 2001
 *
 * Send export data to export.jsp. 
 */
%> 

<%@ page import="chemaxon.jchem.db.*, chemaxon.util.*, 
		java.sql.*, java.util.*" 
	errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<LINK REL ="stylesheet" TYPE="text/css" HREF="../../../jchemexample.css" TITLE="Style">
<title>Fields to export</title>
<script language="javascript">
<!--
    //resize the window on load.
    function init() {
    	window.resizeTo(400,380);
    }
//-->
</script>
</head>
<body bgcolor="#e1e1e1" onload="init();">
<form name='expConForm' method='post'>
<font face='helvetica' size=+2><b>Fields to export</b><br></font>
<%

//Get ConnectionHandler from session if possible.
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

String structureTableName = 
	    (String)session.getAttribute(sessionVarPrefix+"strTableName");

//Get posted parameters.
String type = request.getParameter("type");
String lineend = request.getParameter("lineend");
String quotation = request.getParameter("quotation");
String delim = request.getParameter("delim");
String structNeed = request.getParameter("struct");
String condText = request.getParameter("conditionText");
String toExport = request.getParameter("toExport");

String tableName = structureTableName;

// If export are not allowed from this table.

if(toExport.equals("disable")) {
    %>
    <script language='javascript'>
    <!--
    window.location.replace("exporter.jsp"+location.search);
    alert("You are not allowed to export this table.");
    //-->
    </script>
    <%
    return;
} else if(!toExport.equals("hit")) {
    tableName = toExport;
}

//Get fields of the table.
//TableInfo tableFields = TableInfo.getTableInfo(ch, null, tableName);
java.util.List tableFieldsList = DatabaseTools.getFieldNames(ch, tableName, null);
//Enumeration fieldsElements = tableFields.elements();

java.util.List startsCD_List = new ArrayList();
java.util.List notStartsCD_List = new ArrayList();


//Sort fields.
for(int i=0;i<tableFieldsList.size();i++) {
    String fieldName = (String)tableFieldsList.get(i);
    if((fieldName.toUpperCase().startsWith("CD_"))&&(!fieldName.toUpperCase().equals("CD_ID"))&&(!fieldName.toUpperCase().equals("CD_STRUCTURE"))) {
	startsCD_List.add(fieldName);
    } else if(!((fieldName.toUpperCase().equals("MOLFORMULA"))||(fieldName.toUpperCase().equals("MOLWEIGHT"))||(fieldName.toUpperCase().equals("CD_STRUCTURE"))))
        	notStartsCD_List.add(fieldName);
}


int max = Math.max(notStartsCD_List.size(),startsCD_List.size());


%>
<table width='100%'>
<%
//write the fields into the table.
for(int i=0;i<max;i++){
    out.println("<tr>");
    if(notStartsCD_List.size()>i) {
 	String fieldName = (String)notStartsCD_List.get(i);
	out.println("<td><input type='checkbox' name='field"+i+"' value='"+
		fieldName+"' checked='true'></td><td>"+
		fieldName+"</td>");
    } else {
	out.println("<td></td><td></td>");
    }
    if(startsCD_List.size()>i) {
	String fieldName = (String)startsCD_List.get(i);
	out.println("<td><input type='checkbox' name='cdfield"+i+"' value='"+
		fieldName+"'></td><td>"+
		fieldName+"</td>");
    } else {
	out.println("<td></td><td></td>");
    }
    if(i==0) out.println("<td><input type='button' value='Export' onClick='go();'></td>");
    if(i==1) out.println("<td><input type='button' value='Cancel' onClick='window.close();'></td>");
    out.println("</tr>");
}
%>
  <tr>
    <td colspan=5 align='left'>
	<input type='button' value='Export' onClick='go();'>
	<input type='button' value='Cancel' onClick='window.close();'>
    </td>
  </tr>
</table>

<!--Variables to store export parameters-->

<input type="hidden" name="type" value="<%=type%>">
<input type='hidden' name='lineend' value="<%=lineend%>">
<input type='hidden' name='conditionText' value="<%=condText%>">
<%
if(quotation!=null) {
    if(quotation.equals("'")) {
    	%>
       	<input type='hidden' name='quotation' value="<%=quotation%>">
	<%
    } else {
	%>
        <input type='hidden' name='quotation' value='<%=quotation%>'>
	<%
    }
}
%>
<input type="hidden" name="delim" value="<%=delim%>">
<input type="hidden" name="struct" value="<%=structNeed%>">
<input type="hidden" name="fields">
<input type="hidden" name="toExport" value="<%=toExport%>">

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
<script language="javascript">
<!--

//Start export with posting the form.
function go() {
    var form = document.expConForm;
    var fieldList = "";
    for(var i=0;i<<%=notStartsCD_List.size()%>;i++) {
	var fieldChecked = eval('form.field'+i+'.checked');
	var fieldValue = eval('form.field'+i+'.value');
        
	if(fieldChecked) {
		fieldList = fieldList + fieldValue + ' ';
	}
    }

    for(var i=0;i<<%=startsCD_List.size()%>;i++) {
	var fieldChecked = eval('form.cdfield'+i+'.checked');
	var fieldValue = eval('form.cdfield'+i+'.value');

	if(fieldChecked) {
		fieldList = fieldList + fieldValue + ' ';
	}
    }



    form.fields.value = fieldList.substr(0,fieldList.length-1);

    document.expConForm.action='export.jsp'+location.search;
    document.expConForm.submit();
}
//-->
</script>

