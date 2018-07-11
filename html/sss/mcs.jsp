<!--
  Copyright (c) 2016 ChemAxon Ltd. All Rights Reserved.

  This software is the confidential and proprietary information of
  ChemAxon. You shall not disclose such Confidential Information
  and shall use it only in accordance with the terms of the agreements
  you entered into with ChemAxon.
-->

<!--
    Author: Miklos Vargyas
    Created: 15/10/2004
    Last modified: 15/10/2004
-->



<%@ page 
import="com.chemaxon.search.mcs.MaxCommonSubstructure,
		chemaxon.struc.*,
		chemaxon.formats.*,
		chemaxon.util.*,
        java.io.*,
        java.util.ArrayList,
        chemaxon.sss.search.MolSearch"
%>




<%
    String queryMol = request.getParameter( "mol1" );
    String targetMol = request.getParameter( "mol2" );
    if ( queryMol == null ) {
        queryMol = "";
    }
    if ( targetMol == null ) {
        targetMol = "";
    }

    int[] map = new int[0];
    if ( queryMol.length() > 0 && targetMol.length() > 0 ) {

        Molecule query = new MolHandler( queryMol ).getMolecule();
        query.aromatize();
        query.calcHybridization();
        if ( query.getDim() < 2 ) {
            query.clean( 2, null );
        }

        Molecule target = new MolHandler( targetMol ).getMolecule();
        target.aromatize();
        target.calcHybridization();
        if ( target.getDim() < 2 ) {
            target.clean( 2, null );
        }

        MaxCommonSubstructure mcs = MaxCommonSubstructure.newInstance();
		mcs.setMolecules( query, target );
        if (mcs.hasNextResult()) {
            map = mcs.nextResult().getAtomMapping();
        }
    }
%>


<html>
<head>
<LINK REL ="stylesheet" TYPE="text/css" HREF="../../../jchemmanuals.css" TITLE="Style">
<title>Maximum Common Substructure Search</title>
</head>



  <script LANGUAGE="JavaScript1.1">
  <!--
    pageLoaded = false;

    map = new Array(<%
            for( int i = 0; i < map.length; i++ ) {
                if ( i != 0 ) out.print( ',' );
                out.print( map[ i ] );
            }
    %>);


    function loadFile1() {
      document.queryMsketch.setMol("file:"+document.inputForm.File1.value);
    }

    function loadFile2() {
      document.targetMsketch.setMol("file:"+document.inputForm.File2.value);
    }

    function search()
    {
        if ( pageLoaded ) {
            form = document.postForm;
    	    form.action = "mcs.jsp" + location.search;
    	    form.mol1.value = document.queryMsketch.getMol('mrv');
    	    form.mol2.value = document.targetMsketch.getMol('mrv');
    	    form.submit();
        }
        else {
    	    alert( "Loading page. Please wait...");
        }
    }

    function displayMCS() {

<%--        if ( map.length == 0 ) {--%>
<%--            return;--%>
<%--        }--%>

<%--        document.targetMsketch.setAtomSetColor(0, Color.black);--%>
<%--        document.targetMsketch.setAtomSetColor(1, Color.red);--%>
<%----%>
<%----%>
        var ac = document.targetMsketch.getAtomCount(0);
alert("ac = " + ac );
        for ( var i = 0; i < ac; i++ ) {
            document.targetMsketch.setAtomSetSeq( 0, i, 1 );
        }
<%----%>
<%--        document.targetMsketch.setMol( 0, document.queryMsketch.getMol(0) );--%>


<%--        // coloring atoms--%>
<%--        for ( var i = 0; i < map.length; i++ ) {--%>
<%--            if ( map[ i ] >= 0 ) {--%>
<%--                document.targetMsketch.setAtomSetSeq( 0, map[ i ], 1 );--%>
<%--                document.queryMsketch.setAtomSetSeq( 0, i, 1 );--%>
<%--            }--%>
<%--        }--%>
<%----%>
<%--        //coloring bonds:--%>
<%--        var nh=nonHitBonds[hitNum];--%>
<%--        for (var i = 0; i < nh.length; i++) {--%>
<%--            document.targetMsketch.setBondSetSeq(0, nh[i][0], nh[i][1], 1);--%>
<%--        }--%>

    }

  -->
  </script>
  </head>
  <body onload="pageLoaded=true" >

  <form method="post" name="postForm">
    <input type="hidden" name="mol1"/>
    <input type="hidden" name="mol2"/>
  </form>

  <form onSubmit="return false" name="inputForm">
  <table>
    <tr>
    <td align="left">Structure file:</td>
    <td><input type="file" size="50" name="File1"/></td>
    <td><input type="button" name="Load file1" value="Load in Marvin" onClick="loadFile1()"/></td>
    </tr>
    <tr>
    <td align="left">Structure file:</td>
    <td><input type="file" size="50" name="File2"/></td>
    <td><input type="button" name="Load file2" value="Load in Marvin" onClick="loadFile2()"/></td>
    </tr>
    <tr>
    <td><input type="button" value="Search" onClick="search()"/></td>
    </tr>
  <table>
  <table>
  <tr>
  <td><b>Query</b></td>
  <td><b>Target</b></td>
  </tr>
  <tr>
  <td>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
            <script LANGUAGE="JavaScript1.1">
            <!--
            msketch_name="queryMsketch";
            msketch_begin("../../marvin", 440, 400);
            msketch_param("bgcolor", "#b0b0b0");
            msketch_param("molbg", "#F0F0F0");
            msketch_param("implicitH", "off");
            msketch_param("atomSetColor1","#ff0000" );
            msketch_param("undo", "50");
            msketch_param("mol","<%=HTMLTools.convertForJavaScript(queryMol)%>");
            msketch_param("preload", "MolExport,GraphInvariants,Parity");
            msketch_end();
            //-->
    </script>
  </td>
  <td>
    <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>
            <script LANGUAGE="JavaScript1.1">
            <!--
            msketch_name="targetMsketch";
            msketch_begin("../../marvin", 440, 400);
            msketch_param("bgcolor", "#b0b0b0");
            msketch_param("molbg", "#F0F0F0");
            msketch_param("implicitH", "off");
            msketch_param("atomSetColor1","#ff0000" );
            msketch_param("undo", "50");
            msketch_param("mol","<%=HTMLTools.convertForJavaScript(targetMol)%>");
            msketch_param("preload", "MolExport,GraphInvariants,Parity");
            msketch_param("molChanged0", "js:displayMCS()");
            msketch_end();
            //-->
    </script>
  </td>
  </tr>
<%--  <tr>--%>
<%--  <td>--%>
<%--  <script LANGUAGE="JavaScript1.1" SRC="../../marvin/marvin.js"></script>--%>
<%--            <script LANGUAGE="JavaScript1.1">--%>
<%--            <!----%>
<%--            mview_name="mview";--%>
<%--            mview_mayscript=true;--%>
<%--            mview_begin("../../marvin", 300, 300);--%>
<%--            mview_param("bgcolor", "#b0b0b0");--%>
<%--            mview_param("molbg", "#F0F0F0");--%>
<%--            mview_param("implicitH", "off");--%>
<%--            mview_param("undo", "50");--%>
<%--            mview_param("mol","<%=HTMLTools.convertForJavaScript(targetMol)%>");--%>
<%--            mview_param("colorScheme","atomset" );--%>
<%--            mview_param("atomSetColor0","#000000" );--%>
<%--            mview_param("atomSetColor1","#ff0000" );--%>
<%--            mview_param("bondSetColor1","#000000" );--%>
<%--            mview_param("molChanged0", "js:displayMCS()");--%>
<%--            mview_end();--%>
<%--            //-->--%>
<%--    </script>--%>
<%--    </td>--%>

<%--  </tr>--%>
  </table>

  </form>

  </body>
</html>