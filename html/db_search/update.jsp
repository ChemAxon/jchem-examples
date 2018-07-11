<%--

 update.jsp

 ChemAxon Ltd., 1999-2011

 Updates a record in the structure table.

--%> 
<%@ page import="
java.sql.*,
java.text.DecimalFormat,
chemaxon.jchem.db.*,
chemaxon.util.*"
%>
<%@ include file="init.jsp" %>
<%
//response.setBufferSize(20*1024);

//Reading input parameters from form
String mode=request.getParameter("mode");
String molfile = request.getParameter("molfile");
String fields = request.getParameter("fields"); 
String idString = request.getParameter("id");
String cellIndex = request.getParameter("cellIndex");
String formCell = request.getParameter("formCell");
String labelCountString = request.getParameter("labelCount");
boolean queryTable = request.getParameter("queryTable") != null;
    
int labelCount = 0;
if(labelCountString != null) {
    if(!labelCountString.equals("")) {
	labelCount = Integer.parseInt(labelCountString);
    }
}

Vector fieldNames = null;
if(fields != null) {
    fieldNames = new Vector();
    StringTokenizer st = new StringTokenizer(fields,",");
    while(st.hasMoreTokens()) {
	String f = st.nextToken();
	fieldNames.addElement(f);
    }
}

Vector fieldValues = null;
if(fieldNames != null) {
    fieldValues = new Vector();
    for(int i=0;i<fieldNames.size();i++) {	
	fieldValues.addElement(request.getParameter("field"+i));
    }
}

%>
<html>
<head>
<title>Update</title>
<!--script LANGUAGE="JavaScript1.1" SRC="update.js"></script-->
<script LANGUAGE="JavaScript">
<!--
/*
 * Modify the MView applet containing the updated
 * molecule.
 */
function modifyMView(window, cellIndex, molweight, molformula, molfile, newFields)
{
	var mview=window.document.mview;
	var cells=mview.getCellCount();
	var labelCountInACell=parseInt("<%=labelCount%>");
	<%
    	if(fieldNames != null) {    
	    int lIndex = labelCount - fieldNames.size();
	    if(formCell.startsWith("default")) {
		%>
		mview.setL(parseInt(cellIndex*labelCountInACell+2), 
							    'MW: '+molweight);
		mview.setL(parseInt(cellIndex*labelCountInACell+1), molformula);
		<%
	    }
	    if(formCell.equals("defaultall")) {
		for(int i=0;i<fieldNames.size();i++) {
		    String pre = (String)fieldNames.get(i);
		    if(pre.length() > 5) {
			pre = pre.substring(0, 5);
		    }
		    %>
		    mview.setL(
			    parseInt(cellIndex*labelCountInACell+<%=lIndex+i%>),
			    '<%=pre+": "+fieldValues.elementAt(i)%>');
		    <%
		}
	    } else if(!formCell.equals("defaultnull")) {
		int i = 0;
		StringTokenizer st = new StringTokenizer(formCell, ";");
		while(st.hasMoreTokens()) {
		    String field = st.nextToken();		
		    int start = field.indexOf("<");
		    int end = field.indexOf(">");
		    int def = field.indexOf("#");
		    String pre = field.substring(0, start);
		    String fieldName = 
			    field.substring(start + 1, end).toLowerCase();
		    String post = field.substring(end + 1);
		    String defaultv = "";
		    if(def > -1) {
			post = field.substring(end + 1, def);
			defaultv = field.substring(def + 1);
		    }
		    if(fieldName.equals("$cd_structure")) {
			i--;
		    } else if(fieldName.equals("cd_formula")) {
			%>
			mview.setL(parseInt(cellIndex*labelCountInACell+<%=i%>),
				molformula);
			<%
		    } else if(fieldName.equals("cd_molweight")) {
			%>
			mview.setL(parseInt(cellIndex*labelCountInACell+<%=i%>),
				molweight);		
			<%
		    } else {
			for(int j=0;j<fieldNames.size();j++) {
			    String f = 
				((String)fieldNames.elementAt(j)).toLowerCase();
			    if(fieldName.equals(f)) {			
				String newValue;
				if(fieldValues.elementAt(j) == null) {
				    newValue = defaultv;
				} else {
				    if(fieldValues.elementAt(j).equals("")) {
					newValue = defaultv;
				    } else {
					newValue = pre + 
					    fieldValues.elementAt(j) + post;
				    }
				}		    
				%>
				mview.setL(parseInt(
					    cellIndex*labelCountInACell+<%=i%>),
					   '<%=newValue%>');
				<%
			    }
			}
		    }
		    i++;
		}
	    }
	    %>
	    mview.setM(cellIndex, molfile);
	    <%
	} else {
	    %>
	    for(var i=0;i<labelCountInACell;i++) {
		var startL = labelCountInACell*cellIndex;
		if(i == 0) mview.setL(startL,'DELETED');
		else mview.setL(startL+i,'');
	    }
	    mview.setM(cellIndex,'');
	    <%
    
	}%>
}

//-->
</script>
</head>

<body bgcolor="#e0e0e0">
<%

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

String structureTableName =
        (String)session.getAttribute(sessionVarPrefix+"strTableName");
boolean isInsertion = mode.equals("insert");
int cd_id = 0;
if(!isInsertion) {
    cd_id = Integer.parseInt(idString);
}            

try { 
    if(mode.equals("delete")) {
	if(idString!=null) {
            UpdateHandler.deleteRow(ch, structureTableName, cd_id);
        %>
            <script LANGUAGE="JavaScript1.1">
            <!--
            // Modification of the Marvin View table
            modifyMView(opener.frames[1],<%= cellIndex %>,"","","",false);
            //-->
            </script>
            <%
	}
	%>
	<script LANGUAGE="JavaScript">
	<!--
        window.close();
	//-->
	</script>
	<%
	return;
    }
 

    
    // Updating the structure table    
    UpdateHandler uh = new UpdateHandler(ch,
	    (isInsertion? 
		UpdateHandler.INSERT :
		UpdateHandler.UPDATE),
	    structureTableName, fields);
    try {
	
        uh.setStructure(molfile);
	if(!isInsertion) {
	    uh.setID(cd_id);
	}
	for(int i=0;i<fieldNames.size();i++) {	
	    uh.setValueForAdditionalColumn(i + 1, fieldValues.elementAt(i));
	}

	int insertedId=uh.execute(true);
        if (insertedId<0) {
            insertedId=-insertedId;
            throw new Exception("Structure already exists (cd_id=" 
                    + insertedId + ")");    
        }
	if(!isInsertion) {
	    MolHandler mh = new MolHandler(molfile);
	    mh.addHydrogens();
	    float molWeight = mh.calcMolWeight();
	    String formula = mh.calcMolFormula();
	    %>
	    <script LANGUAGE="JavaScript">
	    <!--
	    // Modification of the Marvin View table
	    modifyMView(opener.frames[1],<%= cellIndex %>, 
			"<%=molWeight%>", "<%=formula%>", 
			"<%= HTMLTools.convertForJavaScript(molfile) %>",true);
	    //-->
	    </script>
	    <%
	}
    } finally {
	uh.close();
    }
    %>
    <font face="helvetica" size="+2">Record was 
    <%= isInsertion? "inserted" : "updated"%>.</font>
    <script LANGUAGE="JavaScript">
    <!--
    window.close();
    //-->
    </script>
    <%
} catch(Exception e) {
    /* 
     * In case of error, the script displays the error message(s)
     * and returns.
     */
    e.printStackTrace();
    if(e.getMessage()!=null) {
	try {
	    %><%= HTMLTools.exceptionToString(e) %><%
	} catch(Exception nf) {
	    %>Error: JChem repository not found<%
	}
    }
    if(mode.equals("delete"))
	return;
    %>
    <p>
    <form method="post" name="dataForm">
    <input type=hidden name=mode value="<%= mode %>">
    <input type=hidden name=id value="<%= idString %>">
    <input type=hidden name=molfile>
    <input type=hidden name=fields value="<%= fields %>">
    <input type=hidden name=labelCount value="<%= labelCount %>">
    <input type=hidden name=formCell value="<%= formCell %>">
    <input type=hidden name=fvalues value="<%
    for(int i=0;i<fieldNames.size();i++) {
    String value = request.getParameter("field"+i);
    if(value == null) {
	value = " ";
    }
	out.print((value.equals("")? " " : value)+",");
    }
    %>">
    <input type=hidden name=cellIndex value="<%= cellIndex %>">
    <input type=submit value="    Ok    ">
    </form>
    <script language="JavaScript">
    <!--
        var form=document.dataForm;
        form.molfile.value="<%= HTMLTools.convertForJavaScript(molfile) %>";
        form.action = "edit.jsp" + location.search;
    // -->
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