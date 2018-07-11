<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="page">
    <html>
    <head>
    <title><xsl:value-of select="title"/></title>
    <xsl:if test="jscript">
      <xsl:apply-templates select="jscript"/>
    </xsl:if>
    <xsl:if test="headscript">
        <script language="javascript">
            <xsl:value-of select="headscript"/>
        </script>
    </xsl:if>
    </head>
    <xsl:if test="framescript">
	<script language="javascript">
	    <xsl:value-of select="framescript"/>
	</script>
    </xsl:if>
    <body bgcolor="#e1e1e1">
	<xsl:apply-templates />
    </body>
    </html>
  </xsl:template>

  <xsl:template match="query_parameters">
    <xsl:variable name="set_name"><xsl:value-of select="@name"/></xsl:variable>
    <xsl:if test="$set_name = validate/root/constraint-set/@name">
      <xsl:for-each select="validate/root/constraint-set/validate">
	<xsl:if test="position() > 5">
	  <xsl:variable name="param_name"><xsl:value-of select="@name"/>
								</xsl:variable>
	  <tr>
	    <td>
		<xsl:value-of select="$param_name"/>: 
	    </td><td>
	      <select name="{$param_name}_relation">
		<option value="&lt;">&lt;</option>
		<option value="&lt;=">&lt;=</option>
		<option value="=">=</option>
		<option value="&gt;=">&gt;=</option>
		<option value="&gt;">&gt;</option>
	      </select>
	    </td><td>
	      <input type="text" name="{$param_name}"/>
	    </td>
	  </tr>
	</xsl:if>
      </xsl:for-each>	
    </xsl:if>
  </xsl:template>

  <xsl:template match="para">
   <p align="left">
    <i><xsl:apply-templates/></i>
   </p>
  </xsl:template>

  <xsl:template match="error">
   <p align="left">
    <b>Error</b>
    <p><xsl:apply-templates/></p>
   </p>
  </xsl:template>

  <xsl:template match="@*|node()" priority="-2">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>
  
  <!--xsl:template match="text()" priority="-1">
    <xsl:value-of select="."/>
  </xsl:template-->

</xsl:stylesheet>
