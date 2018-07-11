<%@ page import="chemaxon.util.ConnectionHandler,
                 java.sql.Connection,
                 chemaxon.struc.Molecule,
                 chemaxon.marvin.calculations.MarkushEnumerationPlugin,
                 chemaxon.sss.search.MolSearch,
                 chemaxon.jchem.db.JChemSearch,
                 chemaxon.jchem.db.cdmarkush.CDMarkushHandlerCache.ThreadSafety,
                 chemaxon.jchem.db.cdmarkush.CDMarkushHandlerCache.CacheBehavior,
                 chemaxon.jchem.db.cdmarkush.CDMarkushHandlerCache,
                 chemaxon.jchem.db.cdmarkush.CDMarkushFromDB,
                 chemaxon.sss.SearchConstants,
                 chemaxon.struc.MolBond,
                 chemaxon.formats.MolExporter,
                 chemaxon.struc.MDocument,
                 chemaxon.sss.search.MolSearchOptions,
                 chemaxon.util.HitColoringAndAlignmentOptions,
                 chemaxon.util.HitDisplayTool"%>
<%@ page import="java.awt.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="init.jsp" %>
<html>
  <head><title>Markush enumeration</title></head>
  <body>
<%
    String cd_id=request.getParameter("cd_id");
    String countString=request.getParameter("count");
    String modeString=request.getParameter("type");
    String maxCountString=request.getParameter("maxCount");
    
    boolean reductionToHit =false;
    if (modeString!=null && modeString.equals("Reduction")) {
        reductionToHit =true;
    }
    
    boolean randomEnumeration=false;
    if (modeString!=null && modeString.equals("Random")) {
	randomEnumeration=true;
    }
    
    boolean copyQueryIntoMarkush= 
            request.getParameter("copyQueryIntoMarkush")!=null;
    
    boolean toFile=request.getParameter("toFile")!=null;
    
    long count=0;
    if (countString!=null && countString.length()>0) {
        count= Long.parseLong(countString);
    }
    if (count==-1) { //too many cobinations found to fit into Long type
        count=Long.MAX_VALUE;
    }

    int maxCount=100; //default
    if (maxCountString!=null && maxCountString.length()>0) {
        maxCount= Integer.parseInt(maxCountString);
    }
    if (maxCount>200 && !toFile && !reductionToHit) { //limitation for HTML
        maxCount=200;
%>
            <script LANGUAGE="JavaScript">
            <!--
            alert("WARNING: 200 structure limit set for HTML mode. Use file export to enumerate more structures");
            -->
            </script>
<%
    }
    else if (maxCount>20 && !toFile && reductionToHit){
	maxCount=20;
	%>
	            <script LANGUAGE="JavaScript">
	            <!--
	            alert("WARNING: 20 structure limit set for HTML mode. Use file export to enumerate more structures");
	            -->
	            </script>
	<%
    }
    if (count < maxCount) {
        maxCount=(int)count;
    }


    String structureTableName =
        (String)session.getAttribute(sessionVarPrefix+"strTableName");

    ConnectionHandler ch =
        (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");
    
    //timeout check:
    if((ch==null)||(!ch.isConnected())) {
        Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
        if(v == null) {
            %>
            <script LANGUAGE="JavaScript">
            <!--
            location.href="expired.html";
            -->
            </script>
            <%
            return;
        }
    }
    
    Connection con=ch.getConnection();
    Statement stmt=con.createStatement();
    String sql="SELECT cd_markush FROM " + structureTableName + " WHERE " +
            "cd_id = " + cd_id;
    ResultSet rs=stmt.executeQuery(sql);
    byte[] structure=null;
    if (rs.next()) {
        structure = DatabaseTools.readBytes(rs, 1);
    }
    rs.close();
    stmt.close();
    if (structure==null) {
%>
    The structure was deleted.
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
    int columns=4;
    int rows=(int)Math.ceil((double)maxCount / columns);
    int cellWidth = 240;
    int cellHeight = 240;

    MolExporter exporter=null;
    if (toFile) {
//        response.setContentType("application/octet-stream");
        //setting an unknown type, otherwise IE tries to disaply an XML for MRV:
        response.setContentType("asdfasdfasdf/asdfasdfasdf");
        response.setHeader("Content-Disposition","inline; filename=result.mrv");
        exporter=new MolExporter(response.getOutputStream(), "mrv"); 
    } else {
%>
    <center>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js">
    </script>
    <script LANGUAGE="JavaScript1.1">
    <!--
<%
    }

    int cellIndex=0;
    java.util.List enumeratedMols = null;

    CDMarkushHandlerCache markushHandlerCache =
        new CDMarkushHandlerCache(chemaxon.jchem.db.cdmarkush.CDMarkushHandlerCache.ThreadSafety.SYNCHRONIZED, 
                chemaxon.jchem.db.cdmarkush.CDMarkushHandlerCache.CacheBehavior.CACHEFIRST);
    CDMarkushFromDB markushFromDB = markushHandlerCache.parseWithCompatibleHandler(structure);

    if (reductionToHit) {
            int searchType = SearchConstants.SUBSTRUCTURE;
        String typeString=(String)session.getAttribute(
                sessionVarPrefix+"query.type");
        if(typeString.equals("Screening")) {
            searchType = SearchConstants.NO_ABAS;        //todo: should not happen
        } else if(typeString.equals("Superstructure")) {
            searchType = SearchConstants.SUPERSTRUCTURE;
        } else if(typeString.equals("Similarity")) { //todo: should not happen
            searchType = SearchConstants.SIMILARITY;
        } else if(typeString.equals("Full")) {
            searchType = SearchConstants.FULL;
        } else if(typeString.equals("Full fragment")) {
            searchType = SearchConstants.FULL_FRAGMENT;
        }

        String molfile=
                (String)session.getAttribute(sessionVarPrefix+"query.molfile");
        Molecule query=new MolHandler(molfile).getMolecule();
        Molecule originalQuery=(Molecule) query.clone();

        query.aromatize();
        
		MolSearchOptions mso = new MolSearchOptions(searchType);
		mso.setMarkushEnabled(true);
		mso.setHitIndexType(SearchConstants.MARKUSH_HIT_ORIGINAL);

		HitColoringAndAlignmentOptions hco = new HitColoringAndAlignmentOptions();
		hco.coloring = true;
		hco.enumerateMarkush = true;
        
        int[] hit=null;
        
        enumeratedMols = new ArrayList();

        HitDisplayTool hdt = new HitDisplayTool(hco, mso, query, null);
        Molecule[] hitMols = hdt.getHits(
        	new MolHandler(structure).getMolecule(),
			structure == null ? (Molecule) null : markushFromDB.getSupergraph(),
			maxCount);

        for (int y=0; y<hitMols.length; y++) {

            if (toFile) {
                exporter.write(hitMols[y]);               
            } else {
                String source=hitMols[y].toFormat("mrv");
                enumeratedMols.add(HTMLTools.convertForJavaScript(source));
            }          

            }
        rows = (hitMols.length%columns == 0) 
        	? hitMols.length/columns 
        	: (hitMols.length/columns)+1;
    } else { //full or random enumeration:

        Molecule markush = markushFromDB.getMarkush();
        markush.clearProperties(); 
       
        MarkushEnumerationPlugin enumPlugin = new MarkushEnumerationPlugin();
	if (randomEnumeration){
	    enumPlugin.setRandomEnumeration();
	}
        enumPlugin.setMolecule(markush);
        enumPlugin.setMaxStructureCount(maxCount);
        enumPlugin.run();
        
        int size = (int)enumPlugin.getStructureCount();
        Molecule eMol = null;
        enumeratedMols = new ArrayList();
        while (enumPlugin.hasMoreStructures()){            
	    eMol = enumPlugin.getNextStructure();      
            //currently cleaning is needed after Markush enumeration:
            eMol.clean(2, null);
            
            if (toFile) {
                exporter.write(eMol);               
            } else {
                String source=eMol.toFormat("mrv");
                enumeratedMols.add(HTMLTools.convertForJavaScript(source));
            }
            if (++cellIndex>=maxCount) {
                break;
            }
        }
    }
    if (toFile) {                
        exporter.close();                
        response.getOutputStream().flush();
        response.getOutputStream().close();
    }

%>
    mview_begin("../../marvin",
    	"<%= columns*cellWidth+columns-1 %>",
        "<%= rows*cellHeight+rows-1 %>");
    mview_param("cols", "<%= columns %>");
    mview_param("rows", "<%= rows %>");
    mview_name="mview";
    mview_param("navmode", "rotZ");
    mview_param("molbg", "#ffffff");
    mview_param("border", 1);
    mview_param("editable", 2);
    mview_param("rgroupsVisible", "false");
<%
    for (int i = 0; i < enumeratedMols.size(); i++) {
%>
        mview_param("cell<%= i %>",
                "|<%= enumeratedMols.get(i) %>");
<%
    }
%>    
    mview_end();
    //-->
    </script>
    </center>
  </body>
</html>