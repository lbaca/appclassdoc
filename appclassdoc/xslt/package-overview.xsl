<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>

  <xsl:variable name="apiPath">
    <xsl:call-template name="dup">
      <xsl:with-param name="input" select="'../'"/>
      <xsl:with-param name="count" select="number(/package/@level)"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates select="/package"/>
  </xsl:template>

  <xsl:template match="package">
    <html lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title><xsl:value-of select="concat(@name, ' (PeopleSoft API)')"/></title>
        <link rel="stylesheet" type="text/css" href="{$apiPath}../resources/stylesheet.css" title="Style"/>
        <script type="text/javascript" src="{$apiPath}../resources/script.js">/**/</script>
      </head>
      <body>
        <h1 class="bar">
          <!-- <a href="0package-summary.html" target="classFrame"> -->
            <xsl:value-of select="@name"/>
          <!-- </a> -->
        </h1>
        <div class="indexContainer">
          <xsl:if test="class[boolean(@interface)]">
            <h2 title="Interfaces">Interfaces</h2>
            <ul title="Interfaces">
              <xsl:apply-templates select="class[boolean(@interface)]"/>
            </ul>
          </xsl:if>
          <xsl:if test="class[not(boolean(@interface))]">
            <h2 title="Classes">Classes</h2>
            <ul title="Classes">
              <xsl:apply-templates select="class[not(boolean(@interface))]"/>
            </ul>
          </xsl:if>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="class">
    <xsl:choose>
      <xsl:when test="boolean(@interface)">
        <li><a href="{.}.html" title="{concat('interface in ', /package/@name)}" target="classFrame"><span class="interfaceName"><xsl:value-of select="."/></span></a></li>
      </xsl:when>
      <xsl:otherwise>
        <li><a href="{.}.html" title="{concat('class in ', /package/@name)}" target="classFrame"><xsl:value-of select="."/></a></li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="dup">
    <xsl:param name="input"/>
    <xsl:param name="count" select="1"/>
    <xsl:param name="work" select="$input"/>

    <xsl:choose>
      <xsl:when test="not($count) or not($input)"/>
      <xsl:when test="$count=1">
        <xsl:value-of select="$work"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="dup">
          <xsl:with-param name="input" select="$input"/>
          <xsl:with-param name="count" select="$count - 1"/>
          <xsl:with-param name="work" select="concat($work, $input)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
