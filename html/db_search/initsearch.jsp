<%--

 initsearch.jsp

 ChemAxon Ltd., 1999-2004

 A frameset that for displaying the hit structures 
 and a button page.

--%> 
<%@ page errorPage="errorpage.jsp" %>
<%@ include file="init.jsp" %>

<%

//checking server timeout:
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

/*
 * Molfile and other input parameters will be used for searching.
 */
String molfile = (String)request.getParameter("molfile");
if(molfile != null) { // query defined
    String type=request.getParameter("type");
    String threshold=request.getParameter("dissimilarityThreshold");
    String maxRes=request.getParameter("maxResultCount");
    String mdName=request.getParameter("MD");
    String mdConfig=request.getParameter("MDConfig");
    String tautomers=request.getParameter("tautomers");   
    String stereochem=request.getParameter("stereochem");
    String doubleBondStereoCheck=request.getParameter("doubleBondStereoCheck");
    String charges=request.getParameter("charges");
    String isotopes=request.getParameter("isotopes");
    String radicals=request.getParameter("radicals");
    String valence=request.getParameter("valence");
    String vaguebond=request.getParameter("vaguebond");   
    String nonhits=request.getParameter("nonhits");
    String prevhits=request.getParameter("prevhits");
    String chemterm=request.getParameter("chemterm");
    String additionalOpts=request.getParameter("addopts");
    String startTimeAtClient=request.getParameter("startTimeAtClient");
    // settings for current search:
    session.setAttribute(sessionVarPrefix+"query.molfile", molfile);
    session.setAttribute(sessionVarPrefix+"query.type",type);
    session.setAttribute(sessionVarPrefix+"query.dissimilarityThreshold",threshold);
    session.setAttribute(sessionVarPrefix+"query.maxResultCount", maxRes);
    session.setAttribute(sessionVarPrefix+"query.MDName", mdName);
    session.setAttribute(sessionVarPrefix+"query.MDConfig", mdConfig);
    session.setAttribute(sessionVarPrefix+"query.tautomers", tautomers);
    session.setAttribute(sessionVarPrefix+"query.stereochem", stereochem);
    session.setAttribute(sessionVarPrefix+"query.doubleBondStereoCheck", doubleBondStereoCheck);
    session.setAttribute(sessionVarPrefix+"query.charges", charges);
    session.setAttribute(sessionVarPrefix+"query.isotopes", isotopes);
    session.setAttribute(sessionVarPrefix+"query.radicals", radicals);
    session.setAttribute(sessionVarPrefix+"query.valence", valence);
    session.setAttribute(sessionVarPrefix+"query.vaguebond", vaguebond);
    session.setAttribute(sessionVarPrefix+"query.nonhits", nonhits);
    session.setAttribute(sessionVarPrefix+"query.prevhits", prevhits);
    session.setAttribute(sessionVarPrefix+"query.chemterm", chemterm);
    session.setAttribute(sessionVarPrefix+"query.additionalOptions", additionalOpts);
    session.setAttribute(sessionVarPrefix+"query.startTimeAtClient", startTimeAtClient);

    // saving previous query settings:
    session.setAttribute(sessionVarPrefix+"query.prev.molfile", molfile);
    session.setAttribute(sessionVarPrefix+"query.prev.type",type);
    session.setAttribute(sessionVarPrefix+"query.prev.dissimilarityThreshold",threshold);
    session.setAttribute(sessionVarPrefix+"query.prev.maxResultCount", maxRes);
    session.setAttribute(sessionVarPrefix+"query.prev.MDName", mdName);
    session.setAttribute(sessionVarPrefix+"query.prev.MDConfig", mdConfig);
    session.setAttribute(sessionVarPrefix+"query.prev.tautomers", tautomers);
    session.setAttribute(sessionVarPrefix+"query.prev.stereochem", stereochem);
    session.setAttribute(sessionVarPrefix+"query.prev.doubleBondStereoCheck", doubleBondStereoCheck);
    session.setAttribute(sessionVarPrefix+"query.prev.charges", charges);
    session.setAttribute(sessionVarPrefix+"query.prev.isotopes", isotopes);
    session.setAttribute(sessionVarPrefix+"query.prev.radicals", radicals);
    session.setAttribute(sessionVarPrefix+"query.prev.valence", valence);
    session.setAttribute(sessionVarPrefix+"query.prev.vaguebond", vaguebond);
    session.setAttribute(sessionVarPrefix+"query.prev.nonhits", nonhits);
    session.setAttribute(sessionVarPrefix+"query.prev.chemterm", chemterm);
    session.setAttribute(sessionVarPrefix+"query.prev.additionalOptions", additionalOpts);
    int conds = 
	((Integer)session.getAttribute(sessionVarPrefix+"condcount")).intValue();
    for(int i=0; i<conds; i++) {
	session.setAttribute(sessionVarPrefix+"query.condition"+i+".field",
		request.getParameter("field"+i));
	session.setAttribute(sessionVarPrefix+"query.condition"+i+".relation",
		request.getParameter("relation"+i));
	session.setAttribute(sessionVarPrefix+"query.condition"+i+".value",
		request.getParameter("value"+i));
	session.setAttribute(sessionVarPrefix+"query.condition"+i+".type",
		request.getParameter("type"+i));
    }
} else { // starting page
    String structureTableName = (String)request.getParameter("strtable");
    if(structureTableName != null) {
        String oldTableName=(String)
                session.getAttribute(sessionVarPrefix+"strTableName");
        //cleaning previous hit list if table name changed:
        if (oldTableName==null || !oldTableName.equals(structureTableName)) {
            session.removeAttribute(sessionVarPrefix+"prevHitLists");
            session.removeAttribute(sessionVarPrefix+"prevHitTimes");
        }
	session.removeAttribute(sessionVarPrefix+"strTableName");
	session.removeAttribute(sessionVarPrefix+"viewform");
	session.setAttribute(sessionVarPrefix+"strTableName", structureTableName);
	String viewForm = (String)request.getParameter("viewform");
	session.setAttribute(sessionVarPrefix+"viewForm", viewForm);
    }
    // defining "empty query" - all structures returned:
    session.removeAttribute(sessionVarPrefix+"query.molfile");
    session.setAttribute(sessionVarPrefix+"query.type", "");
    session.setAttribute(sessionVarPrefix+"query.dissimilarityThreshold","0");
    session.setAttribute(sessionVarPrefix+"query.maxResultCount", "0");
    session.setAttribute(sessionVarPrefix+"query.tautomers", "0");   
    session.setAttribute(sessionVarPrefix+"query.stereochem", "on");
    session.setAttribute(sessionVarPrefix+"query.doubleBondStereoCheck", "1");
    session.setAttribute(sessionVarPrefix+"query.charges", "0");
    session.setAttribute(sessionVarPrefix+"query.isotopes", "0");
    session.setAttribute(sessionVarPrefix+"query.radicals", "0");
    session.setAttribute(sessionVarPrefix+"query.valence", "0");
    session.setAttribute(sessionVarPrefix+"query.vaguebond", "0"); 
    session.removeAttribute(sessionVarPrefix+"query.nonhits");
    session.removeAttribute(sessionVarPrefix+"query.prevhits");
    session.removeAttribute(sessionVarPrefix+"query.chemterm");
    session.removeAttribute(sessionVarPrefix+"query.additionalOptions");
    session.removeAttribute(sessionVarPrefix+"query.startTimeAtClient");

    if(session.getAttribute(sessionVarPrefix+"condcount") != null) {
	int conds = ((Integer)session.getAttribute(
				    sessionVarPrefix+"condcount")).intValue();
	for(int i=0; i<conds; i++) {
	    session.removeAttribute(sessionVarPrefix+"query.condition"+i+".field");
	    session.removeAttribute(
			    sessionVarPrefix+"query.condition"+i+".relation");
            session.removeAttribute(sessionVarPrefix+"query.condition"+i+".value");
    	    session.removeAttribute(sessionVarPrefix+"query.condition"+i+".type");
	}
    }
}

session.setAttribute(sessionVarPrefix+"search.action", "starting_search");
%>
<html>
<head>
<script language="JavaScript">
<!--

var contentLoaded=false
var buttonsLoaded=false

var idSearchResults=1;

var labelCountInACell=1;
var ids;
var formCellParam;

document.childOpened="false";

function selectAPage()
{
    var searchResults=frames[idSearchResults];
    var form=searchResults.document.navigationForm;
    if(form==null || form["pageNumber"]==null)
	    return;
    var value=prompt("Enter page number:", form.pageNumber.value);
    if((value!=null) && !isNaN(parseInt(value))) {
	form.pageNumber.value=value;
	buttonAction("pageNumber");
    }
}

function buttonAction(event)
{
    if(buttonsLoaded && contentLoaded) {
	var searchResults=frames[idSearchResults];
	var form=searchResults.document.navigationForm;
	if(form!=null) { // null if no structures found
	    form.nextState.value=event;
	    contentLoaded=false;
	    form.action="searchresults.jsp"+location.search;
	    form.submit();
	}
    } else
	alert("Page loading. Please wait.");
}

function openEditWindow(mode)
{
    if(mode=='readonly') {
	alert("The content of this table cannot be modified.");
	return;
    }
    var searchResults=frames[idSearchResults];
    isInsertion = (mode=='insert');
    if(!buttonsLoaded || !contentLoaded) {
	alert("Page loading. Please wait.");
	return;
    }
    var mview = searchResults.document["mview"];
    var index = (mview==null? -1 : mview.getSelectedIndex());
    //var labelCountInACell=parseInt(labelsInACell);
    //var idIndexInACell=0;
    var conf = "true";
    if(mode=="delete" && index>=0 ) {
	conf=confirm("Warning: " + ids[index] + " will be deleted.")
    }
    if(mode=="insert" ||
	    (index >=0 && (mode=="update" ||  conf))) {
	var width = 810;
	var height = 600;
	if(mode=="delete") {
	    width = 300;
	    height = 100;
	}

        document.childOpened="false";
        window.open ('popuptest.html','newWin','resizable=no,scrollbars=no,status=no,height=50,width=150');
        openCheck();

	var w = window.open("", "", "resizable=yes,width="+width+
		",height="+height+",scrollbars=yes,menubar=yes,location=yes");
	w.document.writeln("<html><body bgcolor='#e1e1e1'><font size=+2 face=helvetica>");
	w.document.writeln((mode=="delete"? "Deleting" : "Page loading")
		+"... Please wait.");
	w.document.writeln("<form method=post>");
	w.document.writeln("<input type=hidden name=mode>");
	w.document.writeln("<input type=hidden name=cellIndex>");
	w.document.writeln("<input type=hidden name=id>");
	w.document.writeln("<input type=hidden name=labelCount>");
	w.document.writeln("<input type=hidden name=formCell>");
	w.document.writeln("</form>");
	w.document.writeln("</font></body></html>");
	w.document.close();
	var form=w.document.forms[0];
	form.mode.value = mode;
	if(!isInsertion) {
	    form.id.value = ids[index];
	    form.cellIndex.value = index;
	    form.labelCount.value = labelCountInACell;
	    form.formCell.value = formCellParam;
	}
	if(mode=="delete") {
	    form.action = "update.jsp"+location.search;
	} else {
	    form.action = "edit.jsp"+location.search;
	}
	form.submit();

    } else if(index<0) {
	alert("Nothing has been selected.");
    }
}

function importMols() {
    var searchResults=frames[idSearchResults];
    if(!buttonsLoaded || !contentLoaded) {
	alert("Page loading. Please wait.");
	return;
    }
    document.childOpened="false";
    var w = window.open("transfer/uploader.jsp"+location.search, "uploadWindow", "resizable=yes,width=500,height=320,scrollbars=no,menubar=no,location=no");
    openCheck();
}

function exportMols() {
    var searchResults=frames[idSearchResults];
    if(!buttonsLoaded || !contentLoaded) {
	alert("Page loading. Please wait.");
	return;
    }
    document.childOpened="false";
    var w = window.open("transfer/exporter.jsp"+location.search, "uploadWindow", "resizable=yes,width=340,height=470,scrollbars=yes,menubar=no,location=no");
    openCheck();
}

//opens about.jsp
function about() {
    document.childOpened="false";
    window.open ('about.jsp'+location.search,'newWin','resizable=yes,scrollbars=yes,status=yes,height=370,width=450');
    openCheck();
}

//....... for checking if popup windows are disabled in the browser ...........

function checkIfOpened() {
    if (document.childOpened!="true") {
        alert("JChem has detected that popup windows are disabled."
                +" Please check your browser and internet security settings,"
                +" and restart your browser after the changes.");
    }
}

function openCheck() {
    setTimeout('checkIfOpened()',3000);
}
// ............... end of popup window checking ..............................

// -->
</script>
<title>Search Results</title>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-453558-10', 'auto');
  ga('send', 'pageview');

</script>
</head>
<script language="JavaScript">
<!--
document.writeln('<frameset cols="210,*" border=0 framespacing=0>');
document.write('<frame src="searchbuttons.jsp' + location.search);
document.write('" frameborder="0" marginheight="0" marginwidth="0">');

document.write('<frame src="searching.jsp' + location.search);
document.writeln('" frameborder=0 marginheight=0 marginwidth=0>"');
document.writeln('</frameset>');
// -->
</script>
</html>

