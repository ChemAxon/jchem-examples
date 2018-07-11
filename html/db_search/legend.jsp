<%@page contentType="text/html"
errorPage="errorpage.jsp" 
import="chemaxon.descriptors.*, chemaxon.struc.*, chemaxon.jchem.db.*, java.awt.*"
%>
<%@ include file="init.jsp" %>
<html>
<head><title>Legend and query structure</title></head>
<body bgcolor="#e1e1e1" onLoad="window.focus()">

<center>

    <%

    ConnectionHandler ch = 
                (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");
    //checking if session has expired:
    if (ch==null) {%>
</center>    
<h2>Your session has expired</h2>
Click <a href="" onClick="javascript:window.close()">here</a> to close this window.
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
    return; //end of page if timeout
    }
    String structureTableName = 
                (String)session.getAttribute(sessionVarPrefix+"strTableName");

    Color[] atomSetColors=null;  // no coloring, if value is null
    String atomSetNames[]=null;
        MolecularDescriptor descriptor=null;
        String queryType=(String)session.getAttribute(sessionVarPrefix+"query.type");
        if (queryType!=null && queryType.equals("Similarity")){
            String mdName=(String)session.getAttribute(sessionVarPrefix+"query.MDName");
            if(mdName!=null && !mdName.equals(".hashedFP.")) {
                MDTableHandler mdth=new MDTableHandler(ch, structureTableName);
                descriptor=mdth.createMD(mdName);
                String mdConfig=(String)session.getAttribute(
                        sessionVarPrefix+"query.MDConfig");
                if (mdConfig!=null && !mdConfig.equals(".default_config.")) {
                    descriptor.setScreeningConfiguration(
                            mdth.getMDConfig(mdName, mdConfig));
                }
                atomSetColors=descriptor.getAtomSetColors();
                atomSetNames=descriptor.getAtomSetNames();
            }
        }


    String molfile=(String)session.getAttribute(sessionVarPrefix+"query.molfile");

    
    %>



    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
    <script LANGUAGE="JavaScript1.1">
    <!--
    mview_name="mview";
    mview_begin("../../marvin", 300, 300);
    mview_param("molbg", "#ffffff");
    mview_param("bgcolor", "#e0e0e0");
    mview_param("border", 1);
<%
    MolHandler mh=new MolHandler(molfile);
    Molecule mol=mh.getMolecule();
%>
    mview_param("mol", "<%=HTMLTools.convertForJavaScript(mol.toFormat("mol"))%>");
    <%
    if (atomSetColors!=null ) {
        for (int x=0; x<atomSetColors.length; x++) {
            if (atomSetColors[x]!=null) {
                String cString=HTMLTools.getHTMLColorString(atomSetColors[x]);
                out.println("msketch_param(\"setColor"+x+"\",\""+cString+"\" );");
            }
        }
        int[] setIndexes=descriptor.getAtomSetIndexes(mol);
        mol.aromatize(false);
        if (setIndexes!=null) { //coloring defined in MD
            for (int set=0; set<64; set++) {
                String list="";
                for (int x=0; x<setIndexes.length; x++) {
                    if (setIndexes[x]==set) {
                        if (list.length()>0) {
                            list=list+",";
                        }
                        list=list+x;
                    }
                }
                if (list.length()>0) {
                    out.print("msketch_param(\"set0."+
                            set+"\",\""+list+"\" );");
                }
            }
        }
    }
    %>
    mview_end();
    //-->
    </script>
    <hr>
<%
    if (atomSetColors!=null ) {
%>
    <table border=1 cellPadding=2 cellSpacing=0>

    <tr>
            <td>Color</td>
            <td>Meaning</td>
    </tr>
    <% for (int x=0; x<atomSetColors.length; x++) {
            if (atomSetNames[x]!=null) {%>
            <tr>
                <td bgcolor=<%=HTMLTools.getHTMLColorString(atomSetColors[x])%>></td>
                <td NOWRAP="true"><%=atomSetNames[x]%></td>
            </tr>    
    <% }     
     } %>
    </table>

<%  } else {
%>
        No colors are defined for this descriptor.
<%
    }
%>
</center>
</body>
</html>
