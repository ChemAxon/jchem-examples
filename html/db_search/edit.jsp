<%--

 edit.jsp

 ChemAxon Ltd., 1999-2004

 Displays a record in the structure table for editing.
 Sends the edited data to update.jsp

--%> 
<%@ page import="java.sql.*, chemaxon.util.*,
                 chemaxon.jchem.db.DatabaseProperties,
                 chemaxon.jchem.db.UpdateHandler" errorPage="errorpage.jsp" %>
<%@ include file="init.jsp" %>
<%
//response.setBufferSize(20*1024);

ConnectionHandler ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");

if((ch==null)||(!ch.isConnected())) {
    Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
    if(v == null) {
        %>
        <script LANGUAGE="JavaScript">
        <!--
        opener.location.href="expired.html";
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

Connection con = ch.getConnection();

String mode=request.getParameter("mode");
String formCell = request.getParameter("formCell");
String labelCount = request.getParameter("labelCount");

// Variables corresponding to table columns
String id="";
String molfile=null;;
String cellIndex="";

boolean isInsertion = mode.equals("insert");

// isFromViewer is true if searchresults.jsp invoked
// this script, false if the data was returned because
// of an error during updating.
boolean isFromViewer = (request.getParameter("fvalues")==null);

String structureTableName = 
	    (String)session.getAttribute(sessionVarPrefix+"strTableName");

DatabaseProperties dbProp=new DatabaseProperties(ch);

java.util.List<String> typeList = new ArrayList<String>();
java.util.List<String> fieldList = DatabaseTools.getFieldNames(ch, structureTableName,
        typeList);
int[] sqlTypes=DatabaseTools.getFieldTypes(ch, structureTableName);
java.util.List fieldTexts=new ArrayList(); //String objects, the displayed names of fields
java.util.List fieldNames=new ArrayList(); //String objects, the DB names of fields
java.util.List fieldTypes=new ArrayList(); //Integer objects
String queryConditions = 
        props.getProperty(structureTableName+".queryConditions");
if(queryConditions == null) {
    queryConditions = props.getProperty("default.queryConditions");
}
for(int i=0;i<fieldList.size();i++) {
    boolean showField = true;
    String field = (String)fieldList.get(i);
    int type=sqlTypes[i];
    String text = field;
    if(queryConditions!=null) {
        StringTokenizer str = new StringTokenizer(queryConditions,";");
        while(str.hasMoreElements()) {
            String sf = str.nextToken();
            if(sf.toLowerCase().startsWith(field.toLowerCase())) {
                int index = sf.indexOf("#");
                if(index > -1) {
                    text = sf.substring(index + 1);
                    sf = sf.substring(0, index);
                }
            }
        }
    } 
    //generated fields cannot be modified:
    if (field.toLowerCase().startsWith("cd_")) { 
        showField=false;
    }
    String ctProperty = dbProp.getProperty("table."+structureTableName+".chemTermColumn."+field.toUpperCase());
    if (ctProperty != null){
	showField=false;
    }
    boolean isText=DatabaseTools.isTextType(type);
    boolean isInteger=DatabaseTools.isIntType(type);
    boolean isReal=DatabaseTools.isRealType(type);
    if (!isText && !isInteger && !isReal) {
        showField=false;
    }
    if(showField) { //adding it to the query list
        fieldNames.add(field);
        fieldTexts.add(text);
        fieldTypes.add(new Integer(type));
    }
}
%>

<html>
<head>
<title>Edit</title>

<script LANGUAGE="JavaScript">
<!--
/*
 * Defining marvin's repository for different browsers
 */

var contentLoaded=false;
var isInsertion;        // true if the data will be inserted
                        // false if it will be used for 
                        // modification

/* 
 * Submits the filled form to update.jsp
 */
function update()
{
    var form=document.forms[0];
    if(!contentLoaded) {
	alert("Page loading. Please wait.");
	return;
    }
    
    form.molfile.value=document["msketch"].getMol("mrv");

    form.action="update.jsp"+location.search;
    if(checkForm()) {
        form.submit();
    }    
}

/*
 * Checking if query conditions are valid
 */
function checkForm() {
    var form=document.forms[0];
<%
for (int x=0; x<fieldTypes.size(); x++) {
    int type=((Integer)fieldTypes.get(x)).intValue();
    String name=((String)fieldNames.get(x)).toLowerCase();
    if (DatabaseTools.isIntType(type) || name.equals("cd_id")){%>
        var value=form.field<%=x%>.value;
        if(value != null && value != "") {
            if(isNaN(value) || value.indexOf('.')>=0) {
                alert("'" + value + "' is not a valid integer value");
                return false;
            }
        }<%
    } else if (DatabaseTools.isRealType(type)){%>
        var value=form.field<%=x%>.value;
        if(value != null && value != "") {
            if(isNaN(value)) {
                alert("'" + value + "' is not a valid floating point value");
                return false;
            }
        }<% 
    }
}%>
    return true;
}



// -->
</script>

</head>

<body bgcolor="#e1e1e1" onLoad = 'init()'>

<%

java.util.List fieldValues=new ArrayList();

if(!isFromViewer || !isInsertion) {
    if(isFromViewer) {
        /*
         * Retrieving the data to be displayed
         * from the database
         */
     	cellIndex = request.getParameter("cellIndex");
        id = request.getParameter("id");
        String sql =
                "SELECT * FROM "+ structureTableName +
                " WHERE " +
                structureTableName + ".cd_id = " + id;		
        Statement stmt=null;
        try{
	    stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(sql);        
            if(rs.next()) {
                molfile = new String(DatabaseTools.readBytes(rs, "cd_structure"),"ASCII");
		for(int i=0;i<fieldNames.size();i++) {
		    Object value = 
				rs.getObject((String)fieldNames.get(i));
		    fieldValues.add(value == null? "" : value);
		}
            } else {
                %>
                <script LANGUAGE="JavaScript">
                <!--
                alert("Compound " + <%= id %> + " not found");
                // -->
                </script>
                <%
            }
	    stmt.close();
        } finally {
            try {
		if(stmt!=null) {
            	    stmt.close();
	 	}
	    } catch(Exception e) {}
        }
    } else {
        /*
         * If the data was returned because of an error, 
         * then retrieving data from the hidden input 
         * variables of the form in update.jsp.
         */
        id = request.getParameter("id");
        molfile = request.getParameter("molfile");
	formCell = request.getParameter("formCell");
	labelCount = request.getParameter("labelCount");
	StringTokenizer sv = 
		    new StringTokenizer(request.getParameter("fvalues"), ",");
	while(sv.hasMoreTokens()) {
	    fieldValues.add(sv.nextToken());
	}
    }
}
%>

<script LANGUAGE="JavaScript">
<!--
/*
 * Initializing the components of the form
 */
function init()
{
    var form=document.forms[0];
    form.cellIndex.value= "<%= cellIndex %>"
    form.mode.value = "<%= mode %>";
    form.formCell.value = "<%= formCell %>";
    form.labelCount.value = "<%= labelCount %>";
    form.id.value = "<%= id %>";
    var fields = "";
    <%
    for(int i=0;i<fieldNames.size();i++) {
        if(fieldValues.size() > i) {
	    %>
	    form.field<%=i%>.value = '<%=fieldValues.get(i)%>';
	    <%
	}%>
	fields += '<%=fieldNames.get(i)%>,';
	<%
    }%>
    form.fields.value = fields.substr(0, fields.length - 1);
    contentLoaded = true;
}
// -->
</script>


<p><font face="helvetica" size=+1>

<script LANGUAGE="JavaScript">
<!--
isInsertion = <%= isInsertion %>;
if(isInsertion) {
    document.writeln("Inserting new compound");
} else {
    document.writeln("Editing compound <%= id %>");
}
// -->
</script>

</font></p>
<form method="post">
<input type="hidden" name="molfile">
<input type="hidden" name="id">
<input type="hidden" name="mode">
<input type="hidden" name="formCell">
<input type="hidden" name="cellIndex">
<input type="hidden" name="fields">
<input type="hidden" name="labelCount">

<table border=0 cellpadding=2 cellspacing=2>

<tr>
<td valign=top>
<table>
<tr>
<td>
<script LANGUAGE="JavaScript">
<!--
if(isInsertion) {
    document.writeln(
        '<input type="button" value="Insert" onClick="update()">');
} else {
    document.writeln(
        '<input type="button" value="Update" onClick="update()">');
}
// -->
</script>
&nbsp;
<input type="button" value="Cancel" onClick="window.close()">
</td>
</tr>
<tr>
<td>
<%
    int tableType=dbProp.getTableType(structureTableName);
    boolean queryTable = tableType == UpdateHandler.TABLE_TYPE_QUERY_STRUCTURES;
    //todo: no duplicate filtering for query tables until DUPLICATE search can handle queries:
%>
<input type="hidden" name="queryTable" value="<%=queryTable%>" >
</td>
</tr>
</table>
</td>

<td>
<script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
<script LANGUAGE="JavaScript1.1">
<!--
msketch_name="msketch";
msketch_begin("../../marvin", 440, 380);
<%
if(molfile!=null) {
    molfile=HTMLTools.convertForJavaScript(molfile);
    %>
    msketch_param("mol","<%= molfile %>");
<%
}
%>
msketch_param("preload", "MolExport");
msketch_param("bgcolor", "#b0b0b0");
msketch_param("molbg", "#F0F0F0");
<%
//only non-query extra bonds are allowed for non-query tables:    
if (!queryTable) {
%>
msketch_param("extrabonds", "arom,wedge");
<%
}
%>
msketch_param("undo", "50");
msketch_end();
//-->
</script>
</td>
</tr>

<%
for(int i=0;i<fieldNames.size();i++) {
    %>
    <tr>
	<td valign="top" align="right"><%=fieldTexts.get(i)%></td>
	<td><input type="text" name="field<%=(i)%>" size="60">
	</td>
    </tr>
    <%
}
%>

<tr>
<td valign=top colspan=2 height=10>
</td>
</tr>
</table>
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
