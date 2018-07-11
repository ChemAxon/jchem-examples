<%--

 seltable.jsp

 ChemAxon Ltd., 1999-2004

 Check login parameters, login, select structure table and form

--%> 
<%@ page import="chemaxon.jchem.db.DatabaseProperties" errorPage="errorpage.jsp" %>
<%@ include file="init.jsp" %>
<html>
<%    
ConnectionHandler ch;
    /*
     * Login
     */
if(request.getParameter("dbname") != null) {
    String username = request.getParameter("dbname");
    String password = request.getParameter("dbpasswd");
    String driver = request.getParameter("dbdrv");
    String url = request.getParameter("dburl");
    String propertyTableName = request.getParameter("propTable");
   
    Vector v = new Vector();
    v.addElement(username);
    v.addElement(password);
    v.addElement(driver);
    v.addElement(url);
    v.addElement(propertyTableName);

    session.setAttribute(sessionVarPrefix+"loginDetails",v);

    //In case of a new login
    ch = new ConnectionHandler();
    ch.setDriver(driver);
    ch.setUrl(url);
    ch.setLoginName(username);
    ch.setPassword(password);
    ch.setPropertyTable(propertyTableName);

    //Try connecting to database, if error occures going back to index.jsp 
    //and showing the error message.
    try {
        ch.connectToDatabase();
    } catch (Exception e) { 
        session.setAttribute(sessionVarPrefix+"error",e.getMessage());
        %><jsp:forward page="index.jsp" /><%
    }
} else {
    ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");
    if((ch==null) || (!ch.isConnected())) {
	Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
	if(v == null) {
	    %>
            <script LANGUAGE="JavaScript">
            <!--
            location.href="expired.html";       
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
}

String prevStrTable = (String)session.getAttribute(sessionVarPrefix+"strTableName");
String prevForm = (String)session.getAttribute(sessionVarPrefix+"viewForm");

Enumeration propnames = props.propertyNames();
Vector formnames = new Vector();
while(propnames.hasMoreElements()) {
    String name = (String)propnames.nextElement();
    if(name.indexOf("form") != -1 && name.indexOf("layout") != -1) {
	formnames.addElement(name);
    }
}
%>
<head>
<title>Table Selection</title>
<script language="javascript">
<!--
function setCheck() {
    var htmlform = document.tableForm;
    var value = htmlform.formsel.options[htmlform.formsel.selectedIndex].value;
    if(value == 'd') htmlform.defall.disabled = false;
    else htmlform.defall.disabled = true;
}
function updateForms() {
    var htmlform = document.tableForm;
    var tablea = 
	    htmlform.tablesel.options[htmlform.tablesel.selectedIndex].value;
    var forms = new Array(<%
	for(int i=0;i<formnames.size();i++) {
	    out.println("'"+(String)formnames.elementAt(i)+"'");
	    if(i<formnames.size()-1) {
		out.println(",");
	    }
	}
    %>);
    var options = htmlform.formsel.length;
    for(var i=0;i<options;i++) {
	htmlform.formsel.options[i] = null;
	htmlform.formsel.options[i] = null;	
    }
    htmlform.formsel.options[0] = new Option('default','d');
    var i=1;
    for(var j=0;j<forms.length;j++) {   
	if(forms[j].toLowerCase().indexOf(tablea.toLowerCase()+'.form.') == 0) {
	    var start = forms[j].indexOf('.form.')+6;
	    var formname = forms[j].substr(start, 
				forms[j].indexOf('.',start) - start);
	    htmlform.formsel.options[i] = new Option(formname, forms[j]);
	    if(forms[j] == '<%=prevForm%>.layout') {
		htmlform.formsel.options[i].selected = true;
	    }
	    i++;
	}
    }
    setCheck();
}
function go() {
    var htmlform = document.tableForm;  
    htmlform.strtable.value = 
	    htmlform.tablesel.options[htmlform.tablesel.selectedIndex].value;
    var selind = htmlform.formsel.selectedIndex;	        
    if(selind == -1) selind = 0;
    var formname = 
	    htmlform.formsel.options[selind].value;
    if(formname == 'd' && htmlform.defall.checked) formname = "defaultall";
    else if(formname == 'd') formname = "defaultnull";
    else {
	var end = formname.lastIndexOf(".");
	formname = formname.substr(0, end);
    }
    htmlform.viewform.value = formname;
    htmlform.action="initsearch.jsp"+location.search;
    htmlform.submit();
}
function init() {
    updateForms();
    if('<%=prevForm%>' == 'defaultall') {
	document.tableForm.defall.checked = true;
    }
}
//-->
</script>
</head>
<body bgcolor="#e1e1e1" onLoad="init()">
<b>Select the database table (structure types) you want to work with</b>
<form name="tableForm" method="post">
<table>
  <tr>
    <td>structure table:</td>
    <td><select name="tablesel" onChange="updateForms()">
	    <%
	    Vector tables=(new DatabaseProperties(ch)).getStructureTableNames();
	    for(int i=0;i<tables.size();i++) {
		String value = (String)tables.elementAt(i);
		String name = value.substring(value.indexOf(".") + 1);
		out.println("<option value='"+value+"' "+(value.equals(prevStrTable)? "selected='true'" : "")+">"+name+"</option>");
	    }
	    %>
	</select></td>
 </tr><td></td><tr>
  </tr><tr>
    <td colspan="2">
    <b>Demo of forms available, please leave at "default"</b>
    </td>
  </tr><tr>
    <td>form:</td>
    <td><select name="formsel" onChange="setCheck()">
	</select></td>
  </tr><tr>
  <td colspan="2"><input type="checkbox" name="defall"> Display results with all user defined fields
    </td>
  </tr><tr>  
</tr><tr>
    <td colspan="2">
    <input type="button" value="submit" onClick="go()">
    </td>
  </tr>
</table>
<b>Structure tables available:</b>
<ul>
    <li> editexample: small set of  structures (~2,600 records) and limited data. Open for modification, insert, etc. </li>
    <li> markush: collection of Markush structures which can be searched. Includes additional options for visualizing/enumerating hits and R-groups. </li>
    <li> nci: larger subset of NCI structures (~250k records) and limited data. </li>
    <li> NCI3D: NCI set stored and shown as 3D structures. </li>
    <li> NCI_drugs: (~11,000 records) limited data.</li>
    <li> polymer: A small collection of polymers illustrating Marvin/JChem polymer structure features. </li>
    <li> query: A small collection of queries illustrating Marvin/JChem query table features. </li>
    <li> reactions: A collection of reactions illustrating Marvin/JChem reaction searching features. </li>
</ul>
<input type="hidden" name="strtable">
<input type="hidden" name="viewform">
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
