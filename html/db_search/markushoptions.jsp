<%@ page import="chemaxon.util.ConnectionHandler,
                 java.sql.Connection,
                 chemaxon.struc.Molecule,
                 chemaxon.enumeration.ExpansionCounter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="init.jsp" %>
<html>

<head>
<title>Markush enumeration options</title>


  <script language="JavaScript">
  <!--
  
    function typeChanged() {
        form=document["markushForm"];
        if (form["type"].value=="Hit") {
            form["copyQueryIntoMarkush"].disabled=false;
        } else {
            form["copyQueryIntoMarkush"].disabled=true;
        }
    }

    function submitForm() {
        form=document["markushForm"];
<%
    String molfile=
                (String)session.getAttribute(sessionVarPrefix+"query.molfile");
    if (molfile==null || molfile.length()==0) {
        %>
        if (form["type"].value=="Hit") {
            alert("Please search with a query first for hit enumeration.")
            return;
        }
        <%
    }
%>
        
        form.action="enumeratemarkush.jsp"+location.search;
<%--        if (form["type"].value=="Selective") {--%>
<%--            form.action="markushselection.jsp"+location.search;    --%>
<%--        } else { --%>
<%--            form.action="enumeratemarkush.jsp"+location.search;--%>
<%--        }--%>
        form.submit();
    }
    
  // -->
  </script>

  </head>
  <body>

<%
    String cd_id=request.getParameter("cd_id");

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
    String sql="SELECT cd_structure FROM " + structureTableName + " WHERE " +
            "cd_id = " + cd_id;
    ResultSet rs=stmt.executeQuery(sql);
    byte[] structure=null;
    if (rs.next()) {
        structure = DatabaseTools.readBytes(rs, "cd_structure");
    }
    rs.close();
    stmt.close();
    if (structure==null) {
%>
    The structure was not found, please try again.
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
    String molString=new String(structure, "ASCII");
%>
    <center>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js">
    </script>
    <script LANGUAGE="JavaScript1.1">
    <!--
    mview_name="mview";
    mview_begin("../../marvin", 500, 500);
    mview_param("navmode", "rotZ");
    mview_param("molbg", "#ffffff");
    mview_param("cell0",
            "|<%= HTMLTools.convertForJavaScript(molString) %>");
    mview_end();
    //-->
    </script>
    </center>
<%


    Molecule mol=new MolHandler(structure).getMolecule();
    ExpansionCounter counter=new ExpansionCounter();
    counter.setMolecule(mol);
    long enumeratedCount=-1;
    try {
        enumeratedCount=counter.countExpansions();
    } catch (ArithmeticException e) {} //cannot fit into Long.MAXVALUE

    boolean moreHits = (request.getParameter("moreHits") != null);
    
    if (!moreHits) {
	if (enumeratedCount==-1) {
%>
    	Full enumeration of this structure produces <b>more than</b>
    	2<sup>63</sup>-1 structures (exact number is out of range for calculation).    
<%
        
    	} else {
%>
    
    	Full enumeration of this structure produces <%=enumeratedCount%> structures.
<%
    	}
    }
%>


    <form method="post" name="markushForm">
        <input type="hidden" name="cd_id" value=<%=cd_id%>>
        <input type="hidden" name="count" value=<%=enumeratedCount%>>
        <table border="0" cellpadding="0" cellspacing="0">
            <tr>
<%
	if (moreHits) {
%>
		<td colspan=2><input type="hidden" name="type" value="Reduction" /></td>
<%
	} else {
%>
		<td>
		Enumeration type:
		</td>
		<td>
                    <select name="type" onClick="javscript:typeChanged()">
                        <option value="Full">Full enumeration</option>
<%--                        <option value="Selective">Selective enumeration</option>--%>
<%--                        <option value="Reduction">Markush structure reduction to hits of the last query--%>
                        <option value="Random">Random enumeration</option>
                    </select>
                </td>
<%
	}
%>
            </tr>
            <tr>
                <td>Maximum number of structures to display:
                </td>
                <td>
                    <input name="maxCount" value=<% out.print(moreHits ? "\"20\"" : "\"100\""); %>/>
                </td>
            </tr>
            <tr>
                <td colspan="2" >
                    <input name="toFile" type="checkbox" >
                    Export results to file
                </td>
            </tr>
        </table>
    </form>

    <input type=button value=<% out.print(moreHits ? "\"Show hits\"" : "\"Enumerate\""); %>  onClick="javscript:submitForm()">

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