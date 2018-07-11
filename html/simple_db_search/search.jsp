<%
/*
 * search.jsp
 *
 * ChemAxon Ltd., 1999
 *
 * A frame that retrieves the page that displays 
 * the found structures and a button page.
 */
 %> 
<%
String sessionVarPrefix="example.";

/*
 * Molfile and other input parameters will be used for searching.
 */
String molfile = (String)request.getParameter("molfile");
//Integer quantity = (Integer) new Integer(
//	Integer.parseInt(request.getParameter("quantity")));
if(molfile != null) {
    session.setAttribute(sessionVarPrefix+"query.molfile", molfile);
    session.setAttribute(sessionVarPrefix+"query.quantity", request.getParameter("quantity"));
    session.setAttribute(sessionVarPrefix+"query.type", request.getParameter("type"));
    session.setAttribute(sessionVarPrefix+"query.similarityThreshold",
	    request.getParameter("similarityThreshold"));
    session.setAttribute(sessionVarPrefix+"query.maxResultCount", request.getParameter("maxResultCount"));
    session.setAttribute(sessionVarPrefix+"search.action", "starting_search");
}
%>
<html>
<script language="JavaScript">
<!--

var contentLoaded=false
var buttonsLoaded=false

idSearchResults=1;

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
	    var param="";
	    if(location.search.lastIndexOf('gui=swing') >= 0)
		param="?gui=swing";
	    form.action="searchresults.jsp"+param;
	    form.submit();
	}
    } else
	alert("Page loading. Please wait.");
}

twIndex=0
function helpWindow()
{
    var w = window.open("sreshelp.html","sresulttips"+
	    (twIndex++).toString(),
	    "resizable=yes,width=470,height=400,scrollbars=yes,menubar=yes");
    w.focus()
}

//var progressWindow = window.open("progress.jsp","progressWindow",
//	"resizable=yes,width=200,height=150,scrollbars=no,menubar=no");
//
//function closeProgressWindow()
//{
//    if((progressWindow!=null) && !progressWindow.closed)
//	progressWindow.close();
//}
// -->
</script>

<head>
<title>Search Results</title>
</head>

<script language="JavaScript">
<!--
document.writeln('<frameset cols="210,*" border=0 framespacing=0>');
document.write('<frame src="searchbuttons.html' + location.search);
document.write('" frameborder="0" marginheight="0" marginwidth="0">');

document.write('<frame src="searchresults.jsp' + location.search);
document.writeln('" frameborder=0 marginheight=0 marginwidth=0>"');
document.writeln('</frameset>');
// -->
</script>

</html>
