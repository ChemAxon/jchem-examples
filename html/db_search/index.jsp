<%--

 index.jsp

 ChemAxon Ltd., 2002

 Starting page of the jsp1_x example, a login window containing name, password,
 driver, url fields for database login and a jchemproperty field.

--%> 

<html>
<head>
<title>JChem login</title>
<%@ include file="init.jsp" %>
<%!
private boolean checkLogin(String a, String b, String c, String d, String e) {
    if(a != null && b != null && c != null && d != null && e != null) {
	if(!a.equals("") && !b.equals("") && !c.equals("") && 
	    !d.equals("") && !e.equals("")) {
	    return true;
	}    
    }
    return false;
}
private boolean driverDef(String drv) {
    if(drv != null) {
	if(!drv.equals("")) return true;
    }
    return false;
}
private boolean urlDef(String url) {
    if(url != null) {
	if(!url.equals("")) return true;
    }
    return false;
}

private String generateUserID() {
    return ""+((long)(Math.random()*Long.MAX_VALUE));
}


%>

<%
    String queryString=request.getQueryString();

    if (queryString==null) {
        queryString="";
    }
    if (queryString.indexOf("uid=")==-1) {
        if (queryString.length()!=0) {
            queryString+="&";
        }
        queryString+="uid="+generateUserID();
    }
%>
<SCRIPT language="JavaScript">
<!--

// If cookies exist read cookies and write values into the proper
// text fields. If cookies exist with " " values or there are no cookies
// the values readed from property file ($HOME/jchem.properties)
// will be written into fields.

var bikky = document.cookie;

function getCookie(name) {
    var index = bikky.indexOf(name + "=");
    if (index == -1) return null;
    index = bikky.indexOf("=", index) + 1;
    var endstr = bikky.indexOf(";", index);
    if (endstr == -1) endstr = bikky.length;
    return unescape(bikky.substring(index, endstr));
}

var today = new Date();
var expiry = new Date(today.getTime() + 28 * 24 * 60 * 60 * 1000); // plus 28 days

function setCookie(name, value) {
    if (value != null && value != "")
      document.cookie=name + "=" + escape(value) + "; expires=" + expiry.toGMTString();
    bikky = document.cookie;
}

//setting field values:
function init() {
    var form = document.loginForm;
    form.dbdrv.value = '<%= local_driver %>';
    form.dburl.value = '<%= local_url %>';
    form.propTable.value = '<%= local_propertyTableName %>';
    }

// Save cookies if values not equals " " and try to login by index.jsp
// If text values equals " ", replace values with values read from 
// property file, and load the page again.

function login() {
    if(document.loginForm.dbname.value=="") setCookie("jchemName"," ");
    else setCookie("jchemName",document.loginForm.dbname.value);
    if(document.loginForm.dburl.value=="") setCookie("jchemUrl"," ");
    else setCookie("jchemUrl",document.loginForm.dburl.value);
    if(document.loginForm.dbdrv.value=="") setCookie("jchemDrv"," ");
    else setCookie("jchemDrv",document.loginForm.dbdrv.value);
    if(document.loginForm.propTable.value=="") setCookie("jchemPropTbl"," ");
    else setCookie("jchemPropTbl",document.loginForm.propTable.value);
    if(document.loginForm.passwdCheck.checked) {
        setCookie("jchemRemPasswd","true");
        if(document.loginForm.dbpasswd.value=="") setCookie("jchemPasswd"," ");
        else setCookie("jchemPasswd",document.loginForm.dbpasswd.value);	
    } else {
        setCookie("jchemPasswd"," ");
        setCookie("jchemRemPasswd","false");
    }
    document.loginForm.submit();
}

function clearcookies() {
    setCookie("jchemName"," ");
    setCookie("jchemUrl"," ");
    setCookie("jchemPropTbl"," ");
    setCookie("jchemDrv"," ");
    setCookie("jchemRemPasswd"," ");
    setCookie("jchemPasswd"," ");
    document.loginForm.propTable.value = "";
    document.loginForm.dburl.value = "";
    document.loginForm.passwdCheck.checked = false;
    document.loginForm.dbdrv.value = "";
    document.loginForm.dbname.value = "";
    document.loginForm.dbpasswd.value = ""
    document.loginForm.dburl.value = "";	 
}
//-->
</SCRIPT>
</head>
<%
// Remove the ConnectionHandler from session, because 
// a new login will be created.
session.removeAttribute(sessionVarPrefix+"ch");

// Get parameters from request. These parameters exist in case of
// expired session.
String urlFrom = (String)request.getParameter("url");
String error = (String)session.getAttribute(sessionVarPrefix+"error");
session.removeAttribute(sessionVarPrefix+"error");
%>
<body bgcolor="#e1e1e1" onLoad="init();">
<h3>Login to the demo pages</h3>
<form name="loginForm" method="post">
<script language="javascript">
	<!--	
        //passing parameters (swing/awt) to the next page:
	document.loginForm.action="seltable.jsp"+"?<%=queryString%>";
        //-->
</script>
<%
// e.g. login error
if(error != null) {
    if(error.length()!=0) {
	 out.println("<font size=+1 color='black'><p>Error:<br><br>"+
	"</font><font color='red'>"+error+"</font></p>");
    }
} 
if(error == null && false &&
	    checkLogin(local_driver, local_url, local_username,
				local_password, local_propertyTableName)) {
	//Login automatically if properties are defined.
	%>
	<input type="hidden" name="dbname">
	<input type="hidden" name="dbpasswd">
	<input type="hidden" name="dbdrv">
	<input type="hidden" name="dburl">
	<input type="hidden" name="propTable">
	<script language="javascript">
	<!--	
	var form = document.forms[0];
	form.dbname.value = '<%= local_username %>';
	form.dbpasswd.value = '<%= local_password %>';
	form.dbdrv.value = '<%= local_driver %>';
	form.dburl.value = '<%= local_url %>';
	form.propTable.value = '<%= local_propertyTableName %>';
	form.submit();
	//-->
	</script>
	<%
} else {
    %>
    <table>
	<tr>
	    <!--td colspan=2 align='center'><font size=+3 face="helvetica"><b>Login</b></font></td-->
	</tr><tr>
	    <td>Username:</td>
	    <td><input type="text" size="40" name="dbname" value="guest"></td>
	</tr><tr>
	    <td>Password:</td>
	    <td><input type="password" size="40" name="dbpasswd" value="guest"></td>
	</tr>
	<%if(!driverDef(local_driver)) {%>
	<tr>
	    <td>Driver:</td>
	    <td><input type="text" size="40" name="dbdrv"></td>
	</tr>
	<%} else {%>
	    <input type="hidden" name="dbdrv" value="<%=local_driver%>">
	<%} 
        if(!urlDef(local_url)) {%>
	<tr>
	    <td>Url:</td>
	    <td><input type="text" size="40" name="dburl"></td>
	</tr>
	<%} else {%>
	    <input type="hidden" name="dburl" value="<%=local_url%>">	
	<%}%>
	<tr>
	    <td>Property table:</td>
	    <td><input type="text" size="40" name="propTable"></td>
       </tr><tr>
	    <td colspan=2>Please accept the default Username, Password, and Property table.</td>
       </tr><tr>
	    <td colspan=2><input type='hidden' name='passwdCheck' ></td>
	</tr><tr>

	    <td colspan=2 align='center'>
	    <input type="button" value="Login" onClick="login();">
	    <input type="button" value="Clear" onClick="clearcookies();">
	    <input type="button" value="Cancel" onClick="window.close();"></td>
	</tr>
    </table>
    <%
    if(urlFrom!=null) {
	%>
	<input type="hidden" name="urlFrom" value="<%=urlFrom%>">
	<%
    }
}
%>
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
