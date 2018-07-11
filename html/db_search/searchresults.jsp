<%
/*
 * searchresults.jsp
 *
 * ChemAxon Ltd., 1999-2004
 *
 * Searches all data that satisfies the query condition.
 */
 %> 
<%@ page import="
java.sql.*,
java.text.DecimalFormat,
java.awt.*,
chemaxon.jchem.db.*, 
chemaxon.util.*,
chemaxon.struc.*,
chemaxon.descriptors.*,
chemaxon.formats.*,
chemaxon.sss.search.*,
chemaxon.enumeration.MolEnumerator,
chemaxon.sss.SearchConstants,
chemaxon.reaction.Standardizer"
errorPage="errorpage.jsp"
%>
<%@ include file="init.jsp" %>
<%!
/**
 * Creates marvin cell strings
 * @param index the index of the marvin cell (0..n-1)
 * @param source the molecule in SMILES or MOLfile format
 * @param dataFieldNames the name of the data fields, String objects
 * @param dataFieldValues the value of the data fields
 * @param layout the name of the custom layout, or "default", or "defaultall"
 * @param dissim the dissimilarity value if dissimilarity search, otherwise -1
  */
String[] getCellParams(int index, String source, java.util.List dataFieldNames,
                    Object[] dataFieldValues, String layout, float dissim) {
    java.util.List params = new ArrayList();
    int fieldCount=dataFieldNames.size();
    if(layout.startsWith("default")) {
        params.add(source);
	boolean showDisSim = true;
	for(int i=0;i<fieldCount;i++) {
            String propName = (String)dataFieldNames.get(i);
            Object propValue= dataFieldValues[i];
	    String pre = "";
	    if(propName.toLowerCase().equals("cd_id")) {
		pre = "ID: ";
	    } else if(
		propName.toLowerCase().equals("cd_molweight")) {
		pre = "MW: ";
	    } else 
		if(propName.toLowerCase().equals("cd_formula")) {
		    pre = "";	
	    } else {
		if(propName.toString().length() <= 10) {
		    pre = propName + ": ";
		} else {
		    pre = propName.substring(0, 10) + ": ";
		}
	    }
            //dissimilariy comes before user fields:
	    if(showDisSim && 
		    !propName.toLowerCase().startsWith("cd_")) {
                showDisSim = false;
                if (dissim != -1) {
                    params.add("DISS: "+ dissim);
                }
	    }
	    if(propValue != null) {
		    params.add(pre + propValue.toString());
	    } else {
                params.add("");    
            }
	}
        if(showDisSim) {//dissimilarity wasn't displayed yet
            params.add(dissim == -1? "" : "DISS: "+ dissim);
        }
    } else {
	StringTokenizer st = new StringTokenizer(layout, ";");
	while(st.hasMoreTokens()) {
	    String field = st.nextToken();
	    int start = field.indexOf("<");
	    int end = field.indexOf(">");
	    int def = field.indexOf("#");
	    String pre = field.substring(0, start);
	    String fieldname = field.substring(start + 1, end).toLowerCase();
	    String post = field.substring(end + 1);
	    String defaultv = "";
	    if(def > -1) {
		post = field.substring(end + 1, def);
		defaultv = field.substring(def + 1);
	    }
	    if(fieldname.equals("$cd_structure")) {
		params.add(source);
	    } else if(fieldname.equals("$dissimilarity")) {
		params.add((dissim == -1? defaultv : pre + dissim + post));
	    } else {
		for(int i=0;i<fieldCount;i++) {
            String propName = (String)dataFieldNames.get(i);
            Object propValue= dataFieldValues[i];
            //propValue = propValue.toString().substring(0,19)+"...";
            if(propName.toLowerCase().equals(fieldname.toLowerCase())) {
			if(propValue != null) {
			    params.add(pre + propValue.toString() + post);
			} else {
			    params.add(defaultv);
			}
		    }
		}
	    }
	}
    }
    String[] result = new String[params.size()];
    for (int x=0; x< params.size() ; x++) {
        result[x] = (String) params.get(x);
    }
    return result;
}

%>

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


String structureTableName =
    (String)session.getAttribute(sessionVarPrefix+"strTableName");
String queryType=(String)session.getAttribute(sessionVarPrefix+"query.type");        

ConnectionHandler ch =
	    (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");
Connection con=ch.getConnection();

DatabaseProperties dbProp = new DatabaseProperties(ch);        
int tableType=dbProp.getTableType(structureTableName);
boolean reactionTable = tableType == UpdateHandler.TABLE_TYPE_REACTIONS;           
boolean markushTable = tableType == UpdateHandler.TABLE_TYPE_MARKUSH_LIBRARIES;           
        
String param=request.getParameter("enumMarkush");
if (param!=null) {
    session.setAttribute(sessionVarPrefix+"enumerateMarkush", Boolean.TRUE);        
} else {
    session.setAttribute(sessionVarPrefix+"enumerateMarkush", Boolean.FALSE);
}
        
boolean enumerateMarkush= false;        
Boolean enumMarkush = 
        (Boolean)session.getAttribute(sessionVarPrefix+"enumerateMarkush");
if (enumMarkush!=null) {
    enumerateMarkush=enumMarkush.booleanValue();
}
if (queryType.equals("Similarity")) {
    enumerateMarkush=false;
}
        
boolean showRgroups= true;
if (markushTable){
    showRgroups=false;
    param=request.getParameter("showRgroups");
    if (param!=null) {
        session.setAttribute(sessionVarPrefix+"showRgroups", Boolean.TRUE);        
    } else {
        session.setAttribute(sessionVarPrefix+"showRgroups", Boolean.FALSE);
    }
    Boolean showRg = 
        (Boolean)session.getAttribute(sessionVarPrefix+"showRgroups");   
    if (showRg!=null) {
	showRgroups=showRg.booleanValue();
    } 
}

// Parameters of hit coloring

param=request.getParameter("subhitcolor");
String hitColoringParam = request.getParameter("hitColoringState");
boolean hitColoringState = true;
if (hitColoringParam!=null){
	if (!hitColoringParam.equals("0")){
	//if ((param!=null) || ((param==null) && (sessionParam==null)) || ((request.getParameter("pageNumber")==null) && (sessionParam==Boolean.TRUE))){
	    session.setAttribute(sessionVarPrefix+"subhitcolor", Boolean.TRUE); 
	} else {
	    session.setAttribute(sessionVarPrefix+"subhitcolor", Boolean.FALSE);	    
	}
}

boolean showHitColoring=true; //default
Boolean showHc = 
        (Boolean)session.getAttribute(sessionVarPrefix+"subhitcolor");
if (showHc!=null) {
	showHitColoring=showHc.booleanValue();
}

//Parameters of hit alignment and partial clean

param=request.getParameter("hitAlignmentOrClean");
if (param!=null) {
    session.setAttribute(sessionVarPrefix+"hitAlignmentOrClean", param);        
} else {
    session.setAttribute(sessionVarPrefix+"hitAlignmentOrClean", "hitAlignment");
}
        
boolean hitAlignment = false;
boolean partialClean = false;
String alignmentMode = 
        (String)session.getAttribute(sessionVarPrefix+"hitAlignmentOrClean");
if (alignmentMode.equals("hitAlignment")) {
	hitAlignment =true;
}      
else if (alignmentMode.equals("partialClean")) 
	partialClean = true;
	

//for backwards compatibility : reaction tables specified by the user 
if (reactionTables!=null) {
    StringTokenizer st=new StringTokenizer(reactionTables, ";");
    while (st.hasMoreTokens()) {
        String rTable=st.nextToken();
        if (structureTableName.equals(rTable)){
            reactionTable=true;
        }
    }
}

// Applet size parameters
String viewForm = 
	    (String)session.getAttribute(sessionVarPrefix+"viewForm");
	    
int maxCols, maxRows; // Maximum number of rows, maximum number of columns

if (reactionTable){ 
    maxCols=1;
    maxRows = 6;
}
else if (markushTable){
    maxCols=2;
    maxRows = 2;
}
else {
    maxCols=3; 
    maxRows = 6;
}
    
int cellWidth = reactionTable ? 3*250 : 250;
int cellHeight = 160;
if(!viewForm.startsWith("default")) {
    maxCols = Integer.parseInt(props.getProperty(viewForm+".cols"));
    maxRows = Integer.parseInt(props.getProperty(viewForm+".rows"));  
    String cellDim = props.getProperty(viewForm+".celldim");
    cellWidth = Integer.parseInt(cellDim.substring(0, cellDim.indexOf(":")));
    cellHeight = Integer.parseInt(cellDim.substring(cellDim.indexOf(":")+1));
}

int maxCells = maxCols*maxRows;

if(session.getAttribute(sessionVarPrefix+"search.action") == null) {
    %>
    <html>
    <body bgcolor="white">
    Sorry, your session has expired. Please reload the page 
    by selecting Reload (or Refresh), or run a new query.
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-453558-10', 'auto');
  ga('send', 'pageview');

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
    <%
    return;
}

int pageNumber;         // the number of the page to be shown

JChemSearch searcher = (JChemSearch)session.getAttribute(
	    sessionVarPrefix+"search.searcher");
String action = (String)session.getAttribute(
        sessionVarPrefix+"search.action");
if(action.equals("searching")) {
    searcher.waitUntilSearchComplete();
    /*
     * Searching has finished. Let's
     * see the first page
     */
    searcher.checkException();
    session.setAttribute(sessionVarPrefix+"search.action","paging");
    pageNumber = 0;
} else {
    /*
     * It seems we have already visited the first page
     * of the results.
     * Retrieving search results from session variables.
     */
    if(request.getParameter("pageNumber")==null)
        pageNumber = 0;
    else
        pageNumber = Integer.parseInt(request.getParameter("pageNumber"))-1;
    String event = (String)request.getParameter("nextState");
    if(event==null || event.equals("first"))
        pageNumber = 0;
    else if(event.equals("last"))
        pageNumber = 1000000;
    else if(event.equals("left"))
        pageNumber--;
    else if(event.equals("right"))
        pageNumber++;
}


/*
 * Initializing the molecule table applet
 */
int start = pageNumber * maxCells;    //the row in the result set that
                                      //belongs to the first cell
int pages = (int)Math.ceil(((double)searcher.getResultCount())/maxCells);
int resultCount = searcher.getResultCount();

if(start<0 || resultCount==0) {
    pageNumber=0;
    start=0;
}
else if(start>=resultCount) {
    pageNumber = pages-1;
    start = pageNumber * maxCells; 
}
int cells = searcher.getResultCount() - start<maxCells ?
        searcher.getResultCount() - start : maxCells;
int rows = maxCols*(cells/maxCols) == cells?
        cells/maxCols : cells/maxCols + 1;
int cols = cells<maxCols ? cells : maxCols;

      

//Collectiong cd_id values of Markush structures:
java.util.List markushList=new ArrayList();
String sql = "SELECT cd_flags FROM "+
     structureTableName +" WHERE " +
     structureTableName + ".cd_id = ?";
PreparedStatement pstmt=con.prepareStatement(sql);
for(int i=start; i<start+cells; i++) {
    int id = searcher.getResult(i);
    pstmt.setInt(1, id);
    ResultSet rs = pstmt.executeQuery();
    if (rs.next()) {
        String flags=rs.getString(1);
        if (flags!=null && flags.indexOf('m')!=-1) {
            markushList.add(new Integer(id));
        }
    }
    rs.close();
}
pstmt.close();




%>
<html>
<head>
<script language="JavaScript">
<!--

function alertMDTableIntegrity() {
<%
    String mdErr=(String)session.getAttribute(sessionVarPrefix+
            "MD.table.integrity.error");
    if (mdErr!=null && mdErr.equals("true")) {
        //will only show at first page:
        session.setAttribute(sessionVarPrefix+"MD.table.integrity.error", "false");
    %>
        alert("Warning: some structure table rows are not represented in"+
            " Molecular Descriptor table\nRegeneration of descriptor table is"+
            " recommended");
    <%
    }
%>
}


<%
    String elements=new String();
    for (int i=0; i<markushList.size(); i++) {
        if (i>0) {
            elements+=(", ");
        }
        elements+="'"+markushList.get(i)+"'";
    }
%>
var markushList=new Array(<%=elements%>);

function enumerateMarkush(moreHits) {
    if (moreHits == null) {
	moreHits = false;
    }
    var mview = document["mview"];
    var index = (mview==null? -1 : mview.getSelectedIndex());
    if(index<0) {
	alert("Please select a structure first.");
        return;
    }
    var id=parent.ids[index];
    var contains=false;
    for (x=0; x<markushList.length; x++){
        if (markushList[x]==id) {
            contains=true;
            break;
        }
    }
    if (contains!=true) {
        alert("The selected structure is not a Markush structure.");
        return;
    }
    form=document["markushForm"];
    form.cd_id.value=id;
    form.action="markushoptions.jsp"+location.search;
    if (moreHits == true) {
	form.action += "&moreHits";
    }
    form.target="_blank";
    form.submit();
}

function markushDisplayOptionChanged() {
    var form=document["navigationForm"];
    form.submit();
}

function ColoringAndAlignmentOptionChanged() {
    var form=document["navigationForm"];
    var hitColoringState=form.hitColoringState;
    if (form.subhitcolor.checked==true)
      hitColoringState.value=1
    else
      hitColoringState.value=0
    form.submit();
}

function restoreOptions() {
    var form=document["navigationForm"];
    if (form.enumMarkush) {
        form.enumMarkush.checked=<%=enumerateMarkush%>;
    }
    if (form.showRgroups) {
        form.showRgroups.checked=<%=showRgroups%>;
    }
    
    if (form.subhitcolor) {
        form.subhitcolor.checked=<%=showHitColoring%>;
    }
}

// -->
</script>
</head>
<body bgcolor="#e0e0e0" onLoad="parent.contentLoaded=true;restoreOptions();alertMDTableIntegrity()">
<form method="post" name="navigationForm">
<%
java.util.List dataFieldNames = new ArrayList();

int viewRows = 0;  //total number of fields displayed
//user defined fields (not beginning with "cd_"),displayed *under* the structure
int userRows = 0;

String viewLayout = "";
String viewParam = "";
String viewCell = "";

java.util.List<String> typeList = new ArrayList<String>();
java.util.List<String> fieldList = DatabaseTools.getFieldNames(ch, 
					    structureTableName, typeList);

int[] fieldTypes = DatabaseTools.getFieldTypes(ch, structureTableName);

if(viewForm.startsWith("default")) { //"default" or  "defaultall"
    viewCell = viewForm;
    for(int i=0;i<fieldList.size();i++) {
        int type=fieldTypes[i];
        String field = (String)fieldList.get(i);
        boolean displayable=DatabaseTools.isIntType(type) || 
                DatabaseTools.isRealType(type) || DatabaseTools.isTextType(type);
        if (!displayable) {
            continue;   //non-displayable type 
        }

	boolean showField = false;
	if(viewForm.equals("defaultall")) {
	    showField = true; //adding all fields in the first step
	    if(!field.toLowerCase().startsWith("cd_")) {
		userRows++;
	    }
	} else if(field.toLowerCase().startsWith("cd_")) {
	    showField = true;
	}
    //adding fields except fingerprints and smiles: 
	if(showField && 
				(field.toLowerCase().equals("cd_id") ||
				 field.toLowerCase().equals("cd_molweight") ||
				 field.toLowerCase().equals("cd_formula") ||
				 (!FieldInfo.isReservedColumnName(field))
				)) {
			dataFieldNames.add(field);
            viewRows++;
		}
    }

    if (queryType.equals("Similarity")){
    	++viewRows;
    }

    //currently cannot be 0, this line is for future use:
    int rowNumber=viewRows==0 ? 1 : viewRows; //total number of rows in layout
    viewLayout = ":"+(rowNumber)+":2:M:0:0:"+(rowNumber-userRows)+
		    ":1:n:n:1:10:";
    int col = 1; //the column number where the label starts
    int fwidth = 1; //the width of the label in columns
    for(int i=0;i<viewRows;i++) {
	if(i>=(viewRows-userRows)) { //user fields _below_ the structure
	    col = 0;
	    fwidth = 2;
	}
        if (i>0) {
            viewLayout += ":";
        }
	viewLayout += "L:"+i+":"+col+":1:"+fwidth+":nw:n:0:10";
    }

    viewParam = ":M:150:150:";
    if (reactionTable) {
        viewParam = ":M:650:150:";
    }
    for(int i=0;i<viewRows;i++) {
        if (i>0) {
            viewParam += ":";
        }
	viewParam += "L:10";
    }
    

    cellHeight += userRows * 12;
} else {  //user-defined layout
    viewLayout = props.getProperty(viewForm+".layout");
    viewParam = props.getProperty(viewForm+".param");
    viewCell = props.getProperty(viewForm+".cell");

    for(int i=0;i<fieldList.size();i++) {
	String field = (String)fieldList.get(i);
	boolean showField = false;
	if(viewCell.toLowerCase().indexOf("<"+field.toLowerCase()+">") != -1) {
            showField = true;
            viewRows++;
	    if(field.toLowerCase().equals("cd_id")) {
	    }
	}
	if(showField || field.toLowerCase().startsWith("cd_id") ) {
	    dataFieldNames.add(field);
	}
    }
}

    boolean noHitColoring = false;
    boolean noAlignment = false;
    
if(searcher.getResultCount() == 0) {
    %>
    <table width="100%"><tr>
    <td width='40%' align='left'><font face="helvetica">
    No structures found
    </font></td>
    <td align="left">Structure table: <b><%=structureTableName%></b></td>
    </tr></table>
    <%
} else { // There are items to display
    if((ch==null)||(!ch.isConnected())) {
    	ch = new ConnectionHandler();
    	ch.setDriver((String)v.elementAt(2));
    	ch.setUrl((String)v.elementAt(3));
    	ch.setLoginName((String)v.elementAt(0));
    	ch.setPassword((String)v.elementAt(1));
    	ch.setPropertyTable((String)v.elementAt(4));

        ch.connectToDatabase();

	session.setAttribute(sessionVarPrefix+"ch",ch);
    }

     
    %>
    <table width="100%">
    <tr>
    <td><font face="helvetica">
    Hits: <%= searcher.getResultCount() %>
    </font></td>
    <td align="center">Structure table:</td>
    <td align="right"><font face="helvetica">
    Page: <%= pageNumber+1 %>/<%= pages %>
    </font></td>
    </tr>
    <tr>
    <td width="30%">
    <%= searcher.isMaxResultCountReached()?
            " (maximum hits reached)" : "" %>
    <%= searcher.isMaxResultCountReached()
        && searcher.isMaxResultCountReached() ? "<br>" : "" %>
    <%= searcher.isMaxTimeReached()?
            " (maximum time reached)" : "" %>
    </td>
    <td align="center"><b><%=structureTableName%></b></td>
    <td align="right" width="30%">
    <%= " Search took "+searcher.getSearchTime()/1000.0+" seconds."%>
    </td></tr>
    <%
//  initialization of Molecular Descriptor coloring (e.g. pharmacohpore colors)
    Color[] atomSetColors=null;  // no coloring, if value is null
    boolean descriptorColoring=false; //true, if descriptor coloring is needed
    boolean substructureColoring=false; //true, if hit coloring is needed
    String mdName = null;
    
    MolecularDescriptor descriptor=null;
    if (queryType!=null) {
        if (queryType.length()==0) {
            enumerateMarkush=false; //retreive all
        }
        if (queryType.equals("Similarity")){
        	mdName  =(String)session.getAttribute(sessionVarPrefix+"query.MDName");

            if(mdName!=null && !mdName.equals(".embedded.")) {
                MDTableHandler mdth=new MDTableHandler(ch, structureTableName);
                descriptor=mdth.createMD(mdName);
                String mdConfig=(String)session.getAttribute(sessionVarPrefix+"query.MDConfig");
                if (mdConfig!=null && !mdConfig.equals(".default_config.")) {
                    descriptor.setScreeningConfiguration(
                            mdth.getMDConfig(mdName, mdConfig));
                }
                if(showHitColoring)
                {
                    atomSetColors=descriptor.getAtomSetColors();
                    descriptorColoring=true;
                }
            }
        } else if (queryType.equals("Substructure")
                    || queryType.equals("Full fragment")
                    || queryType.equals("Superstructure")
                    || (queryType.equals("Full") && (tableType == UpdateHandler.TABLE_TYPE_MARKUSH_LIBRARIES))) {
                //coloring:
                if(showHitColoring) {                    
                    substructureColoring=true;
                }           	
        }
    }
    
    String queryString = 
        (String) session.getAttribute(sessionVarPrefix+"query.molfile");
    boolean isQueryString = false;
    MolHandler mh = null;
    if ((queryString != null) && !queryString.equals("")){
    	isQueryString = true;
    	mh = new MolHandler(queryString);
    }
    
    if ((queryType.length() != 0) && isQueryString && (session.getAttribute(sessionVarPrefix+"query.nonhits") == null) && (mh.getAtomCount()>=1)){
    noHitColoring = (queryType.equals("Full") && !markushTable) || queryType.equals("Duplicate") || (queryType.equals("Similarity") && ((mdName == null) || mdName.equals(".embedded.")));
    noAlignment = queryType.equals("Superstructure") || queryType.equals("Full") || queryType.equals("Similarity");
    %>
    <tr>
    	<td colspan="3">
    	<% if (!noHitColoring) { %>
    	  Hit coloring: <input type="checkbox" id="subhitcolor" name="subhitcolor" onclick="ColoringAndAlignmentOptionChanged()" value="">&nbsp;&nbsp;&nbsp;&nbsp;
    	<% }
    	if (!noAlignment) {
    	  String disabled = "";
    	%>
    	  Alignment: <select id="hitAlignmentOrClean" name="hitAlignmentOrClean" onchange="ColoringAndAlignmentOptionChanged()" <%= disabled %>>
    	    <option value="hitAlignment" <%= hitAlignment ? "selected" : "" %>>Hit alignment</option>
    	<%
    	if (!markushTable) {
    	%>
    	    <option value="partialClean" <%= partialClean ? "selected" : "" %>>Partial clean</option>
    	<% } %>    
    	    <option value="none" <%= (!partialClean && !hitAlignment) ? "selected" : "" %>>None</option>
    	  </select>
    	<% } %>
     	</td>
    </tr>
    <% } %>
    </table>
    <input id="hitColoringState" name="hitColoringState" type="hidden" value="2">
    <%
    
    if (descriptorColoring) {%>
        <br>
        <input type=button value="Legend / query structure"  onClick="window.open ('legend.jsp?<%=request.getQueryString()%>', 'newWin', 'resizable=yes,scrollbars=yes,status=yes,height=<%=atomSetColors==null ? 400 : 600%>,width=500')">
        <br><br>
    <%}
    if (markushList.size()>0) {%>
        <br>
        <table width="100%">
            <tr>
<%
        boolean noReductionToHit =queryType.equals("Simliarity") || queryString==null
                || queryString.length()==0;
%>                
                <td align="left">
                    <p><input name="enumMarkush" type="<%= noReductionToHit ? "hidden" : "checkbox"%>"
                    onClick="javascript:markushDisplayOptionChanged()">
<%
        if (!noReductionToHit) {
%>                    
                    Show Markush structure reduction to a hit of the last query
                    <input name="moreHits" type=button value="More hits for selected..." onClick="javascript:enumerateMarkush(true)" />
<%
        }        
%>                    
                </p><td>
                <td align="right" >
                    <input type=button value="Enumerate a Markush structure"  onClick="javascript:enumerateMarkush()">
                </td>
            </tr>
            <tr>
                <td align="left">
                    <input name="showRgroups" type="checkbox"  
                    onClick="javascript:markushDisplayOptionChanged()">
                    Show R-group definitions of Markush structures
                </td>    
            </tr>
        </table>
        <br><br>
    <%}
    %>
    <center>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js">
    </script>
    <script LANGUAGE="JavaScript1.1">
    <!--
    mview_name="mview";
    mview_begin("../../marvin",
            "<%= cols*cellWidth+cols-1 %>",
            "<%= rows*cellHeight+rows-1 %>");
    mview_param("rows", "<%= rows %>");
    mview_param("cols", "<%= cols %>");
    mview_param("bgcolor", "#e0e0e0");
    mview_param("border", 1);
    mview_param("layout", "<%=viewLayout%>");
    mview_param("param", "<%=viewParam%>");
    mview_param("rgroupsVisible", "<%=showRgroups%>");
    <%
    /*
     * Writing data into the cells in the applet
     */
    int cd_ids[] = new int[cells]; //cd_id value
    int cellIndex=0;
    for(int i=0; i<cells; i++) {
        cd_ids[i] = searcher.getResult(start+i);
    }
    HitColoringAndAlignmentOptions options=
                new HitColoringAndAlignmentOptions();
    options.coloring = !noHitColoring 
            && (substructureColoring || descriptorColoring);
    options.enumerateMarkush = enumerateMarkush;
    options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_OFF;
    if (!noAlignment) {
        if (hitAlignment)
            options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_ROTATE;
        else if (partialClean)
            options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_PARTIAL_CLEAN;
    }
    		
    java.util.List dataFieldValues = new ArrayList();
    Molecule[] mols = searcher.getHitsAsMolecules(cd_ids, options,
            dataFieldNames, dataFieldValues);
    
    
    
    for(int i=0; i<mols.length; i++) {
        
	float disSim = -1;
	if(searcher.getSearchOptions().getSearchType() == JChemSearch.SIMILARITY) {
		disSim = searcher.getDissimilarity(start+i);
	}
        Molecule mol=mols[i];
        
        if(mol != null) {
            String source = mol.toFormat("mrv");
        String[] cellParams = getCellParams(cellIndex, source,
            dataFieldNames, (Object[])dataFieldValues.get(i), viewCell, disSim);
            for (int x=0; x< cellParams.length ; x++) {
            
                String paramName =  "cell" + cellIndex + "_" + x;
                %>
    mview_param("<%=paramName%>", "<%=HTMLTools.convertForJavaScript(cellParams[x])%>");
                <%
            }
        } else {
            %>
            mview_param("cell<%= cellIndex %>_0", "");
            mview_param("cell<%= cellIndex %>_1", "DELETED");
            <%
        }
        cellIndex++;
    }
    String idStr = "";
    for(int i=0;i<cells;i++) {
	idStr += cd_ids[i];
	if(i<cells-1) {
	    idStr += ",";
	}
    }
    
    %>
    mview_param("viewmolbg2d", "#ffffff");
    mview_param("viewmolbg3d", "#000000");
    mview_end();
    parent.ids = new Array(<%= idStr %>,-1);
    parent.labelCountInACell = '<%= viewRows %>';
    parent.formCellParam = '<%= viewCell %>';
    //-->
    </script>
    </center>
    <%
}
%>


    <input type="hidden" name="pageNumber" value="<%= pageNumber+1 %>">
    <input type="hidden" name="nextState">
</form>

<form method="post" name="markushForm">
    <input type="hidden" name="cd_id" >
</form>

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-453558-10', 'auto');
  ga('send', 'pageview');

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
