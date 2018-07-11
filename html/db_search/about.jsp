<%@page contentType="text/html"%>
<%@ include file="init.jsp" %>
<html>
<head>
<!--LINK REL ="stylesheet" TYPE="text/css" HREF="../../jchemmanuals.css"
TITLE="Style"-->
<title>About JChem</title>
</head>
<body bgcolor="#FFFFFF">
<script language="JavaScript">
<!--
opener.document.childOpened="true";  //For pop-up window check
-->
</script>

<center>
<p>
<br>
<a href="http://www.chemaxon.com" target="_blank"><img border=0 src="../../images/logo.jpg"></a>
</p>

</center>
<%-- <jsp:useBean id="beanInstanceName" scope="session" class="package.class" /> --%>
<%-- <jsp:getProperty name="beanInstanceName"  property="propertyName" /> --%>
<p>
<table border="0" align="center" cellspacing="0" cellpadding="5">
    <tr>
        <td><a href="http://www.chemaxon.com/jchem" target="_blank">JChem</a> version:</td>
	<td width="30">&nbsp;</td>
        <td><%=chemaxon.jchem.version.VersionInfo.getVersion()%></td>
    </tr>
    <tr>
        <td>JVM*:</td>
	<td width="30">&nbsp;</td>
        <td><%=System.getProperty("java.vendor")
        +"<br>"+System.getProperty("java.vm.name")
        +"<br>"+System.getProperty("java.version")
        %></td>
    </tr>
    <tr>
        <td>OS*:</td>
	<td width="30">&nbsp;</td>
        <td><%=System.getProperty("os.arch")+" "+System.getProperty("os.name")+" "+System.getProperty("os.version")%></td>
    </tr>
    <tr>
        <td>
            <a href="cachedetails.jsp" target="_blank">Cache details</a>
        </td>
    </tr>
    <tr>
	<td><font size=-1>* Server-side.</font></td>
	<td width="30">&nbsp;</td>
	<td></td>
    </tr>
</table>
</p>
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