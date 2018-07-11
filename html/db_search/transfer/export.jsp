<%
/*
 * export.jsp
 *
 * ChemAxon Ltd., 2001
 *
 * Export structures to SDFile.
 */
%> 

<%@ page import="chemaxon.jchem.db.*, chemaxon.util.*, java.sql.*, java.util.*, java.lang.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<html>
<head>
<title>Export</title>
</head>
<body>
<%
//Get the searcher from the session.
JChemSearch searcher = (JChemSearch)session.getAttribute(
	    sessionVarPrefix+"search.searcher");

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

//Get posted values.
String type = (String)request.getParameter("type"); 
String fieldNames = (String)request.getParameter("fields");
String condText = (String)request.getParameter("conditionText");
String toExport = (String)request.getParameter("toExport");

//If this table is not allowed to export from.
if(toExport.equals("disable")) {
    %>
    <script language='javascript'>
    <!--
    window.location.replace("exporter.jsp"+location.search);
    alert("You are not allowed to export from this table.");
    //-->
    </script>
    <%
    return;
}

/*Set the contenttype to application/zip to the browser can download
 the outputstream. */ 

//response.setContentType("application/octet-stream");
//setting an unknown type, otherwise IE tries to disaply an XML for MRV:        
response.setContentType("asdfasdfasdf/asdfasdfasdf");

/* Set the header to name.ext where name contains the name of tableset
 and the expression, the ext depends on the type of the file to export. */

String extension = "sdf";
if(type.equals("1")) {
    extension = "mol";
} else if(type.equals("3")) {
    extension = "smiles";
} else if(type.equals("5")) {
    extension = "rdf";
} else if(type.equals("6")) {
    extension = "mrv";
}
response.setHeader("Content-Disposition","inline; filename=exportMols."+extension);

String structureTableName = 
	    (String)session.getAttribute(sessionVarPrefix+"strTableName");

//SQL condition to Exporter.
int[] idList = null;

if(toExport.equals("hit")) {
    idList=searcher.getResults();
}


int molNumber = 0;

Exporter exp = new Exporter();
exp.setConnectionHandler(ch);
exp.setTableName((toExport.equals("hit") ? structureTableName : toExport));
exp.setFieldList(fieldNames);
exp.setConditions(condText);
exp.setIDList(idList);        
OutputStream outs = response.getOutputStream();
exp.setOutputStream(outs);
exp.setFormat(Integer.parseInt(type.trim()));
exp.setDefaults(true);

//Start exporting.
try {
    molNumber = exp.writeAll();
} catch(Exception ex) {
    outs.write((new String(ex.getMessage())).getBytes());
} finally {
    outs.flush();
    outs.close();
}

session.setAttribute(sessionVarPrefix+"molNumber",Integer.toString(molNumber));
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
