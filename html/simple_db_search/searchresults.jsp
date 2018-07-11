<%
/*
 * searchresults.jsp
 *
 * ChemAxon Ltd., 1999
 *
 * Searches and displays all data that satisfies the query
 * condition specified in query.jsp.
 */
 %>
<%@ page import="
java.sql.*,
java.util.Vector,
chemaxon.jchem.db.*, 
chemaxon.util.*,
chemaxon.sss.search.JChemSearchOptions"
%>
<%@ include file="init.jsp" %>

<%
// Applet size parameters
int maxCols = 4;	    // Maximum number of columns 
int maxRows = 25;
int maxVisibleRows = 3;
int maxCells = maxCols*maxRows;
int structureWidth = 150;
int structureHeight = 150;
int cellWidth = structureWidth;
int cellHeight = structureHeight+20;

if(session.getAttribute(sessionVarPrefix+"search.action") == null) {
    %>
    <html>
    <body bgcolor="white">
    Sorry, your session has expired. Please reload the page 
    by selecting Reload (or Refresh), or run a new query.
    </body>
    </html>
    <%
    return;
}
%>
<html>
<body bgcolor="#e0e0e0" onLoad="parent.contentLoaded=true">
<%
try { 
	ConnectionHandler ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");
	
	
    //Connection con = (Connection)session.getAttribute(sessionVarPrefix+"search.con");
    //if(con == null || con.isClosed() || !DatabaseTools.isConnectionAlive(con)) {
    if((ch==null)||(!ch.isConnected())) {
	/*
	 * Initializing the database connection
	 */
	 
	 ch = new ConnectionHandler();
 	 ch.setDriver(driver);
 	 ch.setUrl(url);
 	 ch.setLoginName(username);
 	 ch.setPassword(password);
 	 ch.setPropertyTable(propertyTableName);

     	ch.connectToDatabase();

	session.setAttribute(sessionVarPrefix+"ch",ch);

	/*Class.forName (driver).newInstance();
	con = DriverManager.getConnection(url, username, password);

	session.setAttribute(sessionVarPrefix+"search.con", con);*/
    }
    
    Connection con=ch.getConnection();

    int pageNumber;		    // page to be shown
    int visit = 0;

    boolean pageReloadingNeeded = true;
    JChemSearch searcher = (JChemSearch) session.getAttribute(
            sessionVarPrefix+"search.searcher");

    /*
     * The following session variables are set in
     * search.jsp 
     */
    float similarityThreshold = 1;
    String molfile=(String)session.getAttribute(sessionVarPrefix+"query.molfile");
    int maxResultCount = Integer.parseInt(
	    (String)session.getAttribute(sessionVarPrefix+"query.maxResultCount"));
    String typeString=(String)session.getAttribute(sessionVarPrefix+"query.type");
    int searchType=JChemSearch.SUBSTRUCTURE;
    if(typeString.equals("Screening")){
	searchType = JChemSearch.NO_ABAS;
    }
    else if(typeString.equals("Similarity")){
	searchType = JChemSearch.SIMILARITY;
	similarityThreshold = Float.valueOf(
		(String)session.getAttribute(sessionVarPrefix+"query.similarityThreshold")).floatValue();
    }
    else if(typeString.equals("Superstructure")){
	searchType = JChemSearch.SUPERSTRUCTURE;
    }
    else if(typeString.equals("Full")){
	searchType = JChemSearch.FULL;
    }
    else if(typeString.equals("Full Fragment")){
	searchType = JChemSearch.FULL_FRAGMENT;
    }
    else if(typeString.equals("Duplicate")){
	searchType = JChemSearch.DUPLICATE;
    }
    
    String action = (String)session.getAttribute(sessionVarPrefix+"search.action");
    if(action.equals("starting_search"))
    {
	session.setAttribute(sessionVarPrefix+"search.action", "searching");
	session.setAttribute(sessionVarPrefix+"search.visit", new Integer(0));

	/*
	 * Setting search options 
	 */
	JChemSearchOptions searchOptions = new JChemSearchOptions(searchType);
	searchOptions.setMaxResultCount(maxResultCount);
	if(typeString.equals("Similarity")){
	    searchOptions.setDissimilarityThreshold(1.0f - similarityThreshold);
        }
	
	/*
	 * Searching molecules, collecting the cd_id-s of
	 * of found items into a Vector.
	 */
	searcher = new JChemSearch();
        searcher.setQueryStructure(molfile);
        searcher.setConnectionHandler(ch);
        searcher.setStructureTable(structureTableName);
        searcher.setSearchOptions(searchOptions);
	searcher.setInfoToStdError(true);
	searcher.setRunMode(JChemSearch.RUN_MODE_ASYNCH_COMPLETE);


	searcher.run();
	session.setAttribute(sessionVarPrefix+"search.searcher", searcher);
    }
    if(searcher.isRunning()) {
	visit = ((Integer)session.getAttribute(sessionVarPrefix+"search.visit")).intValue()+1;
	session.setAttribute(sessionVarPrefix+"search.visit", new Integer(visit));
	%>
	<font face="helvetica">
	<p>
	<font size="+2" color="red"><b>
	Please wait. Searching.....
	</b></font></p>
	<p> <%= searcher.getProgressMessage() %></p>
	<p>Hits: <%= searcher.getResultCount() %> </p>
	<br><br>
	<font size="-1">
	Checking: <%= visit %>
	</font>
	</font>
	<%
    } else { // searching has stopped
	pageReloadingNeeded=false;
	int[] foundItems=searcher.getResults();

	if(action.equals("searching")) {
	    /*
	     * Searching has finished. Let us
	     * see the first page
	     */
	    Throwable e = searcher.getException();
	    if(e!=null)
		throw e;
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
	int pages = maxCells*(searcher.getResultCount()/maxCells) == searcher.getResultCount() ?
		searcher.getResultCount()/maxCells : searcher.getResultCount()/maxCells + 1;

	if(pages==pageNumber) pageNumber--;

	int start = pageNumber * maxCells;    //the row in the result set that
					//belongs to the first cell

	if(start>searcher.getResultCount()) {
	    pageNumber = pages-1;
	    start = pageNumber * maxCells;
	} else if(start<0) {
	    pageNumber=0;
	    start=0;
	}
	int cells = searcher.getResultCount() - start<maxCells ? 
		searcher.getResultCount() - start : maxCells;
	int rows = maxCols*(cells/maxCols) == cells?
		cells/maxCols : cells/maxCols + 1; 
	int visibleRows = rows<maxVisibleRows? rows : maxVisibleRows;
	int cols = cells<maxCols ? cells : maxCols;
	if(searcher.getResultCount() == 0) {
	    %>
	    <p>No structures found</p>
	    <%
	} else { // There are items to display
	    %>
	    <table width="100%"><tr>
	    <td><font face="helvetica">
	    Hits: <%= searcher.getResultCount() %>&nbsp;
	    <font size="1">
	    <%= searcher.isMaxResultCountReached()? " (maximum hits reached)" : "" %>
	    <%= searcher.isMaxTimeReached()? " (maximum time reached)" : "" %>
	    </font>
	    </font></td>
	    <td align="right"><font face="helvetica">
	    Page: <%= pageNumber+1 %>/<%= pages %> 
	    </font></td>
	    </tr></table>
	    <form method="post" name="navigationForm">
	    <input type="hidden" name="pageNumber" value="<%= pageNumber+1 %>">
	    <input type="hidden" name="nextState">
	    </form>

	    <center>
	    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js">
	    </script>
	    <script LANGUAGE="JavaScript1.1">
	    <!--
	    mview_name="mview";
	    mview_begin("../../marvin",
		    "<%= cols*cellWidth+cols-1 %>",
		    "<%= visibleRows*cellHeight+visibleRows-1 %>");
	    mview_param("rows", "<%= rows %>");
	    mview_param("cols", "<%= cols %>");
	    mview_param("visibleRows", "<%= rows>visibleRows?visibleRows:rows %>");
	    mview_param("navmode", "rot3d");
	    mview_param("molbg", "#000000");
	    mview_param("bgcolor", "#e0e0e0");
	    mview_param("border", "1");
	    mview_param("animate", "0");
	    mview_param("layout", ":3:1:"+
		"L:0:0:1:1:w:n:0:10:"+ <%/* ID              */%>
		"M:1:0:1:1:c:n:1:10"); <%/* Molecule        */%>
	    mview_param("param", ":"+
		"L:11b:"+
		"M:<%= structureWidth %>:<%= structureHeight %>");
	    <%
	    /*
	     * Writing data into the cells in the applet
	     */
	    int cellIndex=0;
            String sql =
			"SELECT " +
			structureTableName + ".cd_id, "+
			structureTableName + ".cd_structure  " +
			"FROM "+ structureTableName +
			" WHERE " +
			structureTableName + ".cd_id = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            try {
                for(int i=start; i<start+cells; i++) {
                    int id = foundItems[i];
                    /*
                     * SQL statement for retrieving structures
                     */
                    pstmt.setInt(1,id);
                    ResultSet rs = pstmt.executeQuery();
                    try {
                        if(rs.next()) {
                            String dbMolfile = new String(DatabaseTools.readBytes(rs, 2),"ASCII");
                            %>
                            mview_param("cell<%= cellIndex %>",
                                "|ID: <%= id %>"+
                                "|<%= HTMLTools.convertForJavaScript(
                                    dbMolfile) %>");
                            <%
                        }
                    } finally {
                        rs.close();
                    }
                    cellIndex++;
                }
            } finally {
                pstmt.close();
            }
	    %>
	    mview_end();
	    //-->
	    </script>
	    </center>
<script LANGUAGE="JavaScript">
<!--
//alert("Search completed");
//-->
</script>
	    <%
	}
    }
    if(pageReloadingNeeded) {
	%>
	<script LANGUAGE="JavaScript">
	<!--
	window.setTimeout(
		'window.location.reload(false)', 2000 );
	//-->
	</script>
	<%
    }
} catch(Throwable e) {
    /* 
     * In case of error, the script displays the error message(s)
     * and returns.
     */
    e.printStackTrace();
    if(e.getMessage()==null) {
	// Null pointer exceptions caused by an error in JRun
	// when reading session variables
	%><p>The server might be too busy. Please reload the page.<%
    } else {
	try {
	    %><%= HTMLTools.exceptionToString(e) %><%
	} catch(Throwable nf) {
	    %>Error: JChem repository not found<%
	}
    }
}
%>
</body>
</html>

