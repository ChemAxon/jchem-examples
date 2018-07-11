<%--

 editproperties.jsp

 ChemAxon Ltd., 2002

 One can edit the $HOME/.jchemsite file with this page.
 The .jchemsite file contains the default database parameters
 username, password, driver, url, and the property table name.
 If the file doesn't exist create it with default data.
--%> 

<%@page contentType="text/html"%>
<%@ page import="java.io.*, chemaxon.util.*,
                 java.util.Properties,
                 java.util.Enumeration,
                 java.util.ArrayList, java.util.List" errorPage="errorpage.jsp"%>


<%

    String fileSep=System.getProperty("file.separator");

    String chemDir=DotfileUtil.getDotDir().getAbsolutePath();
    if (chemDir.endsWith(fileSep)) {
        chemDir=chemDir.substring(0, chemDir.length()-1);
    }

    //Creating chemaxon directory if not exists
    File d = new File(chemDir);
    d.mkdirs();

    // Set the file, get parameters from the os.
    String propsFname = chemDir +fileSep+ ".jchemsite";

    //moving configuration file from previous version:
    if (!new File(propsFname).exists()) {
        File old=new File(chemDir).getParentFile();
        old=new File(old, ".jchemsite");
        if (old.exists()) {
            old.renameTo(new File(chemDir, ".jchemsite"));
        }
    }




    Properties defaultProps=new Properties();
    defaultProps.setProperty("propertyTableName", "JChemProperties");
    defaultProps.setProperty("useStructureCache", "true");

// Read the file.
    Properties props=new Properties(defaultProps);
    try{
        props.load(new FileInputStream(propsFname));
    } catch (IOException e) {
        // setting some example values if property file does not exist yet.
	props.setProperty("readOnlyTableNames", "SCOTT.JSPEXAMPLE;SCOTT.TABLE");
	props.setProperty("SCOTT.JSPEXAMPLE.queryConditions", "cd_id#id;name");

	props.setProperty("jspexample.form.jchemform.rows", "6");
	props.setProperty("jspexample.form.jchemform.cols", "3");
	props.setProperty("jspexample.form.jchemform.celldim", "240:180");
	props.setProperty("jspexample.form.jchemform.layout", ":3:2:L:0:0:1:2:w:n:0:10:M:1:0:2:1:c:n:1:10:L:1:1:1:1:w:n:L:2:1:1:1:nw:n");
	props.setProperty("jspexample.form.jchemform.param", ":L:10:M:150:150:L:11b:L:10");
	props.setProperty("jspexample.form.jchemform.cell", "ID: <cd_id>;<$cd_structure>;<cd_formula>;MW: <cd_molweight>");
    }

    java.util.List propertiesWithFields= new ArrayList();

    propertiesWithFields.add("sessionVarPrefix");
    propertiesWithFields.add("driver");
    propertiesWithFields.add("url");
    propertiesWithFields.add("propertyTableName");
    propertiesWithFields.add("username");
    propertiesWithFields.add("password");
    propertiesWithFields.add("readOnlyTableNames");
    propertiesWithFields.add("chemicalTermsFilterFile");
    propertiesWithFields.add("searchesToRemember");
    propertiesWithFields.add("useStructureCache");

    //making sure no displayed property is null:
    for (int x=0; x<propertiesWithFields.size() ; x++) {
        String propName=(String) propertiesWithFields.get(x);
        String prop=props.getProperty(propName);
        if (prop==null) {
            props.setProperty(propName, "");
        }
    }

    StringBuffer otherProps=new StringBuffer();
    Enumeration keys=props.keys();
    while (keys.hasMoreElements()) {
        String key=(String)keys.nextElement();
        if (!propertiesWithFields.contains(key)) {
            otherProps.append(key);
            otherProps.append("=");
            otherProps.append(props.getProperty(key));
            otherProps.append("\n");
        }
    }
%>
<html>
<head><title>Setup page</title></head>
<body bgcolor="#e1e1e1">
<center><h2>JSP Database Example Setup Page</h2></center>
<FORM action="saveproperties.jsp" method="post">

<table>

    <tr>
        <td><pre>JDBC driver class name: </pre></td>
        <td><input name="driver" size="90" value="<%=props.getProperty("driver")%>"/></td>
    <tr>

    <tr>
        <td><pre>URL for JDBC connection: </pre></td>
        <td><input name="url" size="90" value="<%=props.getProperty("url")%>"/></td>
    <tr>

    <tr>
        <td><pre>Property table name: </pre></td>
        <td><input name="propertyTableName" size="90"
            value="<%=props.getProperty("propertyTableName")%>"/></td>
    <tr>

    <tr>
        <td><pre>Database user login name: </pre></td>
        <td><input name="username" size="90" value="<%=props.getProperty("username")%>"/></td>
    <tr>

    <tr>
        <td><pre>Database user password: </pre></td>
        <td><input name="password" type="password"
            size="90" value="<%=props.getProperty("password")%>"/></td>
    <tr>

    <tr>
        <td><pre>Read-only tables: </pre></td>
        <td><input name="readOnlyTableNames" size="90"
            value="<%=props.getProperty("readOnlyTableNames")%>"/></td>
    <tr>

    <tr>
        <td><pre>Chemical Terms filter file: </pre></td>
        <td><input name="chemicalTermsFilterFile" size="90"
            value="<%=props.getProperty("chemicalTermsFilterFile")%>"/></td>
    <tr>

    <tr>
        <td><pre>Searches to remember:</pre></td>
        <td><select name="searchesToRemember">
            <option value=0>None
<%
    String toRemember=props.getProperty("searchesToRemember");
    if (toRemember==null) {
        toRemember="0"; //default
    }
    for (int x=1; x< 5; x++) {
%>
            <option value=<%=x%> <%= toRemember.equals(""+x) ? "selected" : "" %> > <%=x%>
<%
    }
%>
        </select></td>
    <tr>

</table>
<p>
<B>Additional properties:</b><br>
<TEXTAREA cols=90 rows=10 name=otherProps><%= otherProps %></TEXTAREA>
<p>
<input type=SUBMIT value="Save changes">
<input type=button value="Cancel" onClick="javascript:location.href='index.jsp'">
<p>
<a href="../../util/license/setlicense.jsp" target="_blank">Upload license keys</a>
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
