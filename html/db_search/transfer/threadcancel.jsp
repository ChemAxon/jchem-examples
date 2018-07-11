<%--

 threadcancel.jsp

 ChemAxon Ltd., 2002

 Stops the upload or import thread when cancel is pressed or when a limit for
 the number of molecules is set. 

--%> 
<%@ page import="java.io.File,chemaxon.util.*,chemaxon.jchem.db.*,chemaxon.jchem.file.*" errorPage="../errorpage.jsp"%>
<%@ include file="../init.jsp"%>
<%


String importFinishedParam = request.getParameter("importFinished");

//If the import progress was cancelled from the importconnects.jsp
String cancelledFromCon = request.getParameter("cancelFromCon");

String tmpFile = null;

UploadThread uth = null;
Importer ith = null;


if(cancelledFromCon==null) {

    //Get the thread from the session
    if(importFinishedParam==null) {
        uth = (UploadThread)session.getAttribute(sessionVarPrefix+"UploadThread");
	tmpFile = (String)session.getAttribute(sessionVarPrefix+"tmpFile");
    } else {
    	ith = (Importer)session.getAttribute(sessionVarPrefix+"ImportThread");
    }

    if(importFinishedParam==null) {
        if(uth!=null) {
            // Stop the upload thread.
            uth.setFinished(true);
            session.removeAttribute(sessionVarPrefix+"UploadThread");
            session.removeAttribute(sessionVarPrefix+"tmpFile");
            // Delete the tmp file
            try {
                File file = new File(tmpFile);
                file.delete();
            } catch (Exception e) {
                 System.err.println(e.getMessage());
            }
        }
    } else {
        if((ith!=null)&&(importFinishedParam.equals("true"))) {
            //Stop the import thread.
            ith.cancel();
            session.removeAttribute(sessionVarPrefix+"ImportThread");
        }
    }
} else {
    // If the import progress was cancelled from the importconnects.jsp
    // deletes the tmp file.
    tmpFile = (String)session.getAttribute(sessionVarPrefix+"tmpFile");
    session.removeAttribute(sessionVarPrefix+"tmpFile");

    try{
	File f = new File(tmpFile);
	f.delete();
    } catch (Exception e) {
	System.err.println(e.getMessage());
    }
}

%>
<script language="javascript">
<!--
    window.close();
//-->
</script>
