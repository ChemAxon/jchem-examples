<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="simple-page2html.xsl"/>

  <xsl:template match="headscript">
    <!--script language="javascript">
            <xsl:value-of select="."/>
    </script-->
  </xsl:template>

  <xsl:template match="framescript">
    <!--script language="javascript">
      <xsl:value-of select="."/>
    </script-->
  </xsl:template>


  <xsl:template match="jscript">
    <!-- a query.js -bol a query-t helyettesitse be parameterbol -->
    <xsl:if test="@file">
      <script language="javascript" src="resources/{@file}"></script>
    </xsl:if>
    <xsl:if test="@function">
      <script language="javascript">
  	<xsl:value-of select="@function"/>
      </script>
    </xsl:if>
  </xsl:template>

  <xsl:template match="msketch">
    <script LANGUAGE="JavaScript1.1" SRC="marvin.js"></script>
    <script LANGUAGE="JavaScript1.1">
    msketch_name="<xsl:value-of select="@name"/>";
    
    msketch_begin("<xsl:value-of select="begin/@codebase"/>",
		  "<xsl:value-of select="begin/@width"/>",
		  "<xsl:value-of select="begin/@height"/>");
    <xsl:for-each select="./param">
      msketch_param("<xsl:value-of select="@name"/>",
		    "<xsl:value-of select="@value"/>");
    </xsl:for-each>
    msketch_end();
    </script>
  </xsl:template>

  <xsl:template match="mview">
    <xsl:if test="@align">
    </xsl:if>
    <script LANGUAGE="JavaScript1.1" SRC="marvin.js"></script>
    <script LANGUAGE="JavaScript1.1">
    mview_name="<xsl:value-of select="@name"/>";
    <xsl:choose>
        <xsl:when test='begin/@width'>
        mview_begin("<xsl:value-of select="begin/@codebase"/>",
		  "<xsl:value-of select="begin/@width"/>",
		  "<xsl:value-of select="begin/@height"/>");
	</xsl:when>
	<xsl:when test='begin/width'>
	mview_begin("<xsl:value-of select="begin/@codebase"/>",
		  "<xsl:value-of select="begin/width"/>",
		  "<xsl:value-of select="begin/height"/>");
	</xsl:when>
    </xsl:choose>
    
    <xsl:for-each select="./param">
	<xsl:choose>
            <xsl:when test='@name'>
	        mview_param("<xsl:value-of select="@name"/>",
		    	    "<xsl:value-of select="@value"/>");
	    </xsl:when>
	    <xsl:when test='name'>
	        mview_param("<xsl:value-of select="name"/>",
	    	    	    "<xsl:value-of select="value"/>");
	    </xsl:when>
	</xsl:choose>
    </xsl:for-each>
    mview_end();
    </script>
    <xsl:if test="@align">
    </xsl:if>
  </xsl:template>



  <!--xsl:template match="@*|node()" priority="-1">
   <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
  </xsl:template-->

</xsl:stylesheet>
