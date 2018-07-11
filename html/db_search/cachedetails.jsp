
<%@page contentType="text/html" import="chemaxon.jchem.db.cache.CacheManager"%>
<%@ include file="init.jsp" %>
<html>
  <head><title>Structure cache details</title></head>
  <body bgcolor="#FFFFFF">
  <h2>Structure cache details</h2>
  <p>

<%!
    private double toMB(long size) {
        return Math.round((double)size/1024d/1024d*100d)/100.0;
    }
%>

<%
    Hashtable tables=CacheManager.INSTANCE.getCachedTables();
    long totalCacheSize=0;
    Object[] values=tables.values().toArray();
    for (int x=0; x< values.length ; x++) {
        totalCacheSize+=((Long)values[x]).longValue();
    }
%>

  <table border="0" cellspacing="0" cellpadding="5">
    <tr>
        <td>Number of cached tables:</td>
	<td width="30">&nbsp;</td>
        <td><%=tables.size()%></td>
    <tr>
    <tr>
        <td>Total cache size (MB):</td>
	<td width="30">&nbsp;</td>
        <td><%=toMB(totalCacheSize)%></td>
    <tr>
  </table>

<%
    if (tables.size()>0) {
%>

    <p>
    <table border="1" cellspacing="0" cellpadding="10">
        <tr>
            <td><b>Table name</b></td>
            <td><b>Size in Cache (MB)</b></td>
        <tr>
<%
        Enumeration keys=tables.keys();
        while (keys.hasMoreElements()) {
            String key=(String) keys.nextElement();
            Long value=(Long) tables.get(key);
%>
        <tr>
            <td><%=key%></td>
            <td align="right"><%=toMB(value.longValue())%></td>
        <tr>
<%
        }
%>
    </table>
<%
    }
%>    
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