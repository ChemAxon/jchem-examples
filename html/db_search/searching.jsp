<%--
 searching.jsp
 
 ChemAxon Ltd., 1999-2004
 
 Displays all data that satisfies the query condition.
--%> 
<%@ page import="chemaxon.jchem.db.*, chemaxon.util.*,java.sql.*,
	         chemaxon.nfunk.jep.ParseException,
             chemaxon.sss.search.MolSearch, chemaxon.sss.search.JChemSearchOptions,
             chemaxon.sss.search.SearchOptions, chemaxon.sss.SearchConstants"
errorPage="errorpage.jsp" %>
<%@ include file="init.jsp" %>
<%! 

private String createFilterQuery(HttpSession session, String sessionVarPrefix,
                                 String structureTableName)
        throws SQLException, NumberFormatException
{
    // Create an SQL string for selecting the appropriate CD_IDs
    StringBuffer sql = new StringBuffer("SELECT cd_id FROM "
            + structureTableName + " WHERE ");

    // Add conditions one by one
    int condCounter=0;
    int conds = ((Integer)session.getAttribute(
                                sessionVarPrefix+"condcount")).intValue();
    for(int i=0;i<conds;i++) {
        String field=(String)session.getAttribute(
                sessionVarPrefix+
                "query.condition"+i+".field");
        String relation=(String)session.getAttribute(
                sessionVarPrefix+
                "query.condition"+i+".relation");
        String value=(String)session.getAttribute(
                sessionVarPrefix+
                "query.condition"+i+".value");
        String typeString=(String)session.getAttribute(
                sessionVarPrefix+
                "query.condition"+i+".type");
        int type=0;
        try {
            type=Integer.parseInt(typeString);
        } catch (NumberFormatException e) {}
        boolean isText=DatabaseTools.isTextType(type);
        if(value!=null && (value=value.trim()).length()>0) {
            if(isText) {
                value = "'" + value + "'";
            }
            if(condCounter>0) {
                sql.append("\nAND ");
            }
            sql.append(field+relation+value);
            condCounter++;
        }
    }
    return sql.toString();
}
%>

<%

if (session.isNew()) {
    out.println("<pre>");
    out.println("An error occured.");
    out.println("Possible couses:");
    out.println("1. Cookies are disabled in your browser. Please enable cookies.");
    out.println("2. You have tried to access searching.jsp directly. Please go to:"
            +"\n <a target=\"_parent\" href=\"index.jsp\">index.jsp</a>");
    out.println("</pre>");
    return;
}

//response.setBufferSize(20*1024);

int visit = 0;

/*
 * The following session variables are set in
 * initsearch.jsp 
 * if molfile is null, it's an "empty query"
 */
boolean mdFingerprint=false; // true, if MolecularDescriptor fingerprint
float dissimilarityThreshold=0;
int maxResultCount=0; //no limit
int searchType=JChemSearch.SUBSTRUCTURE;
String molfile=(String)session.getAttribute(sessionVarPrefix+"query.molfile");
String md_name=(String)session.getAttribute(sessionVarPrefix+"query.MDName");
String chemterm=(String)session.getAttribute(sessionVarPrefix+"query.chemterm");
String addopts = (String)session.getAttribute(sessionVarPrefix+"query.additionalOptions");
if (chemterm!=null ) {
    chemterm=chemterm.trim();
    if (chemterm.length()==0) {
        chemterm=null;
    } else {
	try {
	    MolSearch.checkFilter(chemterm);
        } catch (ParseException e) {
	    
            %>
            <html>
            	<body bgcolor="#e0e0e0">
            		<font face="helvetica">
          				<p>
            			<font size="+1" color="red"><b>
            			Chemical Terms filter error:
            			</b></font>
            			</p>
	    				<p>
	    				<%=e.getMessage()%>
	    				</p>
           				<p>
            			Please click
            			<a target="_parent" href="query.jsp?<%=request.getQueryString()%>">here</a>
           				to return to the query page.
            			</p>
            		</font>
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
    }
}
boolean returnNonHits=(String)session.getAttribute(sessionVarPrefix+"query.nonhits")!=null;
String ph=(String)session.getAttribute(sessionVarPrefix+"query.prevhits");
int[] prevHits=null; //search on previous hit list
if (ph!=null) {
    int selected=new Integer(ph).intValue();
    if (selected>0) {
        int[][] prevHitLists=(int[][]) session.getAttribute(
                sessionVarPrefix+"prevHitLists");
        prevHits=prevHitLists[selected-1];
    }
}

if (molfile!=null) {
    String dissim=(String)session.getAttribute(sessionVarPrefix+
            "query.dissimilarityThreshold");
    if (dissim!=null && dissim.length()>0) {
        dissimilarityThreshold = Float.valueOf(dissim).floatValue();
    }
    maxResultCount = Integer.parseInt(
            (String)session.getAttribute(sessionVarPrefix+
                                     "query.maxResultCount"));
    String typeString=(String)session.getAttribute(
            sessionVarPrefix+"query.type");
    if(typeString.equals("Screening")) {
        searchType = JChemSearch.NO_ABAS;
    } else if(typeString.equals("Superstructure")) {
        searchType = JChemSearch.SUPERSTRUCTURE;
    } else if(typeString.equals("Similarity")) {
        searchType = JChemSearch.SIMILARITY;

        if(md_name!=null && !md_name.equals(".embedded.")) {
            mdFingerprint=true;
        }
    } else if(typeString.equals("Full")) {
        searchType = JChemSearch.FULL;
    } else if(typeString.equals("Full fragment")) {
        searchType = JChemSearch.FULL_FRAGMENT;
    } else if(typeString.equals("Duplicate")) {
        searchType = JChemSearch.DUPLICATE;
    }
}

JChemSearchOptions searchOptions = new JChemSearchOptions(searchType);

/* Advanced search options */
String stereoChem = (String)session.getAttribute(sessionVarPrefix+"query.stereochem");
int stereoSearchType = SearchOptions.STEREO_SPECIFIC;
if (stereoChem != null) {
    if (stereoChem.equals("exact")) {
	stereoSearchType = SearchOptions.STEREO_EXACT;
    } else if (stereoChem.equals("diast")) {
	stereoSearchType = SearchOptions.STEREO_DIASTEREOMER;
    } else if (stereoChem.equals("off")) {
	stereoSearchType = SearchOptions.STEREO_IGNORE;
    }
}
String tautomerParam = (String)session.getAttribute(sessionVarPrefix+"query.tautomers");
boolean enumerateQueryTautomers = false;
if (tautomerParam != null){
    int iTautomer = new Integer(tautomerParam).intValue(); 
    enumerateQueryTautomers = (iTautomer != 0); 
}

String dbsc = (String)session.getAttribute(sessionVarPrefix+"query.doubleBondStereoCheck");
int doubleBondStereoCheck = chemaxon.struc.StereoConstants.DBS_MARKED;
if (dbsc != null){
	doubleBondStereoCheck = new Integer(dbsc).intValue(); 
}

String chargesParam = (String)session.getAttribute(sessionVarPrefix+"query.charges");
int charges = searchOptions.getChargeMatching();
if (chargesParam != null){
    charges = new Integer(chargesParam).intValue();
}

String isotopesParam = (String)session.getAttribute(sessionVarPrefix+"query.isotopes");
int isotopes = searchOptions.getIsotopeMatching();
if (isotopesParam!= null){
    isotopes = new Integer(isotopesParam).intValue();
}

String radicalsParam = (String)session.getAttribute(sessionVarPrefix+"query.radicals");
int radicals = searchOptions.getRadicalMatching();
if (radicalsParam != null){
    radicals = new Integer(radicalsParam).intValue();
}

String valenceParam = (String)session.getAttribute(sessionVarPrefix+"query.valence");
boolean valence = searchOptions.isValenceMatching();
if (valenceParam != null){
    valence = valenceParam.equals("0");
}

String vagueBondS = (String)session.getAttribute(sessionVarPrefix+"query.vaguebond");
int vagueBond = searchOptions.getVagueBondLevel();
if(vagueBondS != null){
    vagueBond=new Integer(vagueBondS).intValue();
}
/* End advanced options*/

JChemSearch searcher = (JChemSearch)session.getAttribute(
	sessionVarPrefix+"search.searcher");
String action = (String)session.getAttribute(
        sessionVarPrefix+"search.action");
if(action.equals("starting_search"))
{
    session.setAttribute(sessionVarPrefix+"search.action", "setting_search_parameters");

    /*
     * Searching molecules
     */

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

    String structureTableName = 
		    (String)session.getAttribute(sessionVarPrefix+"strTableName");

    //Check if some of the query conditions are set
    boolean conditionExists=false;
    if(session.getAttribute(sessionVarPrefix+"condcount") != null) {
	int conds = ((Integer)session.getAttribute(
				    sessionVarPrefix+"condcount")).intValue();
	for(int i=0; i<conds; i++) {
	    String value = (String)session.getAttribute(
                sessionVarPrefix+"query.condition"+i+".value");
	    if(value!=null && value.trim().length()>0) {
		conditionExists=true;
	    }
	}
    }

    String filterQuery = (conditionExists?
        createFilterQuery(session, sessionVarPrefix,
                structureTableName)
        : null);
    searchOptions.setMaxResultCount(maxResultCount);
    searchOptions.setDissimilarityThreshold(dissimilarityThreshold);
    searchOptions.setFilterQuery(filterQuery);
    int enumerateTautomers = enumerateQueryTautomers ? 1 : 0;  
    searchOptions.setTautomerSearch(enumerateTautomers);
    searchOptions.setStereoSearchType(stereoSearchType);
    searchOptions.setDoubleBondStereoMatchingMode(doubleBondStereoCheck);
    searchOptions.setChargeMatching(charges);
    searchOptions.setRadicalMatching(radicals);
    searchOptions.setIsotopeMatching(isotopes);
    searchOptions.setValenceMatching(valence);
    searchOptions.setVagueBondLevel(vagueBond);
    searchOptions.setReturnsNonHits(returnNonHits);
    searchOptions.setChemTermsFilter(chemterm);
    if (addopts != null && addopts != "") {
	searchOptions.setOptions(addopts);
    }
    
//  Molecular fingerprint similarity
    String mdConfig=(String)session.getAttribute(sessionVarPrefix+"query.MDConfig");
    if (mdConfig!=null && md_name!=null && md_name.equals(".embedded.")) {
        searchOptions.setDissimilarityMetric(mdConfig);
    }
    if (mdFingerprint) {
        //checking if MD table is valid or not:
        MDTableHandler mdh=new MDTableHandler(ch, structureTableName);
        if (!mdh.isMDTableValid(md_name)) {
            session.setAttribute(sessionVarPrefix+"MD.table.integrity.error", "true");
        } else {
            session.setAttribute(sessionVarPrefix+"MD.table.integrity.error", "false");
        }
        if (mdConfig!=null && !mdConfig.equals(".default_config.")) {
            searchOptions.setDescriptorConfig(mdh.getMDConfig(md_name, mdConfig));
        }
        searchOptions.setDescriptorName(md_name);
    } 
 
    searcher = new JChemSearch();
    searcher.setConnectionHandler(ch); 
    searcher.setQueryStructure(molfile==null? "" : molfile);    
    searcher.setStructureTable(structureTableName);
    searcher.setRunMode(JChemSearch.RUN_MODE_ASYNCH_COMPLETE);
    searcher.setInfoToStdError(true);
    searcher.setSearchOptions(searchOptions);
    if (prevHits!=null) {
        searcher.setFilterIDList(prevHits);
    }

    searcher.run(); // starts searching thread
    session.setAttribute(sessionVarPrefix+"search.searcher", searcher);
    session.setAttribute(sessionVarPrefix+"search.visit", new Integer(0));
    session.setAttribute(sessionVarPrefix+"search.action", "searching");

}
if(searcher.isRunning()) {
    visit = ((Integer)session.getAttribute(
                sessionVarPrefix+
                "search.visit")).intValue()+1;
    session.setAttribute(sessionVarPrefix+
            "search.visit", new Integer(visit));
    %>
    <html>
    <body bgcolor="#e0e0e0">
    <font face="helvetica">
    <p>
    <font size="+2" color="red"><b>
    Please wait. Searching.....
    </b></font>
    <p> <%= searcher.getProgressMessage() %>
    <p>Hits: <%= searcher.getResultCount() %> 
    <br><br>
    <font size="-1">
    Checking: <%= visit %>
    </font>
    </font>
    <%-- Timed reloading of the page if searching has not finished --%>
    <script LANGUAGE="JavaScript">
    <!--
    window.setTimeout(
            'window.location.reload(false)', 
            2000);
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
    <%
} else { // structure searching has stopped

    String clientStartTime=(String) session.getAttribute(
            sessionVarPrefix+"query.startTimeAtClient");
    //storing hits in memory if needed:
    if (searchesToRemember>0 && clientStartTime!=null) {
        //storing previous hits:
        int[][] prevHitLists=(int[][]) session.getAttribute(sessionVarPrefix+"prevHitLists");
        String[] prevHitTimes=(String[]) session.getAttribute(sessionVarPrefix+"prevHitTimes");
        if (prevHitLists==null || prevHitTimes==null) {
            prevHitLists=new int[searchesToRemember][];
            prevHitTimes=new String[searchesToRemember];
        }
        int [][] newPrevHitLists=new int[searchesToRemember][];
        String[] newPrevHitTimes=new String[searchesToRemember];
        newPrevHitLists[0]=searcher.getResults();
        newPrevHitTimes[0]=clientStartTime;
        System.arraycopy(prevHitLists, 0, newPrevHitLists, 1, searchesToRemember-1);
        System.arraycopy(prevHitTimes, 0, newPrevHitTimes, 1, searchesToRemember-1);
        prevHitLists=newPrevHitLists;
        prevHitTimes=newPrevHitTimes;
        session.setAttribute(sessionVarPrefix+"prevHitLists", prevHitLists);
        session.setAttribute(sessionVarPrefix+"prevHitTimes", prevHitTimes);
    }

    %><jsp:forward page="searchresults.jsp" /><%
}
%>

