<%@ page errorPage="errorpage.jsp" 
import="chemaxon.descriptors.*, chemaxon.jchem.db.*, chemaxon.util.*"
%>
<%@ include file="init.jsp" %>
<%

java.util.List filters=new ArrayList();

File configFile=null;
if (chemFilterFile!=null && chemFilterFile.length()>0) {
    configFile=new File(chemFilterFile);
    if (!configFile.exists()) {
        configFile=null;
    }
}
if (configFile==null){
    //trying to read from default file:
    String context=request.getContextPath();
    String uri=request.getRequestURI();
    uri=uri.substring(context.length());
    String thisPage = getServletConfig().getServletContext().getRealPath(uri);
    File f = new File(thisPage);
    configFile =new File(f.getParentFile(), "/ChemicalTermsFilters.xml");
}

if (configFile!=null && configFile.exists()) {
    try {
        FileInputStream fis=new FileInputStream(configFile);
        filters=ConfigTools.readChemicalTermFilters(fis);
        fis.close();
    } catch (NoClassDefFoundError e) {//won't work with JRE 1.3 or older
    } catch (Exception e) {
        System.err.println("Error occured during the read of chemical terms " +
                "config file : "+configFile.getAbsolutePath());
        e.printStackTrace();
    }
}


ConnectionHandler ch = (ConnectionHandler)session.getAttribute(sessionVarPrefix+"ch");

if((ch==null)||(!ch.isConnected())) {
    Vector v = (Vector)session.getAttribute(sessionVarPrefix+"loginDetails");
    if(v == null) {
        %>
        <script language="JavaScript">
        <!--
        location.href="expired.html";
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


String molFile = (String)session.getAttribute(sessionVarPrefix+"query.prev.molfile");
boolean firstVisit = false;            
if(molFile==null) {
    molFile = "";
    firstVisit = true;
}


// CD screening:
String structureTableName = 
        (String)session.getAttribute(sessionVarPrefix+"strTableName");

DatabaseProperties dbProperties = new DatabaseProperties(ch);
int tableType = dbProperties.getTableType(structureTableName);


//non-descriptor metrics:            
JChemSearch.DissimilarityMetrics metrics = JChemSearch.getDissimilarityMetrics 
        (ch, structureTableName);

// values for MD fingerprint screening:
MDTableHandler mdth=new MDTableHandler(ch, structureTableName);
String[] descriptor_ids=mdth.getMolecularDescriptors();
int desc_num=descriptor_ids.length;
int embeddedDesc = (metrics == null) ? 0 : 1;
            
String[] descriptor_names=new String[desc_num + embeddedDesc];
String[] descriptor_comments=new String[desc_num + embeddedDesc];
String[][] descriptorConfigs=new String[desc_num + embeddedDesc][];
float[][] default_threshold=new float[desc_num + embeddedDesc][];
for (int x=0; x<desc_num; x++){
    String mdName=descriptor_ids[x];
    MolecularDescriptor descriptor=mdth.createMD(mdName);
    //getting descriptor names:
    descriptor_names[x + embeddedDesc]=descriptor.getName();
    //getting descriptor comments:
    String comment=mdth.getMDComment(mdName);
    if (comment==null || comment.length()==0) {
        comment="No comments were stored for this descriptor.";
    }
    descriptor_comments[x + embeddedDesc]=comment;
    // getting descriptor configs:
    
    String[] configs=mdth.getMDConfigs(mdName);
    descriptorConfigs[x + embeddedDesc]=new String[configs.length+1];
    default_threshold[x + embeddedDesc]=new float[configs.length+1];
    
    //default settings:
    descriptorConfigs[x + embeddedDesc][0] = "Default";
    default_threshold[x + embeddedDesc][0]=descriptor.getThreshold();

    for (int i=0; i<configs.length; i++) {
        MolecularDescriptor tempDesc=(MolecularDescriptor)descriptor.clone();
        String cfg=mdth.getMDConfig(mdName,configs[i]);
        tempDesc.setScreeningConfiguration(cfg);
        descriptorConfigs[x + embeddedDesc][i+1]=configs[i];
        default_threshold[x + embeddedDesc][i+1]=tempDesc.getThreshold();
    }
}
if (metrics != null) {
    descriptor_names[0] = metrics.name;
    descriptor_comments[0] = "Built-in descriptor";
    descriptorConfigs[0] = metrics.metricNames;
    default_threshold[0] = metrics.defaultDissimilarityMetricThresholds;        
}


//enumerating and checking query conditions:
session.removeAttribute(sessionVarPrefix+"condcount");
java.util.List<String> typeList = new ArrayList<String>();
java.util.List<String> fieldList = DatabaseTools.getFieldNames(ch, structureTableName,
        typeList);
int[] sqlTypes=DatabaseTools.getFieldTypes(ch, structureTableName);
java.util.List fieldTexts=new ArrayList(); //String objects, the displayed names of fields
java.util.List fieldNames=new ArrayList(); //String objects, the DB names of fields
java.util.List fieldTypes=new ArrayList(); //Integer objects, the DB names of fields
String queryConditions = 
        props.getProperty(structureTableName+".queryConditions");
if(queryConditions == null) {
    queryConditions = props.getProperty("default.queryConditions");
}
for(int i=0;i<fieldList.size();i++) {
    boolean showField = false;
    String field = (String)fieldList.get(i);
    int type=sqlTypes[i];
    String text = field;
    if (field.toLowerCase().equals("cd_id")) {
        text="Id";
    }
    if (field.toLowerCase().equals("cd_formula")) {
        text="Formula";
    }
    if (field.toLowerCase().equals("cd_molweight")) {
        text="Molweight";
    }
    if(queryConditions!=null) {
        StringTokenizer str = new StringTokenizer(queryConditions,";");
        while(str.hasMoreElements()) {
            String sf = str.nextToken();		    
            if(sf.toLowerCase().startsWith(field.toLowerCase())) {
                int index = sf.indexOf("#");
                if(index > -1) {
                    text = sf.substring(index + 1);
                    sf = sf.substring(0, index);
                }
                if(sf.toLowerCase().equals(field.toLowerCase())) {
                    showField = true;
                }
            }
        }
    } else if(!field.toLowerCase().startsWith("cd_fp") && 
	    !field.toLowerCase().startsWith("cd_smiles") &&
            !field.toLowerCase().startsWith("cd_hash") &&
            !field.toLowerCase().startsWith("cd_flags") &&
            !field.toLowerCase().startsWith("CD_SORTABLE_FORMULA") &&
            !field.toLowerCase().startsWith("CD_PRE_CALCULATED") &&
            !field.toLowerCase().startsWith("cd_structure")) {
        showField = true;
    }
    boolean isText=DatabaseTools.isTextType(type);
    boolean isInteger=DatabaseTools.isIntType(type);
    boolean isReal=DatabaseTools.isRealType(type);
    if (!isText && !isInteger && !isReal) {
        showField=false;
    }
    if(showField) { //adding it to the query list
        fieldNames.add(field);
        fieldTexts.add(text);
        fieldTypes.add(new Integer(type));
    }
}
session.setAttribute(sessionVarPrefix+"condcount",new Integer(fieldTypes.size()));
%>

<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<!-- META HTTP-EQUIV="expires" CONTENT="0" -->
<title>Query Parameters</title>
<script language="JavaScript">
<!--

var sketcherLoaded=false;
var prevSearchType = "Substructure";

twIndex=0;
/*
 * Opening a new window for the help
 */
function help()
{
    var w = window.open("queryhelp.html",
	    "queryhelp"+(twIndex++).toString(),
	    "resizable=yes,width=470,height=270,scrollbars=yes,menubar=yes");
    w.focus();
}

/*
 * Checking if query conditions are valid
 */
function checkForm() {
<%
for (int x=0; x<fieldTypes.size(); x++) {
    int type=((Integer)fieldTypes.get(x)).intValue();
    String name=((String)fieldNames.get(x)).toLowerCase();
    if (DatabaseTools.isIntType(type) || name.equals("cd_id")){%>
        var value=document.queryForm.value<%=x%>.value;
        if(value != null && value != "") {
            if(isNaN(value) || value.indexOf('.')>=0) {
                alert("'" + value + "' is not a valid integer value");
                return false;
            }
        }<% 
    } else if (DatabaseTools.isRealType(type)){%>
        var value=document.queryForm.value<%=x%>.value;
        if(value != null && value != "") {
            if(isNaN(value)) {
                alert("'" + value + "' is not a valid floating point value");
                return false;
            }
        }<% 
    }
}%>
    if (form.dissimilarityThreshold) {
        var value=document.queryForm.dissimilarityThreshold.value;
        if(!document.queryForm.dissimilarityThreshold.disabled
                && value != null && value != "") {
            if(isNaN(value)) {
                alert("'" + value + "' is not a valid floating point value");
                return false;
            }
        }
    }

    return true;
}


/*
 * Submit form only if the frames have been loaded
 */
function submitIfLoaded(whatToDo)
{
    if(sketcherLoaded) {
        form = document.queryForm;
	form.action = "initsearch.jsp" + location.search;
	form.molfile.value = document.msketch.getMol('mrv');
        //sending the date as a string to the server:
        var d=new Date();
        var hours=d.getHours();
        var minutes=d.getMinutes();
        var seconds=d.getSeconds();
        var timeString="";
        if (hours<10) timeString+="0";
        timeString+=hours+":";
        if (minutes<10) timeString+="0";
        timeString+=minutes+":";
        if (seconds<10) timeString+="0";
        timeString+=seconds;

        form.startTimeAtClient.value=timeString;
	if(checkForm())
	    form.submit();
    } else
	alert("Page loading. Please wait.");
}

/*
 * Functions for the buttons
 */
function swapImgRestore() {
  if (document.swapImgData != null)
    for (var i=0; i<(document.swapImgData.length-1); i+=2)
      document.swapImgData[i].src = document.swapImgData[i+1];
}
function preloadImages() {
  if (document.images) {
    var imgFiles = preloadImages.arguments;
    if (document.preloadArray==null) document.preloadArray = new Array();
    var i = document.preloadArray.length;
    with (document) for (var j=0; j<imgFiles.length; j++) {
      preloadArray[i] = new Image;
      preloadArray[i++].src = imgFiles[j];
  } }
}
function swapImage() {
  var i,j=0,objStr,obj,swapArray=new Array,oldArray=document.swapImgData;
  for (i=0; i < (swapImage.arguments.length-2); i+=2) {
    objStr = swapImage.arguments[(navigator.appName == 'Netscape')?i:i+1];
    if ((objStr.indexOf('document.layers[')==0 && document.layers==null) ||
        (objStr.indexOf('document.all[')   ==0 && document.all   ==null))
      objStr = 'document'+objStr.substring(objStr.lastIndexOf('.'),objStr.length);
    obj = eval(objStr);
    if (obj != null) {
      swapArray[j++] = obj;
      swapArray[j++] = (oldArray==null || oldArray[j-1]!=obj)?obj.src:oldArray[j];
      obj.src = swapImage.arguments[i+2];
  } }
  document.swapImgData = swapArray; //used for restore
}

/**
 * Restore options
*/
function restoreOptions() {
    updateMDConfigs();
    form = document.queryForm;

    //restoring search type:
    var prev='<%
    String prev=(String)session.getAttribute(sessionVarPrefix+"query.prev.type");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    prevSearchType = prev
    var num = form.type.length;
    for(var i=0;i<num;i++) {
        if (form.type.options[i].value == prev) {
            form.type.options[i].selected = true;
        }
    }

    if (prev== 'Similarity' && form.MD) {
        //restoring descriptor type:
        prev='<% 
        prev=(String)session.getAttribute(sessionVarPrefix+"query.prev.MDName");
        if (prev!=null) {
            out.print(prev);
        }
        %>';
        var num = form.MD.length;
        for(var i=0;i<num;i++) {
            if (form.MD.options[i].value == prev) {
                form.MD.options[i].selected = true;
                updateMDConfigs();
            }
        }
        
        if (prev!='.hashedFP.') {
            //restoring screening config:
            prev='<% 
            prev=(String)session.getAttribute(sessionVarPrefix+"query.prev.MDConfig");
            if (prev!=null) {
                out.print(prev);
            }
            %>';
            var num = form.MDConfig.length;
            for(var i=0;i<num;i++) {
                if (form.MDConfig.options[i].value == prev) {
                    form.MDConfig.options[i].selected = true;
                    updateDefaultThreshold();
                }
            }
        }
    }

    //restoring dissimilarity value
    <% 
    prev=(String)session.getAttribute(sessionVarPrefix+"query.prev.dissimilarityThreshold");
    if (prev!=null && descriptor_names.length>0) {
        try {
            Float.parseFloat(prev); // test if valid number
%>
        var diss='<%=prev%>';
        form.dissimilarityThreshold.value=diss;
<%
        } catch (NumberFormatException e) {}
    }
    %>
    

    //restoring max hits:
    var prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.maxResultCount");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    var num = form.maxResultCount.length;
    for(var i=0;i<num;i++) {
        if (form.maxResultCount.options[i].value == prev) {
            form.maxResultCount.options[i].selected = true;
        }
    }

    //restoring tautomer search:
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.tautomers");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.tautomers.value = prev;
    for (var i=0; i < form.tautomers.length; i++)
    {
   	  if (form.tautomers[i].value == prev)
      {
        form.tautomers[i].checked = true;
      }
    }

    //restoring hit non-hit option:
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.nonhits");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.nonhits.checked=prev;
    
    //restore stereochemistry
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.stereochem");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.stereochem.value=prev;
    for (var i=0; i < form.stereochem.length; i++)
    {
   	  if (form.stereochem[i].value == prev)
      {
        form.stereochem[i].checked = true;
      }
    }
    
    //restore doubleBoundStereo
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.doubleBondStereoCheck");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.doubleBondStereoCheck.value = prev;
    for (var i=0; i < form.doubleBondStereoCheck.length; i++)
    {
   	  if (form.doubleBondStereoCheck[i].value == prev)
      {
        form.doubleBondStereoCheck[i].checked = true;
      }
    }
    
    //restore charges
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.charges");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.charges.value = prev;
    for (var i=0; i < form.charges.length; i++)
    {
   	  if (form.charges[i].value == prev)
      {
        form.charges[i].checked = true;
      }
    }
    
    //restore isotopes
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.isotopes");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.isotopes.value = prev;
    for (var i=0; i < form.isotopes.length; i++)
    {
   	  if (form.isotopes[i].value == prev)
      {
        form.isotopes[i].checked = true;
      }
    }
    
    //restore radicals
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.radicals");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.radicals.value = prev;
    for (var i=0; i < form.radicals.length; i++)
    {
   	  if (form.radicals[i].value == prev)
      {
        form.radicals[i].checked = true;
      }
    }
    
    //restore valence
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.valence");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.valence.value = prev;
    for (var i=0; i < form.valence.length; i++)
    {
   	  if (form.valence[i].value == prev)
      {
        form.valence[i].checked = true;
      }
    }
    
    
    //restore vague bond
    prev='<% 
    prev=(String)session.getAttribute(
            sessionVarPrefix+"query.prev.vaguebond");
    if (prev!=null) {
        out.print(prev);
    }
    %>';
    form.vaguebond.value = prev;
    for (var i=0; i < form.vaguebond.length; i++)
    {
   	  if (form.vaguebond[i].value == prev)
      {
        form.vaguebond[i].checked = true;
      }
    }
    
    disabler();
}

function updateDefaultThreshold() {
//default threshold if needed:
    if (form.dissimilarityThreshold) {
        if (form.MD) {
            var defaultThreshold = new Array(<%
            for(int i=0; i<default_threshold.length; i++) {
                float[] th=default_threshold[i];
                if(i!=0) {
                        out.println(",");
                    }
                out.print(" new Array (");
                for(int j=0; j<th.length; j++) {
                    if(j!=0) {
                        out.println(",");
                    }
                    out.println("'"+th[j]+"'");
                }
                out.print(")");
            }
            %>);
            form.dissimilarityThreshold.value=
                    defaultThreshold[form.MD.selectedIndex][form.MDConfig.selectedIndex];
        } else {
            form.dissimilarityThreshold.value='0.1';
        }
    }
}

function searchTypeChanged() {
    updateDefaultThreshold();
    disabler();
    
    //automatically enabling alignment and coloring if "Substructure"
    //mode was selected:
    form = document.queryForm;
    var index = form.type.selectedIndex;
    var value = form.type.options[index].value;
}

function setDefaultOptionValues(sSearchType){
    if (sSearchType == "Substructure"){
        form.stereochemExact.checked=false;
        form.stereochemDiast.checked=false;
        form.stereochemOn.checked=true;
        form.stereochemOff.checked=false;
        form.tautomersOn.checked=false;
	form.tautomersOff.checked=true;
	form.dbscMarked.checked=true;
	form.dbscAll.checked=false;
	form.dbscOff.checked=false;
	form.chargesOn.checked=true;
	form.chargesExact.checked=false;
	form.chargesIgnore.checked=false;
	form.isotopesOn.checked=true;
	form.isotopesExact.checked=false;
	form.isotopesIgnore.checked=false;
	form.radicalsOn.checked=true;
	form.radicalsExact.checked=false;
	form.radicalsIgnore.checked=false;
	form.valenceOn.checked=true;
	form.valenceIgnore.checked=false;
	form.vaguebondOff.checked=false;
	form.vaguebondAmbigousAromaticity.checked=true;
	form.vaguebondRingBounds.checked=false;
	form.vaguebondAllBounds.checked=false;
	form.vaguebondIgnore.checked=false;
	
    }
    else if (sSearchType == "Duplicate"){
        form.stereochemExact.checked=true;
        form.stereochemDiast.checked=false;
        form.stereochemOn.checked=false;
        form.stereochemOff.checked=false;
        form.tautomersOn.checked=false;
	form.tautomersOff.checked=true;       
    }
}

// Fades an element
// elName - id of the element
// start - time in ms when the fading should start
// steps - number of fading steps
// time - the length of the fade in ms
function fader(elName,start,steps,time) {
  setOpacity(elName,100); // To prevent flicker in Firefox
                          // The first time the opacity is set
                          // the element flickers in Firefox
  fadeStep = 100/steps;
  timeStep = time/steps;
  opacity = 100;
  time = start + 100;
  while (opacity >=0) {
    window.setTimeout("setOpacity('"+elName+"',"+opacity+")",time);
    opacity -= fadeStep;
    time += timeStep;
  }
}
function setOpacity(elName,opacity) {
  opacity = (opacity == 100)?99:opacity;
  el = document.getElementById(elName);
  // IE
  el.style.filter = "alpha(opacity:"+opacity+")";
  // Safari < 1.2, Konqueror
  el.style.KHTMLOpacity = opacity/100;
  // Old Mozilla
  el.style.MozOpacity = opacity/100;
  // Safari >= 1.2, Firefox and Mozilla, CSS3
  el.style.opacity = opacity/100
}

function displayWarning(sAlertName){
    var oMessage = document.getElementById(sAlertName);
    oMessage.style.visibility = "visible";
    fader(sAlertName,4000,50,2500);
}

function disabler() {
    form = document.queryForm;
    var index = form.type.selectedIndex;
    var value = form.type.options[index].value;
    var tableType = <%= tableType %>

    //search type -> dissim. type , comment , threshold

    if(value == "Similarity") {
        if (form.MD) {
            form.MD.disabled=false;
            form.MDComment.disabled=false;
        }
        form.dissimilarityThreshold.disabled=false;
    } else {
        if (form.MD) {
            form.MD.disabled=true;
            form.MDComment.disabled=true;
        }
        if (form.dissimilarityThreshold) {
            form.dissimilarityThreshold.disabled=true;
        }
    }

    //search type -> checkboxes
    var adv2 = document.getElementById("adv2");
    var adv4 = document.getElementById("adv4");
    var stereochemOn = document.getElementById("stereochemOnLine");
    var dbsc = document.getElementById("dbsc");
    var advOptionsTab = document.getElementById("advancedOptions");
    
    if (tableType == <%= DatabaseProperties.TABLE_TYPE_QUERY_STRUCTURES%>){
    	form.tautomersOn.disabled=true;
		form.tautomersOff.disabled=true;
    }
    else if(value == "Duplicate") {
        if (prevSearchType == "Substructure"  || prevSearchType == "Similarity"  || prevSearchType == "Superstructure"  || prevSearchType == "Full"  || prevSearchType == "Full fragment"){
            setDefaultOptionValues("Duplicate");
            displayWarning("searchTypeChangedAlert");
        }
        form.stereochemExact.disabled=false;
        form.stereochemDiast.disabled=false;
        form.stereochemOff.disabled=false;
        form.tautomersOn.disabled=false;
	form.tautomersOff.disabled=false;
    	form.dbscMarked.disabled=true;
	form.dbscAll.disabled=true;
	form.dbscOff.disabled=true;
	form.chargesOn.disabled=true;
	form.chargesExact.disabled=true;
	form.chargesIgnore.disabled=true;
	form.isotopesOn.disabled=true;
	form.isotopesExact.disabled=true;
	form.isotopesIgnore.disabled=true;
	form.radicalsOn.disabled=true;
	form.radicalsExact.disabled=true;
	form.radicalsIgnore.disabled=true;
	form.valenceOn.disabled=true;
	form.valenceIgnore.disabled=true;
	form.vaguebondOff.disabled=true;
	form.vaguebondAmbigousAromaticity.disabled=true;
	form.vaguebondRingBounds.disabled=true;
	form.vaguebondAllBounds.disabled=true;
	form.vaguebondIgnore.disabled=true;
	adv2.style.display = "none";
	adv4.style.display = "none";
	dbsc.style.display = "none";
	stereochemOn.style.display = "none";
        advOptionsTab.style.color = "#000000";
    }
    else if(value == "Similarity") {
	form.tautomersOn.disabled=true;
	form.tautomersOff.disabled=true;
	form.stereochemOn.disabled=true;
	form.stereochemDiast.disabled=true;
	form.stereochemExact.disabled=true;
	form.stereochemOff.disabled=true;
	form.dbscMarked.disabled=true;
	form.dbscAll.disabled=true;
	form.dbscOff.disabled=true;
	form.chargesOn.disabled=true;
	form.chargesExact.disabled=true;
	form.chargesIgnore.disabled=true;
	form.isotopesOn.disabled=true;
	form.isotopesExact.disabled=true;
	form.isotopesIgnore.disabled=true;
	form.radicalsOn.disabled=true;
	form.radicalsExact.disabled=true;
	form.radicalsIgnore.disabled=true;
	form.valenceOn.disabled=true;
	form.valenceIgnore.disabled=true;
	form.vaguebondOff.disabled=true;
	form.vaguebondAmbigousAromaticity.disabled=true;
	form.vaguebondRingBounds.disabled=true;
	form.vaguebondAllBounds.disabled=true;
	form.vaguebondIgnore.disabled=true;
	advOptionsTab.style.color = "#CACACA";
	
    } else {
        form.stereochemOn.disabled=false;
        if (prevSearchType == "Duplicate" || prevSearchType == "Similarity"){
            setDefaultOptionValues("Substructure");
            displayWarning("searchTypeChangedAlert");
        }
        form.tautomersOn.disabled=false;
        form.tautomersOff.disabled=false;
        form.stereochemExact.disabled=false;
        form.stereochemDiast.disabled=false;
	form.stereochemOff.disabled=false;
	form.dbscMarked.disabled=false;
	form.dbscAll.disabled=false;
	form.dbscOff.disabled=false;
	form.chargesOn.disabled=false;
	form.chargesExact.disabled=false;
	form.chargesIgnore.disabled=false;
	form.isotopesOn.disabled=false;
	form.isotopesExact.disabled=false;
	form.isotopesIgnore.disabled=false;
	form.radicalsOn.disabled=false;
	form.radicalsExact.disabled=false;
	form.radicalsIgnore.disabled=false;
	form.valenceOn.disabled=false;
	form.valenceIgnore.disabled=false;
	form.vaguebondOff.disabled=false;
	form.vaguebondAmbigousAromaticity.disabled=false;
	form.vaguebondRingBounds.disabled=false;
	form.vaguebondAllBounds.disabled=false;
	form.vaguebondIgnore.disabled=false;
	if (adv2.style.display == "none" || adv4.style.display == "none" || stereochemOn.style.display == "none"){
	    adv2.style.display = "block";
	    adv4.style.display = "block";
	    dbsc.style.display = "block";
	    stereochemOn.style.display = "inline";
	}
	advOptionsTab.style.color = "#000000";
    }
    
    prevSearchType = value;

    //dissim type -> dissim config


    if (form.MD) {
        index = form.MD.selectedIndex;
        if(form.MD.disabled) {
            form.MDConfig.disabled=true;
        } else {
            form.MDConfig.disabled=false;
        }
    }
}

/**
 * Updating MD config options
 */
function updateMDConfigs() {
    form = document.queryForm;
    if (!form.MD) {
        return;
    }
    //cleaning:
    form.MDConfig.length=0;
    //filling up:
    var cd_index = form.MD.selectedIndex;
    var configs = new Array(<%
    for(int i=0; i<descriptorConfigs.length; i++) {
        String[] configs=descriptorConfigs[i];
        if(i!=0) {
                out.println(",");
            }
        out.print(" new Array(");
        for(int j=0; j<configs.length; j++) {
            if(j!=0) {
                out.println(",");
            }
            out.println("'"+configs[j]+"'");
        }
        out.print(")");
    }
    %>);


    var index = form.MD.selectedIndex;
    var met=configs[index];
    var builtInMetric = (<%=metrics!=null%>) && (index == 0);
    for(var i=0;i<met.length;i++) {
        var config = met[i];
        form.MDConfig.options[i] = new Option(config,
        i==0 && !builtInMetric  ? ".default_config." : config      
        ); 
    }
    var defaultMetric=<%=metrics!=null ? metrics.defaultMetricIndex : 0%>;
    if (form.MD[index].value!=".embedded.") {
        defaultMetric=0;
    }
    form.MDConfig.options[defaultMetric].selected = true;
    updateDefaultThreshold();
    disabler();
}

function showComments() {
    var comments = new Array(
<%
    for(int i=0; i<descriptor_comments.length; i++) {
        if (i>0) {
            out.println(",");
        }
        out.println("'"+descriptor_comments[i]+"'");
    }
    %>);
    var index = form.MD.selectedIndex;
    alert(comments[index]);
}

var filters = new Array(<%
    for(int i=0; i<filters.size(); i++) {
        String filter=((String[])filters.get(i))[1];
        filter=HTMLTools.convertForJavaScript(filter);

        if(i!=0) {
                out.print(",");
        }
        out.print("\""+filter+"\"");
    }
    %>);

function setFilter() {
    form = document.queryForm;
    var index = form.filter.selectedIndex;
    if (index==0) {
        return;
    }
    form.chemterm.value=filters[index-1];
}



/* The next 2 functions are for page reloading for back button :
 *   NOT IN USE CURRENTLY
*/

function y2k(number) { return (number < 1000) ? number + 1900 : number; }

function reloadPageIfNeeded() {
    var now = new Date();
    var nowsecs = Date.UTC(y2k(now.getYear()),now.getMonth(),now.getDate(),
            now.getHours(),now.getMinutes(),now.getSeconds());

    var thensecs = '<%
    String qs=request.getQueryString();
    if (qs!=null) {
        out.print(qs);
    } else {
        out.print("0");
    }
    %>';
    //alert(thensecs+' : '+nowsecs);
    var difference = nowsecs - thensecs;
    if ((nowsecs - thensecs) > 20000) {
        location.href = location.href.substring(0,location.href.length
        - location.search.length) + '?' + nowsecs;
    }

}

activeTab = "baseOptions";

function switcPanel(oTab){
        form = document.queryForm;
        var index = form.type.selectedIndex;
	if (oTab && form.type.options[index].value != "Similarity"){
		var oPanel = document.getElementById(oTab.id+"Div");
		var oActivePanel = document.getElementById(activeTab+"Div");
		var oActiveTab = document.getElementById(activeTab);
		
		if (oPanel.style.display == "none"){
			oActivePanel.style.display = "none";
			oPanel.style.display = "block";
			oTab.className = "tabActive";
			oActiveTab.className = "tabInactive";
			activeTab = oTab.id
		}
	}
}

// -->
</script>
<script language="JavaScript1.1" src="../../marvin/marvin.js"></script>
<link rel="stylesheet" href="query.css" type="text/css" />
</head>
<body onload="sketcherLoaded=true;restoreOptions();preloadImages('../../images/chemaxon_high.gif');preloadImages('../../images/search_high.gif');preloadImages('../../images/help_high.gif');restoreOptions()">
	<form method="post" name="queryForm">
	    <input type="hidden" name="molfile"/>
	    <input type="hidden" name="startTimeAtClient"/>
	    
	</div>
	<div id="JChemLogo" style="position:absolute; top:25px; left:80px;">
		Structure table: <b><%=structureTableName%>&nbsp;</b>
	</div>
	<div style="position:absolute; top:25px; left:280px;">
	  	<input type="button" onclick="submitIfLoaded('search')" value="Search" style="width:80px;"/>
	</div>
	<div style="position:absolute; top:25px; left:370px;">
	  	<input type="button" onclick="help()" value="Help" style="width:80px;"/>
	</div>	
	<!-- div style="position:absolute; top:45px; left:280px;">
		<a href="http://www.chemaxon.com" target="_blank" onmouseout="swapImgRestore()" onmouseover="swapImage('document.chemaxon','document.chemaxon','../../images/chemaxon_high.gif')"><img name="chemaxon" border=0 src="../../images/chemaxon_norm.gif" width=144 height=43 alt=""></a>
	</div -->	    
	<div style="position:absolute; top:60px; left:40px;">
		<script language="JavaScript1.1">
            <!--
            msketch_name="msketch";
            msketch_begin("../../marvin", 460, 460);
            msketch_param("molbg", "#F0F0F0");
            msketch_param("implicitH", "off");
            msketch_param("undo", "50");
            msketch_param("mol","<%=HTMLTools.convertForJavaScript(molFile)%>");           
            //msketch.param("debug", 2);
            msketch_end();
            //-->
		</script>

<%                                        
if (tableType != DatabaseProperties.TABLE_TYPE_MARKUSH_LIBRARIES) {
%>
		<table border=0>
			<tr>
	 			<td>
       				<a target="_blank" href="../../doc/user/ChemicalTerms.html">Chemical Terms</a>
           			filter:		
           		</td>
<%
    if (filters.size()>0) {
%>
            <td align=right>
                <select name="filter" onchange="setFilter()">
                <option value="0"> -- Select filter -- </option>
<%
            for (int x=0; x<filters.size() ; x++) {%>
                        <option value="<%=x+1%>"><%=((String[])filters.get(x))[0]%></option>
<%          }
%>
                </select>
<%
    }
%>
		</td>
            </tr>
            <tr><td colspan=2 valign=top>
<%
                prev=(String)session.getAttribute(sessionVarPrefix+
                        "query.prev.chemterm");
                if (prev==null) {
                    prev="";
                }
%>
		<textarea name="chemterm" rows=5 cols=50><%=prev%></textarea></td>
            </tr>
        </table>
<%
}
%> 
	</div>
	<div id="baseOptions" onclick="switcPanel(this)" class="tabActive" style="left:550px;">
		main options
	</div>
	<div id="advancedOptions" onclick="switcPanel(this)" class="tabInactive" style="left:655px;">
		advanced&nbsp;options
	</div>
    <div id="baseOptionsDiv" class="optionPanel" style="display:block;">
		<table border="0" cellpadding="0" cellspacing="5">
            <tr>
                <td>
                    <font face="helvetica" size="1">
                    Search type:
                    </font>
                </td>
                <td>
                    <select name="type" onchange="searchTypeChanged()">
<%                                        
if (tableType != DatabaseProperties.TABLE_TYPE_QUERY_STRUCTURES) {
%>  
                        <option value="Substructure">Substructure</option>
<%
}
%> 
                     
<%                                        
if (tableType != DatabaseProperties.TABLE_TYPE_MARKUSH_LIBRARIES) {
%>                       
                        <option value="Superstructure">Superstructure</option>
<%
}
%>  
                                            
                        <option value="Full">Full</option>
                        <option value="Full fragment">Full fragment</option>
<%                                        
if (descriptor_names.length>0) {
%>
                        <option value="Similarity">Similarity</option>
<%
}
%>                            
                        <option value="Duplicate">Duplicate</option>
                    </select>
               </td>
            </tr>
<%
if (descriptor_names.length>0) {%>
            <tr>
                <td>
                    <font face="helvetica" size="1">
                    Descriptor type:
                    </font>
                </td>
                  <td>
                      <select name="MD" onchange="updateMDConfigs()">
<%
if (embeddedDesc>0) {
%>                                    
                         <option value=".embedded."><%=descriptor_names[0]%></option>
<%
}
    for (int x=0; x<desc_num ; x++) {
        out.println("<option value="+descriptor_ids[x]+">"
                +descriptor_ids[x]+" : "+descriptor_names[x+embeddedDesc]+"</option>");
    }
%>

                     </select>
                 </td>
                 <td>
                     <input type=button name="MDComment" value=" ? " onclick="showComments()"/>
                 </td>
             </tr>

             <tr>
                 <td>
                     <font face="helvetica" size="1">
                     Screening config:
                     </font>
                 </td>
                 <td>
                     <select name="MDConfig" onchange="updateDefaultThreshold()"> 
                         <!-- filled later by Javascript -->
                     </select>
                 </td>
             </tr>

<%
}           // end of "if" statement
%>

<%
if (descriptor_names.length>0) {
%>

              <tr>
                  <td>
                      <font face="helvetica" size="1">
                      Dissimilarity<br/>threshold:
                      </font>
                  </td>
                  <td>
                      <input name="dissimilarityThreshold"/>
                  </td>
              </tr>
<%
}
%>                            
              <tr>
                  <td>
                      <font face="helvetica" size="1">
                      Max. hits:
                      </font>
                  </td>
                  <td>
                      <select name="maxResultCount">
                          <option value=1>1</option>
                          <option value=2>2</option>
                          <option value=3>3</option>
                          <option value=4>4</option>
                          <option value=5>5</option>
                          <option value=10>10</option>
                          <option value=50>50</option>
                          <option value=100>100</option>
                          <option value="200" selected>200</option>
                          <option value=500>500</option>
                          <option value=1000>1000</option>
                          <option value=2000>2000</option>
                          <option value=5000>5000</option>
                          <option value=0>unlimited</option>
                      </select>
                  </td>
              </tr>

              <tr>
                  <td>
                      <font face="helvetica" size="1">
                      Max. time:
                      </font>
                  </td>
              </tr>
<%
if (searchesToRemember!=0) {
%>
              <tr>
                  <td>
                      <font face="helvetica" size="1">
                      Search prev. results:
                       </font>
                   </td>
                   <td>
                        <select name="prevhits">
                            <option value=0>No</option>
<%

int[][] prevHitLists=(int[][]) session.getAttribute(sessionVarPrefix+"prevHitLists");
String[] prevHitTimes=(String[]) session.getAttribute(sessionVarPrefix+"prevHitTimes");
if (prevHitLists==null || prevHitTimes==null) {
    prevHitLists=new int[0][];
}


for (int x=0; x< prevHitLists.length; x++) {
    int[] hits=prevHitLists[x];
    if (hits==null) {
        break; //no more hits to display
     }
     String dispString=prevHitTimes[x] + "    " + hits.length
             + " hits";
     dispString=StringUtil.replaceString(dispString, " ", "&nbsp;");
%>
                                 <option value=<%=x+1%>><%=dispString%></option>
<%
   }
%>
                               </select>
                           </td>
                       </tr>
<%
}
%>
                           <tr>
                               <td colspan="2">
			    <input type="checkbox" name="nonhits" onclick="disabler()"/>
                                   <font face="helvetica" size="1">
                                   Return non-hits (inverse result set)
                                   </font>
                               </td>
		    </tr>
                       </table>
                   </td>
               </tr>
               <tr>
                   <td>
                       <p><font face=helvetica size="-1">Conditions:</font></p><br/>
                   </td>
               </tr>
               <tr>
                   <td colspan=2>
                       <table border="0" cellpadding="0" cellspacing="0">
           <%
               for (int x=0; x<fieldNames.size(); x++) {
                   String text=(String)fieldTexts.get(x);
                   String name=(String)fieldNames.get(x);
                   String type=((Integer)fieldTypes.get(x)).toString();
                   %>
                       <tr><td align="right"><font face="helvetica" size="1"><%=text%></font> </td>
                           <td><select name="relation<%=x%>">
                                   <option value="<">&lt;</option>
                                   <option value="<=">&lt;=</option>
                                   <option value="=" selected>=</option>
                                   <option value=">=">&gt;=</option>
                                   <option value=">">&gt;</option>
                               </select></td>
                           <td><input type="text" name="value<%=x%>" size="15"/>
                               <input type="hidden" name="field<%=x%>" value="<%=name%>"/>
                               <input type="hidden" name="type<%=x%>" value="<%=type%>"/>
                           </td>
                       </tr>
	<%
    }
%>
                       </table>
                   </td>
               </tr>
           </table>
           <div id="searchTypeChangedAlert" style="visibility:hidden; font-size:12px; padding-top:15px; width:340px; color:red;">Warning! Advanced search options are set to default values, according to current search type!</div>
       </div>
       <div id="advancedOptionsDiv" class="optionPanel" style="display:none; font-size:12px;">
       		<fieldset style="width:210px">
       		<legend>Stereochemistry</legend>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
				  <td>
				  	<table><tr>  
				  		<td><span id="stereochemOnLine" style="white-space: nowrap;"><input type="radio" id="stereochemOn" name="stereochem" checked value="on"/>On</span></td>
				  		<td><input type="radio" id="stereochemExact" name="stereochem" value="exact"/>Exact</td></tr>
				  		<tr><td><input type="radio" id="stereochemDiast" name="stereochem" value="diast"/>Diastereomers</td>
				  		<td><input type="radio" id="stereochemOff" name="stereochem" value="off"/>Off</td>
				  	</tr></table>
				  </td>
				</tr>
				<tr>
				  <td><span id="dbsc">    
				          Double bond stereo check<br/>
				  	  <input type="radio" id="dbscAll" name="doubleBondStereoCheck" value="0"/>All
				  	  <input type="radio" id="dbscMarked" name="doubleBondStereoCheck" value="1" checked/>Marked
				  	  <input type="radio" id="dbscOff" name="doubleBondStereoCheck" value="2"/>Off
				       </span>
				  </td>
				</tr>
			</table>
			</fieldset>
			<div id="adv2">
			<fieldset style="width:210px">
       		<legend>Atom matching</legend>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
				  <td>Charges:</td>
				  <td><input type="radio" id="chargesOn" name="charges" value="0" checked/>On</td>
				  <td><input type="radio" id="chargesExact" name="charges" value="1"/>Exact</td>
				  <td><input type="radio" id="chargesIgnore" name="charges" value="2"/>Ignore</td>
				</tr>
				<tr>
				  <td>Isotopes:</td>
				  <td><input type="radio" id="isotopesOn" name="isotopes" value="0" checked/>On</td>
				  <td><input type="radio" id="isotopesExact" name="isotopes" value="1"/>Exact</td>
				  <td><input type="radio" id="isotopesIgnore" name="isotopes" value="2"/>Ignore</td>
				</tr>
				<tr>
				  <td>Radicals:</td>
				  <td><input type="radio" id="radicalsOn" name="radicals" value="0" checked/>On</td>
				  <td><input type="radio" id="radicalsExact" name="radicals" value="1"/>Exact</td>
				  <td><input type="radio" id="radicalsIgnore" name="radicals" value="2"/>Ignore</td>
				</tr>
				<tr>
				  <td>Valence:</td>
				  <td><input type="radio" id="valenceOn" name="valence" value="0" checked/>On</td>
				  <td></td>
				  <td><input type="radio" id="valenceIgnore" name="valence" value="1"/>Ignore</td>
				  </td>
				</tr>
			</table>
			</fieldset>
			</div><div id="adv3">
			<fieldset style="width:210px">
       		<legend>Tautomer</legend>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
				  <td><input type="radio" id="tautomersOn" name="tautomers" value="1"/>On</td>
				  <td></td>
				  <td><input type="radio" id="tautomersOff" name="tautomers" value="0" checked/>Off</td>
				  </td>
				</tr>
			</table>
			</fieldset>
			</div><div id="adv4">
			<fieldset style="width:210px">
       		<legend>Vague bond</legend>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
				  <td><input type="radio" id="vaguebondOff" name="vaguebond" value="1"/></td>
				  <td>Off</td>				  
				</tr>
				<tr>				  
				  <td><input type="radio" id="vaguebondAmbigousAromaticity" name="vaguebond" value="0" checked/></td>
				  <td>Ambigous aromacity 5 memberd rings</td>				  
				</tr>
				<tr>				  
				  <td><input type="radio" id="vaguebondRingBounds" name="vaguebond" value="2"/></td>
				  <td>Ring bonds &quot;or aromatic&quot;</td>				  
				</tr>
				<tr>				  
				  <td><input type="radio" id="vaguebondAllBounds" name="vaguebond" value="3"/></td>	
				  <td>All bonds &quot;or aromatic&quot;</td>			  
				</tr>
				<tr>				  
				  <td><input type="radio" id="vaguebondIgnore" name="vaguebond" value="4"/></td>	
				  <td>Ignore bond types</td>			  
				</tr>
			</table>
			</fieldset>
			<br/>Additional <a href="../../doc/dev/cartridge/cartapi.html#jc_compare" target="_blank">Cartridge-style</a> search options* :
<%
			prev=(String)session.getAttribute(sessionVarPrefix+"query.prev.additionalOptions");
			if (prev==null) {
			    prev="";
			}
%>
			<br/><textarea name="addopts" rows=6 cols=26><%=prev%></textarea>
			<br/>*- override the same options are set on the Main 
			<br/>and Advanced panes.
			</div>
       </div>
	</form>
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