<%@ page import="java.sql.*, java.util.*,java.io.*, chemaxon.util.*" %>

<%

String sessionPrefix="jspexample.";

String chemDir = (String)session.getAttribute("chemaxon.dir");
String fileSep=System.getProperty("file.separator");

if (chemDir==null) {
    chemDir=DotfileUtil.getDotDir().getAbsolutePath();
    if (chemDir.endsWith(fileSep)) {
        chemDir=chemDir.substring(0, chemDir.length()-1);
    }
    session.setAttribute("chemaxon.dir",chemDir);   //storing chemaxon directory
    //creating directory, if not exosts:
    File dir=new File(chemDir);
    if (!dir.exists()) {
        dir.mkdir();
    }
}

String propsFname = chemDir + fileSep + ".jchemsite";

//moving configuration file from previous version:
if (!new File(propsFname).exists()) {
    File old=new File(chemDir).getParentFile();
    old=new File(old, ".jchemsite");
    if (old.exists()) {
        old.renameTo(new File(chemDir, ".jchemsite"));
    }
}

Properties props = new Properties();

try {
	props.load(new FileInputStream(propsFname));
} catch(FileNotFoundException exc) {     
   		System.err.println("File not found "+propsFname+" open setup.jsp.");
} catch(IOException exc) {
		System.err.println("Cannot read properties file "+propsFname);
}
String local_driver=props.getProperty("driver");
String local_url=props.getProperty("url");
String local_username=props.getProperty("username");
String local_password=props.getProperty("password");
String local_propertyTableName=props.getProperty("propertyTableName");

String userID = (String)request.getParameter("uid");
String sessionVarPrefix=sessionPrefix + userID + ".";

String readOnlyTableNames=props.getProperty("readOnlyTableNames");
String chemFilterFile=props.getProperty("chemicalTermsFilterFile");

String _prop=props.getProperty("searchesToRemember");
int searchesToRemember=0; //default, if not specified
if (_prop!=null) {
    try {
        searchesToRemember=new Integer(_prop).intValue();
    } catch(NumberFormatException e) {}
}
String reactionTables=props.getProperty("reactionTables");

%>
