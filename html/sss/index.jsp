<%@ page
	import="chemaxon.util.HTMLTools,
	chemaxon.struc.Molecule,
	chemaxon.util.HitColoringAndAlignmentOptions,
	chemaxon.util.HitDisplayTool,
	chemaxon.util.MolHandler,
	java.util.ArrayList,
	chemaxon.sss.SearchConstants,
	chemaxon.sss.search.MolSearchOptions"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>


<%
	String alignmentOption = request.getParameter("hitAlignmentOrClean");	
	if(alignmentOption == null) {alignmentOption = "none";}
	
	String query_mol = request.getParameter("query_mol");
	String target_mol = request.getParameter("target_mol");
	String display_mol = target_mol;
	ArrayList resultList = new ArrayList();
	if (query_mol == null) {
		query_mol = "";
	}
	if (target_mol == null) {
		target_mol = "";
	}
	if (display_mol == null) {
		display_mol = new Molecule().toFormat("mrv");
	}

	//storing the structures, so the page will remember them:
	session.setAttribute("query.mol", query_mol);
	session.setAttribute("target.mol", target_mol);

	int[][] hits = new int[0][0];
	ArrayList nonHitBonds = new ArrayList();
	if (query_mol.length() > 0 && target_mol.length() > 0) { //not empty structures
		//reading the structures:
		Molecule query = new MolHandler(query_mol).getMolecule();
		Molecule target = new MolHandler(target_mol).getMolecule();
		//basic standardization: aromaitzation


		//Introduce Hit Coloring and Alignment
		HitColoringAndAlignmentOptions options = new HitColoringAndAlignmentOptions();
		options.coloring = true;
		if (alignmentOption.equalsIgnoreCase("hitAlignment")) {
			options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_ROTATE;
		} else if (alignmentOption.equals("partialClean")) {
			options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_PARTIAL_CLEAN;
		} else {
			options.alignmentMode = HitColoringAndAlignmentOptions.ALIGNMENT_OFF;
		}
		//options.hitColor = Color.RED;
		//options.nonHitColor = Color.GRAY;

		MolSearchOptions mso = new MolSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
		mso.setMarkushEnabled(true);
		HitDisplayTool hdt = new HitDisplayTool(options, mso, query, null);
		Molecule[] results = hdt.getHits(target, (Molecule) null, 0);
		if (results.length == 0) {
			display_mol = new Molecule().toFormat("mrv");
		} else {
			for (int i = 0; i < results.length; i += 1) {
				resultList.add(results[i].toFormat("mrv"));
			}
			display_mol = (String) resultList.get(0);
			pageContext.setAttribute("resultMolecules", resultList);
		}
	}
%>


<html>
<head><script type="text/javascript" SRC="../../marvin/marvin.js"></script>
<title>Substructure Search Demo Page</title>

<script type="text/javascript">

  <!--
    pageLoaded=false;
    hits = new Array(<% for (int i =0; i < resultList.size(); i++){
    		if(i != 0){ 
    			out.print(",");
    		}
    		out.print("'");
    		out.print(HTMLTools.convertForJavaScript((String)resultList.get(i)));
    		out.print("'");
    	}%>);
<%--Uncomment the following for input fields: --%>
<%--
    function loadQuery() {
      document.query_msketch.setMol("file:"+document.inputForm.File.value);
    }
    function loadTarget() {
      document.target_msketch.setMol("file:"+document.inputForm.File.value);
    }
    function loadSMARTS() {
        document.query_msketch.setMol(document.inputForm.SMARTS.value, "smarts:");
    }
    function loadSMILES() {
        document.target_msketch.setMol(document.inputForm.SMILES.value, "smiles:");
    }
--%>

    function search()
    {
        if(pageLoaded) {
            if (document.query_msketch.getAtomCount()==0) {
                alert("Please specify a query structure.");
                return;
            }
            if (document.target_msketch.getAtomCount()==0) {
                alert("Please specify a target structure.");
                return;
            }
            form = document.postForm;
    	    form.action = "index.jsp" + location.search;
    	    form.query_mol.value = document.query_msketch.getMol('mrv');
    	    form.target_mol.value = document.target_msketch.getMol('mrv');
	    	form.hitAlignmentOrClean.value = document.inputForm.hitAlignmentOrClean.value;
    	    form.submit();
        } else {
    	    alert("Page loading. Please wait.");
        }
    }

    hitNum=0;

    function displayHit() {
		document.mview.setMol(hits[hitNum]);
		disabler();
    }
    
    function disabler() {

    <%if (resultList.size() > 1) {%>
	
	    if (hitNum<=0) {
		document.inputForm.prevButton.disabled=true;
	    } else {
		document.inputForm.prevButton.disabled=false;
	    }

	    if (hitNum>= <%=resultList.size()-1%>) {
		document.inputForm.nextButton.disabled=true;
	    } else {
		document.inputForm.nextButton.disabled=false;
	    }
    <%}%> 
    }

    function nextHit() {
        hitNum++;
        displayHit();
    }

    function prevHit() {
        hitNum--;
        displayHit();
    }
  -->
  </script>
</head>
<body bgcolor="#e0e0e0" onload="pageLoaded=true;">

<center>
<h2>Substructure Search Demo Page</h2>
</center>

<p><font size="-1">Usage: Draw a query and a target
structure, then press "Search" below.<br>
You can also load files by using the <b>File -> Open</b> menu of the
Marvin Sketch applets.<br>
You can also paste structure strings into the editors directly, or use
the <b>Edit -> Source</b> dialog. </font></p>

<form method="post" name="postForm">
	<input type="hidden" name="query_mol" /> 
	<input type="hidden" name="target_mol" /> 
	<input type="hidden" name="hitAlignmentOrClean" />
</form>
<form onSubmit="return false" name="inputForm">
<table>
	<tr>
		<td><b>Query</b></td>
		<td><b>Target</b></td>
	</tr>
	<tr>
		<td>
		<script type="text/javascript">
            <!--
            msketch_name="query_msketch";
            msketch_begin("../../marvin", 460, 460);
            msketch_param("molbg", "#F0F0F0");
            msketch_param("implicitH", "off");
            msketch_param("undo", "50");
            msketch_param("mol","<%=HTMLTools.convertForJavaScript(query_mol)%>");
            msketch_end();
            //-->
    </script></td>
		<td>
		<script type="text/javascript">
            <!--
            msketch_name="target_msketch";
            msketch_begin("../../marvin", 460, 460);
            msketch_param("molbg", "#F0F0F0");
            msketch_param("implicitH", "off");
            msketch_param("undo", "50");
            msketch_param("mol","<%=HTMLTools.convertForJavaScript(target_mol)%>");
            msketch_end();
            //-->
    </script></td>
	</tr>
</table>
<table>
	<tr>
		
		<td>Alignment: <select id="hitAlignmentOrClean" name="hitAlignmentOrClean" onchange="ColoringAndAlignmentOptionChanged()" >
    	    <option value="hitAlignment" <%= alignmentOption.equalsIgnoreCase("hitAlignment") ? "selected" :""%> >Hit alignment</option>
    	    <option value="partialClean" <%= alignmentOption.equalsIgnoreCase("partialClean") ? "selected" :""%> >Partial clean</option>   
    	    <option value="none" <%= alignmentOption.equalsIgnoreCase("none") ? "selected" :""%> >None</option>
    	  </select>
    	</td>
				
	</tr>
</table>
<table>	
	<tr>
		<td />
		<td><b>Hits</b></td>
		<td />
		<td />
	</tr>
	<tr>
		<td />
		<td><%= resultList.size()== 0 ? "No hits"
						: resultList.size() == 1 ? "1 hit" : resultList.size() + " hits"%></td>
		<td />
		<td />
	</tr>
	<tr>
		<td><input name="prevButton" type="button" value="<<" onClick="
			prevHit()" disabled /></td>
		<td>
		<script type="text/javascript">
            <!--
            mview_name="mview";
            mview_begin("../../marvin", 200, 200);
            mview_param("molbg", "#F0F0F0");
            mview_param("implicitH", "off");
            mview_param("undo", "50");
            mview_param("mol","<%=HTMLTools.convertForJavaScript(display_mol)%>");
            mview_param("colorScheme","mono" );
            mview_param("importEnabled","false" );
            mview_end();
            //-->
    </script></td>
		<td><input name="nextButton" type="button" value=">>"
			onClick="nextHit()" <%=resultList.size() > 1 ? "" : "disabled"%> /></td>
		<td width="300" />
		<td><input type="button" name="searchButton" value="Search"
			onClick="search()" /></td>
</table>
</form>

</body>
</html>