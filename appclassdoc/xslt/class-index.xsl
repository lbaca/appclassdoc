<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  
  <xsl:param name="target" select="''"/>
  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>All Classes (PeopleSoft API)</title>
        <link rel="stylesheet" type="text/css" href="resources/stylesheet.css" title="Style"/>
        <script type="text/javascript" src="resources/script.js">/**/</script>
      </head>
      <body>
        <h1 class="bar"><xsl:text disable-output-escaping="yes">All&amp;nbsp;Classes</xsl:text></h1>
        <div class="indexContainer">
          <ul>
            <xsl:apply-templates select="/classes/class"/>
          </ul>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="class">
    <li>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('api/', translate(@package, ':', '/'), '/', ., '.html')"/>
        </xsl:attribute>
        <xsl:if test="$target != ''">
          <xsl:attribute name="target">
            <xsl:value-of select="$target"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="boolean(@interface)">
            <xsl:attribute name="title">
              <xsl:value-of select="concat('interface in ', @package)"/>
            </xsl:attribute>
            <span class="interfaceName"><xsl:value-of select="."/></span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="title">
              <xsl:value-of select="concat('class in ', @package)"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </li>
  </xsl:template>
</xsl:stylesheet>
