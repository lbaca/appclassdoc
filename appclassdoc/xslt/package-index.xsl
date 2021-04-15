<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title>Overview List (PeopleSoft API)</title>
        <link rel="stylesheet" type="text/css" href="resources/stylesheet.css" title="Style"/>
        <script type="text/javascript" src="resources/script.js">/**/</script>
      </head>
      <body>
        <h1 title="PeopleSoft API" class="bar"><strong>PeopleSoft API</strong></h1>
        <div class="indexHeader"><span><a href="classes-frame.html" target="packageFrame"><xsl:text disable-output-escaping="yes">All&amp;nbsp;Classes</xsl:text></a></span></div>
        <div class="indexContainer">
          <h2 title="Packages">Packages</h2>
          <ul title="Packages">
            <xsl:apply-templates select="/packages/package"/>
          </ul>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="package">
    <li><a href="api/{translate(., ':', '/')}/0package.html" target="packageFrame"><xsl:value-of select="."/></a></li>
  </xsl:template>
</xsl:stylesheet>
