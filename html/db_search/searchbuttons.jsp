<%@ page import="
java.sql.*,
java.util.*,
java.text.DecimalFormat,
chemaxon.jchem.db.*, 
chemaxon.util.*"
errorPage="errorpage.jsp"
%>
<%@ include file="init.jsp"%>
<%
boolean readOnly = false;

String structureTableName = 
	    (String)session.getAttribute(sessionVarPrefix+"strTableName");

ConnectionHandler ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");

if((ch==null)||(!ch.isConnected())) {
    Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
    if(v == null) {
        %>
        <script LANGUAGE="JavaScript">
        <!--
        parent.location.href="expired.html";       
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
if(readOnlyTableNames != null) {
    String delim = ":";
    if(readOnlyTableNames.indexOf(":") == -1) {	
	delim = ";";
    }
    StringTokenizer importToken = new StringTokenizer(readOnlyTableNames,delim);
    while(importToken.hasMoreTokens()) {	
	if(structureTableName.equals(importToken.nextToken())) {
	    readOnly = true;
	}
    }
}
%>

<html>
<head>
<title>Buttons</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript">
<!--
function swapImgRestore() {
  if (document.swapImgData != null)
    for (var i=0; i<(document.swapImgData.length-1); i+=2)
      document.swapImgData[i].src = document.swapImgData[i+1];
}

function preloadImages() {
  if (document.images) {
    var imgFiles = preloadImages.arguments;
    if (document.preloadArray==null) document.preloadArray = new Array();
    var i = document.preloadArray.length;
    with (document) for (var j=0; j<imgFiles.length; j++){
      preloadArray[i] = new Image;
      preloadArray[i++].src = imgFiles[j];
  } }
}

function swapImage() { 
  var i,j=0,objStr,obj,swapArray=new Array,oldArray=document.swapImgData;
  for (i=0; i < (swapImage.arguments.length-2); i+=2) {
    objStr = swapImage.arguments[(navigator.appName == 'Netscape')?i:i+1];
    if ((objStr.indexOf('document.layers[')==0 && document.layers==null) ||
        (objStr.indexOf('document.all[')   ==0 && document.all   ==null))
      objStr = 'document'+objStr.substring(objStr.lastIndexOf('.'),objStr.length);
    obj = eval(objStr);
    if (obj != null) {
      swapArray[j++] = obj;
      swapArray[j++] = (oldArray==null || oldArray[j-1]!=obj)?obj.src:oldArray[j];
      obj.src = swapImage.arguments[i+2];
  } }
  document.swapImgData = swapArray; //used for restore
}

// 2 javascript thingys for "back" button, not in use now :

function y2k(number) { return (number < 1000) ? number + 1900 : number; }

function getTime() {
    var now = new Date();
    return Date.UTC(y2k(now.getYear()),now.getMonth(),now.getDate(),now.getHours(),now.getMinutes(),now.getSeconds());   
}

//-->
</script>
</head>

<body bgcolor="#e1e1e1" onLoad="parent.buttonsLoaded=true;preloadImages('../../images/previous_high.gif');preloadImages('../../images/next_high.gif');preloadImages('../../images/first_high.gif');preloadImages('../../images/last_high.gif');preloadImages('../../images/page_high.gif');preloadImages('../../images/query_high.gif');preloadImages('../../images/retrieve_all_high.gif');preloadImages('../../images/insert_high.gif');preloadImages('../../images/modify_high.gif');preloadImages('../../images/delete_high.gif');preloadImages('../../images/help_high.gif');preloadImages('../../images/chemaxon_high.gif');preloadImages('../../images/import_high.gif');preloadImages('../../images/export_high.gif');preloadImages('../../images/table_high.gif')">

<table border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td rowspan="23" valign="top" >
        <a href="javascript:parent.about()">
            <image src="../../images/jchem.gif" width="56" height="234" border=0>
        </a>
    </td>

    <td><img src="../../images/top.gif" width=144 height=25 border=0 alt=""></td>
  </tr>
  <tr>
    <td><a href="javascript:parent.buttonAction('left')" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.previous','document.previous','../../images/previous_high.gif')"><img name="previous" border=0 src="../../images/previous_norm.gif" width=69 height=37 alt=""></a><a href="javascript:parent.buttonAction('right')" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.next','document.next','../../images/next_high.gif')"><img name="next" border=0 src="../../images/next_norm.gif" width=75 height=37 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href="javascript:parent.buttonAction('first')" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.first','document.first','../../images/first_high.gif')"><img name="first" border=0 src="../../images/first_norm.gif" width=69 height=36 alt=""></a><a href="javascript:parent.buttonAction('last')" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.last','document.last','../../images/last_high.gif')"><img name="last" border=0 src="../../images/last_norm.gif" width=75 height=36 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href="javascript:parent.selectAPage()" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.page','document.page','../../images/page_high.gif')"><img name="page" border=0 src="../../images/page_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
<!-- href="query.jsp" onClick="this.href = 'query.jsp?' + getTime()" target="_parent"
-->
    <td><a href="query.jsp" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.query','document.query','../../images/query_high.gif')"><img name="query" border=0 src="../../images/query_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href="initsearch.jsp" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.retrieveAll','document.retrieveAll','../../images/retrieve_all_high.gif')"><img name="retrieveAll" border=0 src="../../images/retrieve_all_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
      <td><a href="seltable.jsp" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.seltable','document.seltable','../../images/table_high.gif')"><img name="seltable" border=0 src="../../images/table_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
    <tr>
    <td><img src="../../images/space.gif" width=144 height=6 border=0 alt=""></td>
  </tr>
  <tr> 
    <td><a href=javascript:parent.openEditWindow('<%=readOnly? "readonly" : "insert"%>') target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.insert','document.insert','../../images/insert_high.gif')"><img name="insert" border=0 src="../../images/insert_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href=javascript:parent.openEditWindow('<%=readOnly? "readonly" : "modify"%>') target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.modify','document.modify','../../images/modify_high.gif')"><img name="modify" border=0 src="../../images/modify_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href=javascript:parent.openEditWindow('<%=readOnly? "readonly" : "delete"%>') target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.deleteMol','document.deleteMol','../../images/delete_high.gif')"><img name="deleteMol" border=0 src="../../images/delete_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>

  <tr>
    <td><img src="../../images/space.gif" width=144 height=6 border=0 alt=""></td>
  </tr>
  <tr> 
    <td><a href="javascript:parent.importMols()" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.importM','document.importM','../../images/import_high.gif')"><img name="importM" border=0 src="../../images/import_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr> 
    <td><a href="javascript:parent.exportMols()" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.exportM','document.exportM','../../images/export_high.gif')"><img name="exportM" border=0 src="../../images/export_norm.gif" width=144 height=32 alt=""></a></td>
  </tr>
  <tr>
    <td><img src="../../images/space.gif" width=144 height=6 border=0 alt=""></td>
  </tr>
  <tr> 
    <td><a href="../../marvin/help/view/view-index.html" target="_blank" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.help','document.help','../../images/help_high.gif')"><img name="help" border=0 src="../../images/help_norm.gif" width=144 height=32 alt=""></a></td>
</tr>
  <tr> 
    <td><a href="javascript:parent.about()" target="_parent" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.about','document.about','../../images/about_high.gif')"><img name="about" border=0 src="../../images/about_norm.gif" width=144 height=32 alt=""></a></td>
</tr>
  <tr>
    <td><img src="../../images/bottom.gif" width=144 height=29 border=0 alt=""></td>
  </tr>
  <tr> 
    <td colspan=2><a href="http://www.chemaxon.com" target="_blank" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.chemaxon','document.chemaxon','../../images/chemaxon_high.gif')"><img name="chemaxon" border="0" src="../../images/chemaxon_norm.gif" width="144" height="43"></a></td>
  </tr>
</table>

<script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
<script LANGUAGE="JavaScript">
<!--
links_set_search(location.search);
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
