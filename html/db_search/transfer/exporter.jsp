<%--

 exporter.jsp

 ChemAxon Ltd., 2001

 Send export data to export.jsp. 
/
--%> 

<%@ page import="chemaxon.jchem.db.DatabaseProperties" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<LINK REL ="stylesheet" TYPE="text/css" HREF="../../../jchemexample.css" TITLE="Style">
<title>Export</title>
</head>
<body bgcolor="#e1e1e1" onload="init()">
<script language="JavaScript">
<!--
opener.document.childOpened="true";  //For pop-up window check
-->
</script>
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

%>
<form name="exportForm" method="post" >
<table width='100%'>
  <tr>
    <td colspan=2><input type='radio' name='whatToExport' checked="true" value='hit' onClick='exportTypeChanged()'> Export the hits of this query.<br>
	  	  <input type='radio' name='whatToExport' onClick='exportTypeChanged()'> Export from a selected table.
	 	  <select name='exportTable'>
		    <% 
		    Vector tables = 
			(new DatabaseProperties(ch)).getStructureTableNames();
		    for(int i=0;i<tables.size();i++) {
			String value = (String)tables.elementAt(i);
			String name = value.substring(value.indexOf(".") + 1);
			out.println("<option value='"+value+"'>"+name+"</option>");
		    }
	    	    %>
	    	  </select></ul></td>
  </tr>
  <tr>
    <td>
      Select type:
    </td>
    <td>
	<!-- Select object to choose filetype-->
    <select name="type">
		<option value="1">MOLFILE</option>
		<option value="2" selected='true'>SDFILE</option>
		<option value="3"> SMILES</option>
		<option value="5">RDF</option>
		<option value="6">Marvin document</option>
    </Select>
    </td>
  </tr>
  <tr>
    <td colspan=2 align='left'>
	Condition in SELECT command:<br>
	(e.g. WHERE cd_id<1000)
    </td>
  </tr>
  <tr>
    <td colspan=2 align='right'>
	<input type='text' name='condText' size='40'>
    </td>
  </tr>
  <tr>
    <td colspan=2 align=right>
	<input type="button" value="Next" onClick="doexport();" >
	<input type="button" value="Cancel" onClick="window.close();">
    </td>
  </tr>
</table>

<!-- Hidden variables to store posted values. -->
<input type="hidden" name="type" value="">
<input type="hidden" name="conditionText" value="">
<input type="hidden" name="toExport" value="">

</form>
<script language="javascript">
<!--
//Set the select objects.
function init() {

    var agt = navigator.userAgent.toLowerCase();
    
    exportTypeChanged();
}

//Enable or disable table select object, when radio bottoms checked.
function exportTypeChanged() {
    if(document.exportForm.whatToExport[0].checked) {
	document.exportForm.exportTable.disabled=true;
    } else {
	document.exportForm.exportTable.disabled=false;
    }

}

//Set parameters and submit the form.
function doexport() {

    document.exportForm.conditionText.value = document.exportForm.condText.value;

    if(document.exportForm.whatToExport[0].checked) {
	document.exportForm.toExport.value = document.exportForm.whatToExport[0].value;
    } else {
	var index = document.exportForm.exportTable.selectedIndex;
	document.exportForm.toExport.value = document.exportForm.exportTable[index].value;
    }
    if(document.exportForm.type.value==1            //MOLFILE
            ||document.exportForm.type.value==3     //SMILES
            ||document.exportForm.type.value==5)    //RDFILE
	document.exportForm.action='export.jsp'+location.search;
    else
	document.exportForm.action='exportconnects.jsp'+location.search;

    document.exportForm.submit();
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

