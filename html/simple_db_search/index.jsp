<%@ page import="chemaxon.util.*"%>
<%
String sessionVarPrefix="example.";
/*
 * The session object will be needed to store the input data for
 * later use.
 */
javax.servlet.http.HttpSession ssn = request.getSession(true);

/*
 * Molfile will be applied for msketch.
 */

String molFile = (String)ssn.getAttribute(sessionVarPrefix+"query.molfile");
ssn.removeAttribute(sessionVarPrefix+"query.molfile");
if(molFile==null) {
    molFile = "";
}
%>
<html>
<script type="text/javascript" language="JavaScript">
<!--

var sketcherLoaded=false
twIndex=0;
/*
 * Opening a new window for the help
 */
function help()
{
    var w = window.open("queryhelp.html",
	    "queryhelp"+(twIndex++).toString(),
	    "resizable=yes,width=470,height=270,scrollbars=yes,menubar=yes");
    w.focus();
}


/*
 * Submit form only if the loading of the page has finished
 */
function submitIfLoaded(whatToDo)
{
    form=document.queryForm;
    if(sketcherLoaded) {
	form.action="search.jsp" + location.search;
	form.molfile.value=document.msketch.getMol('mrv');
	form.submit();
    } else
	alert("Page loading. Please wait.");
}

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
    with (document) for (var j=0; j<imgFiles.length; j++) {
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
  
  function disabler() {
    form = document.queryForm;
    var index = form.type.selectedIndex;
    var value = form.type.options[index].value;

    if(value != "Similarity") {
    	form.similarityThreshold.disabled=true;
    }
    else {
        form.similarityThreshold.disabled=false;
    }
}
// -->
</script>

<head>
<title>Query Parameters</title>
</head>

<body bgcolor="#e1e1e1" onLoad = "sketcherLoaded=true;preloadImages('../../images/chemaxon_high.gif');preloadImages('../../images/search_high.gif');preloadImages('../../images/help_high.gif')">
<br>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
<td valign=top>
    <form method="post" name="queryForm">
    <input type="hidden" name="molfile">
    <table border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td rowspan="9" valign="top" ><img src="../../images/jchem.gif" width="56" height="234"></td>
        <td><img src="../../images/top.gif" width=144 height=25 border=0 alt=""></td>
      </tr>
      <!--tr>
        <td><img src="../../images/space.gif" width=144 height=5 border=0 alt=""></td>
      </tr-->
      <tr>
        <td><a href="javascript:parent.submitIfLoaded('search')" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.search','document.search','../../images/search_high.gif')"><img name="search" border=0 src="../../images/search_norm.gif" width=144 height=32 alt=""></a></td>
      </tr>
      <tr> 
        <td><a href="javascript:parent.help()" onMouseOut="swapImgRestore()" onMouseOver="swapImage('document.help','document.help','../../images/help_high.gif')"><img name="help" border=0 src="../../images/help_norm.gif" width=144 height=32 alt=""></a></td>
      </tr>
      <tr> 
        <td><img src="../../images/bottom.gif" width=144 height=29 border=0 alt=""></td>
      </tr>
      <tr> 
        <td><a href="http://www.chemaxon.com" target="_blank" onMouseOut="swapImgRestore()"
        onMouseOver="swapImage('document.chemaxon','document.chemaxon','../../images/chemaxon_high.gif')"><img name="chemaxon" border=0 src="../../images/chemaxon_norm.gif" width=144 height=43 alt="">
        </a>
        </td>
      </tr>
      <tr>
        <td height=40></td>
      </tr>
      <tr>
        <td colspan="2">
        <table border="0" cellpadding="0" cellspacing="5">

        <tr>
        <td>
            <font face="helvetica" size="1">
            Search type:
            </font>
        </td>
        <td>
            <select id="type" name="type" onchange="disabler();">
            <option value="Substructure">Substructure</option>
            <option value="Superstructure">Superstructure</option>
            <option value="Similarity">Similarity</option>
            <option value="Full">Full</option>
            <option value="Full Fragment">Full Fragment</option>
            <option value="Duplicate">Duplicate</option>
            </select>
        </td>
        </tr>
        <tr>
        <td>
            <font face="helvetica" size="1">
            Similarity<br>threshold:
            </font>
        </td>
        <td>
            <select id="similarityThreshold" name="similarityThreshold" disabled>
            <option>0.4 </option>
            <option>0.5 </option>
            <option>0.6 </option>
            <option>0.7 </option>
            <option>0.8 </option>
            <option>0.85</option>
            <option>0.86</option>
            <option>0.87</option>
            <option>0.88</option>
            <option>0.89</option>
            <option selected>0.9</option>
            <option>0.91</option>
            <option>0.92</option>
            <option>0.93</option>
            <option>0.94</option>
            <option>0.95</option>
            <option>0.96</option>
            <option>0.97</option>
            <option>0.98</option>
            <option>0.99</option>
            </select>
        </td>
        </tr>

        <tr>
        <td>
            <font face="helvetica" size="1">
            Max. hits:
            </font>
        </td>
        <td>
            <select name="maxResultCount">
            <option value=1>1
            <option value=2>2
            <option value=3>3
            <option value=4>4
            <option value=5>5
            <option value=10>10
            <option value=50>50
            <option value=100>100
            <option value=200 selected>200
            <option value=500>500
            <option value=1000>1000
            <option value=2000>2000
            <option value=5000>5000
            <option value=0>unlimited
            </select>
        </td>
        </tr>
        <tr>
        <td>
            <font face="helvetica" size="1">
            Max. time:
            </font>
        </td>
        </tr>

        </table>
        </td>
      </tr>
      <tr>
        <td height=20>
        </td>
      </tr>
    </table>
    </form>
</td>
<td valign=top>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
    <script LANGUAGE="JavaScript1.1">
    <!--
    msketch_name="msketch";
    msketch_begin("../../marvin", "460", "460");
    msketch_param("molbg", "#F0F0F0");
    msketch_param("implicitH", "off");
    msketch_param("undo", "50");
    msketch_param("mol","<%=HTMLTools.convertForJavaScript(molFile)%>");
    msketch_end();
    //-->
    </script>
</td>
</table>
</body>
</html>
