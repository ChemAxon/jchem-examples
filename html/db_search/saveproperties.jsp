<%@page contentType="text/html"%>
<html>
<head><title>JSP Page</title></head>
<body>
<%@ page import="java.io.*, chemaxon.util.*,
                 java.util.List, java.util.ArrayList,
                 java.util.Properties" errorPage="errorpage.jsp"%>
<pre>
<%

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


    Properties props=new Properties();
    //loading extra properties first, they are overridden by fix properties:
    InputStream is=
            new ByteArrayInputStream(
                    request.getParameter("otherProps").getBytes());
    props.load(is);

    java.util.List propertiesWithFields= new ArrayList();
    propertiesWithFields.add("driver");
    propertiesWithFields.add("url");
    propertiesWithFields.add("propertyTableName");
    propertiesWithFields.add("username");
    propertiesWithFields.add("password");
    propertiesWithFields.add("readOnlyTableNames");
    propertiesWithFields.add("chemicalTermsFilterFile");
    propertiesWithFields.add("useStructureCache");
    propertiesWithFields.add("searchesToRemember");

    for (int x=0; x< propertiesWithFields.size(); x++) {
        String propertyName=(String) propertiesWithFields.get(x);
        String value=request.getParameter(propertyName);
        if (propertyName.equals("useStructureCache")) {
            if (value!=null) {
                value="true";
            } else {
                value="false";
            }
        }
        if (value==null) {
            value="";
        }

        props.setProperty(propertyName, value);

    }

    FileOutputStream fos=new FileOutputStream(propsFname);
    props.store(fos, "JSP Database example settings.");
    fos.close();


%><jsp:forward page="index.jsp" /><%
%>
</pre>
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
