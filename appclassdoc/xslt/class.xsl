<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>

  <xsl:variable name="n"><xsl:text>
</xsl:text></xsl:variable>

  <xsl:variable name="apiPath">
    <xsl:call-template name="dup">
      <xsl:with-param name="input" select="'../'"/>
      <xsl:with-param name="count" select="number(/class/package/@level)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="/class"/>
  </xsl:template>

  <xsl:template match="class">
    <xsl:variable name="capType">
      <xsl:choose>
        <xsl:when test="@type = 'class'">
          <xsl:text>Class</xsl:text>
        </xsl:when>
        <xsl:when test="@type = 'interface'">
          <xsl:text>Interface</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@type"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <html lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title><xsl:value-of select="concat(name, ' (PeopleSoft API)')"/></title>
        <link rel="stylesheet" type="text/css" href="{$apiPath}../resources/stylesheet.css" title="Style"/>
        <script type="text/javascript" src="{$apiPath}../resources/script.js">/**/</script>
      </head>
      <body>
        <script type="text/javascript"><xsl:text disable-output-escaping="yes">
    try {
        if (location.href.indexOf('is-external=true') == -1) {
            parent.document.title="</xsl:text><xsl:value-of select="name"/><xsl:text disable-output-escaping="yes"> (PeopleSoft API)";
        }
    }
    catch(err) {
    }
</xsl:text><xsl:if test="methods"><xsl:text>var methods = {</xsl:text><xsl:apply-templates select="methods/method" mode="tabs"/><xsl:text>};
var tabs = {65535:["t0","All Methods"],1:["t1","Concrete Methods"],2:["t2","Abstract Methods"]};
var altColor = "altColor";
var rowColor = "rowColor";
var tableTab = "tableTab";
var activeTableTab = "activeTableTab";</xsl:text></xsl:if>
        </script>
        <noscript>
          <div>JavaScript is disabled on your browser.</div>
        </noscript>
        <!-- ========= START OF TOP NAVBAR ======= -->
        <div class="topNav">
          <a name="navbar.top">
            <!--   -->
          </a>
          <div class="skipNav">
            <a href="#skip.navbar.top" title="Skip navigation links">Skip navigation links</a>
          </div>
          <a name="navbar.top.firstrow">
            <!--   -->
          </a>
          <ul class="navList" title="Navigation">
            <li><a href="{$apiPath}../start-page.html">Overview</a></li>
            <li class="navBarCell1Rev">Class</li>
          </ul>
          <div class="aboutLanguage">
            <strong><xsl:text disable-output-escaping="yes">PeopleSoft&amp;nbsp;API</xsl:text></strong>
          </div>
        </div>
        <div class="subNav">
          <ul class="navList">
            <li><a href="{$apiPath}../index.html?api/{translate(package, ':', '/')}/{name}.html" target="_top">Frames</a></li>
            <li><a href="{name}.html" target="_top"><xsl:text disable-output-escaping="yes">No&amp;nbsp;Frames</xsl:text></a></li>
          </ul>
          <ul class="navList" id="allclasses_navbar_top">
            <li><a href="{$apiPath}../classes-noframe.html"><xsl:text disable-output-escaping="yes">All&amp;nbsp;Classes</xsl:text></a></li>
          </ul>
          <div>
            <script type="text/javascript"><xsl:text disable-output-escaping="yes">
              allClassesLink = document.getElementById("allclasses_navbar_top");
              if(window==top) {
                allClassesLink.style.display = "block";
              }
              else {
                allClassesLink.style.display = "none";
              }</xsl:text>
            </script>
          </div>
        <div>
        <ul class="subNavList">
          <li><xsl:text disable-output-escaping="yes">Summary:&amp;nbsp;</xsl:text></li>
          <li>
            <xsl:choose>
              <xsl:when test="constructor">
                <a href="#constructor.summary">Constr</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Constr</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="constants">
                <a href="#constant.summary">Constant</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Constant</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="properties">
                <a href="#property.summary">Property</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Property</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="getters">
                <a href="#getter.summary">Get</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Get</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="setters">
                <a href="#setter.summary">Set</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Set</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="methods">
                <a href="#method.summary">Method</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Method</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </li>
        </ul>
        <ul class="subNavList">
          <li><xsl:text disable-output-escaping="yes">Detail:&amp;nbsp;</xsl:text></li>
          <li>
            <xsl:choose>
              <xsl:when test="constructor">
                <a href="#constructor.detail">Constr</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Constr</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="constants">
                <a href="#constant.detail">Constant</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Constant</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="properties">
                <a href="#property.detail">Property</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Property</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="getters">
                <a href="#getter.detail">Get</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Get</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="setters">
                <a href="#setter.detail">Get</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Set</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
          </li>
          <li>
            <xsl:choose>
              <xsl:when test="methods">
                <a href="#method.detail">Method</a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Method</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </li>
        </ul>
      </div>
      <a name="skip.navbar.top">
        <!--   -->
      </a></div>
      <!-- ========= END OF TOP NAVBAR ========= -->
      <!-- ======== START OF CLASS DATA ======== -->
      <div class="header">
        <div class="subTitle"><xsl:value-of select="package"/></div>
        <h2 title="{$capType} {name}" class="title"><xsl:value-of select="concat($capType, ' ', name)"/></h2>
      </div>
        <div class="contentContainer">
          <xsl:apply-templates select="hierarchy" mode="open"/>
          <ul class="inheritance"><li><xsl:value-of select="concat(package, ':', name)"/></li></ul>
          <xsl:apply-templates select="hierarchy" mode="close"/>
          <div class="description">
            <ul class="blockList">
              <li class="blockList">
                <xsl:apply-templates select="subclasses"/>
                <hr/>
                <br/>
                <pre><xsl:value-of select="concat(@type, ' ')"/>
                <span class="typeNameLabel"><xsl:value-of select="name"/></span>
                <xsl:apply-templates select="hierarchy/superclass[position() = last()]"/></pre>
                <xsl:apply-templates select="description"/>
              </li>
            </ul>
          </div>
          <div class="summary">
            <ul class="blockList">
              <li class="blockList">
                <xsl:apply-templates select="constructor" mode="summary"/>
                <xsl:apply-templates select="constants" mode="summary"/>
                <xsl:apply-templates select="properties" mode="summary"/>
                <xsl:apply-templates select="getters" mode="summary"/>
                <xsl:apply-templates select="setters" mode="summary"/>
                <xsl:apply-templates select="methods" mode="summary"/>
              </li>
            </ul>
          </div>
          <div class="details">
            <ul class="blockList">
              <li class="blockList">
                <xsl:apply-templates select="constructor" mode="detail"/>
                <xsl:apply-templates select="constants" mode="detail"/>
                <xsl:apply-templates select="properties" mode="detail"/>
                <xsl:apply-templates select="getters" mode="detail"/>
                <xsl:apply-templates select="setters" mode="detail"/>
                <xsl:apply-templates select="methods" mode="detail"/>
              </li>
            </ul>
          </div>
        </div>
        <!-- ========= END OF CLASS DATA ========= -->
        <!-- ======= START OF BOTTOM NAVBAR ====== -->
        <div class="bottomNav">
          <a name="navbar.bottom">
            <!--   -->
          </a>
          <div class="skipNav">
            <a href="#skip.navbar.bottom" title="Skip navigation links">Skip navigation links</a>
          </div>
          <a name="navbar.bottom.firstrow">
            <!--   -->
          </a>
          <ul class="navList" title="Navigation">
            <li><a href="{$apiPath}../start-page.html">Overview</a></li>
            <li class="navBarCell1Rev">Class</li>
          </ul>
          <div class="aboutLanguage">
            <strong><xsl:text disable-output-escaping="yes">PeopleSoft&amp;nbsp;API</xsl:text></strong>
          </div>
        </div>
        <div class="subNav">
          <ul class="navList">
            <li><a href="{$apiPath}../index.html?api/{translate(package, ':', '/')}/{name}.html" target="_top">Frames</a></li>
            <li><a href="{name}.html" target="_top"><xsl:text disable-output-escaping="yes">No&amp;nbsp;Frames</xsl:text></a></li>
          </ul>
          <ul class="navList" id="allclasses_navbar_bottom">
            <li><a href="{$apiPath}../classes-noframe.html"><xsl:text disable-output-escaping="yes">All&amp;nbsp;Classes</xsl:text></a></li>
          </ul>
          <div>
            <script type="text/javascript"><xsl:text disable-output-escaping="yes">
              allClassesLink = document.getElementById("allclasses_navbar_bottom");
              if(window==top) {
                allClassesLink.style.display = "block";
              }
              else {
                allClassesLink.style.display = "none";
              }</xsl:text>
            </script>
          </div>
          <div>
            <ul class="subNavList">
              <li><xsl:text disable-output-escaping="yes">Summary:&amp;nbsp;</xsl:text></li>
              <li>
                <xsl:choose>
                  <xsl:when test="constructor">
                    <a href="#constructor.summary">Constr</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Constr</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="constants">
                    <a href="#constant.summary">Constant</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Constant</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="properties">
                    <a href="#property.summary">Property</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Property</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="getters">
                    <a href="#getter.summary">Get</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Get</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="setters">
                    <a href="#setter.summary">Set</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Set</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="methods">
                    <a href="#method.summary">Method</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Method</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </ul>
            <ul class="subNavList">
              <li><xsl:text disable-output-escaping="yes">Detail:&amp;nbsp;</xsl:text></li>
              <li>
                <xsl:choose>
                  <xsl:when test="constructor">
                    <a href="#constructor.detail">Constr</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Constr</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="constants">
                    <a href="#constant.detail">Constant</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Constant</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="properties">
                    <a href="#property.detail">Property</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Property</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="getters">
                    <a href="#getter.detail">Get</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Get</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="setters">
                    <a href="#setter.detail">Set</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Set</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text disable-output-escaping="yes">&amp;nbsp;|&amp;nbsp;</xsl:text>
              </li>
              <li>
                <xsl:choose>
                  <xsl:when test="methods">
                    <a href="#method.detail">Method</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Method</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </ul>
          </div>
          <a name="skip.navbar.bottom">
            <!--   -->
          </a>
        </div>
        <!-- ======== END OF BOTTOM NAVBAR ======= -->
      </body>
    </html>
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

  <xsl:template match="hierarchy" mode="open">
    <xsl:for-each select="superclass">
      <xsl:variable name="superType">
        <xsl:choose>
          <xsl:when test="@verb = 'implements'">
            <xsl:text>interface</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>class</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    
      <xsl:if test="position() &gt; 1"><xsl:text disable-output-escaping="yes">&lt;li&gt;</xsl:text></xsl:if>
      <xsl:text disable-output-escaping="yes">&lt;ul class="inheritance"&gt;</xsl:text>
      <li>
        <xsl:choose>
          <xsl:when test="package">
            <a href="{$apiPath}{translate(package, ':', '/')}/{name}.html" title="{$superType} in {package}">
              <xsl:value-of select="concat(package, ':', name)"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name"/>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </xsl:for-each>
        
    <xsl:text disable-output-escaping="yes">&lt;li&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="hierarchy" mode="close">
    <xsl:text disable-output-escaping="yes">&lt;/li&gt;</xsl:text>
        
    <xsl:for-each select="superclass">
      <xsl:text disable-output-escaping="yes">&lt;/ul&gt;</xsl:text>
      <xsl:if test="position() &gt; 1"><xsl:text disable-output-escaping="yes">&lt;/li&gt;</xsl:text></xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="subclasses">
    <dl>
      <dt>Direct Known Subclasses:</dt>
      <dd>
          <xsl:for-each select="subclass">
            <xsl:if test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <a href="{$apiPath}{translate(package, ':', '/')}/{name}.html" title="{@type} in {package}"><xsl:value-of select="name"/></a>
          </xsl:for-each>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template match="hierarchy/superclass[position() = last()]">
    <xsl:variable name="superType">
      <xsl:choose>
        <xsl:when test="@verb = 'implements'">
          <xsl:text>interface</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>class</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:value-of select="concat($n, @verb, ' ')"/>
    <xsl:choose>
      <xsl:when test="package">
        <a href="{$apiPath}{translate(package, ':', '/')}/{name}.html" title="{$superType} in {package}"><xsl:value-of select="name"/></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="paragraph">
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="constructor" mode="summary">
    <!-- ======== CONSTRUCTOR SUMMARY ======== -->
    <ul class="blockList">
      <li class="blockList"><a name="constructor.summary">
        <!--   -->
        </a>
        <h3>Constructor Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Constructor Summary table, listing the constructor, and an explanation">
          <caption><span>Constructor</span><span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span></caption>
          <tr>
            <th class="colFirst" scope="col">Modifier</th>
            <th class="colLast" scope="col">Constructor and Description</th>
          </tr>
          <tr class="altColor">
            <td class="colFirst">
              <code><xsl:value-of select="@scope"/></code>
            </td>
            <td class="colLast">
              <code>
                <span class="memberNameLink">
                  <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#rDetail"><xsl:value-of select="name"/></a>
                </span>
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="arguments/argument"/>
                <xsl:text>)</xsl:text>
              </code>
              <xsl:if test="description/summary">
                <div class="block"><xsl:value-of select="description/summary"/></div>
              </xsl:if>
            </td>
          </tr>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="constants" mode="summary">
    <!-- =========== CONSTANT SUMMARY =========== -->
    <ul class="blockList">
      <li class="blockList"><a name="constant.summary">
        <!--   -->
        </a>
        <h3>Constant Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Constant Summary table, listing constants, and an explanation">
          <caption><span>Constants</span><span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span></caption>
          <tr>
            <th class="colOne" scope="col">Constant and Description</th>
          </tr>
          <xsl:apply-templates select="constant" mode="summary"/>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="constant" mode="summary">
    <xsl:element name="tr">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:text>rowColor</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>altColor</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td class="colOne"><code><span class="memberNameLink">
        <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#c{substring(name, 2)}">
          <xsl:value-of select="name"/>
        </a></span></code>
        <xsl:if test="description/summary">
          <div class="block"><xsl:value-of select="description/summary"/></div>
        </xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <xsl:template match="properties" mode="summary">
    <!-- =========== PROPERTY SUMMARY =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="property.summary">
          <!--   -->
        </a>
        <h3>Property Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Property Summary table, listing properties, and an explanation">
          <caption><span>Properties</span><span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span></caption>
          <tr>
            <th class="colFirst" scope="col">Modifiers and Type</th>
            <th class="colLast" scope="col">Property and Description</th>
          </tr>
          <xsl:apply-templates select="property" mode="summary"/>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="properties/property" mode="summary">
    <xsl:element name="tr">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:text>rowColor</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>altColor</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td class="colFirst">
        <code>
          <xsl:value-of select="@scope"/><xsl:text> </xsl:text>
          <xsl:apply-templates select="type"/>
          <xsl:choose>
            <xsl:when test="boolean(@readonly)">
              <xsl:text> readonly</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="boolean(@get)">
                <xsl:text> </xsl:text>
                <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#g{name}">get</a>
              </xsl:if>
              <xsl:if test="boolean(@set)">
                <xsl:text> </xsl:text>
                <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#s{name}">set</a>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </code>
      </td>
      <td class="colLast">
        <code>
          <span class="memberNameLink">
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="@scope = 'private'">
                    <xsl:value-of select="concat($apiPath, translate(/class/package, ':', '/'), '/', /class/name, '.html#i', substring(name, 2))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($apiPath, translate(/class/package, ':', '/'), '/', /class/name, '.html#p', name)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="name"/>
            </xsl:element>
          </span>
        </code>
        <xsl:if test="description/summary">
          <div class="block"><xsl:value-of select="description/summary"/></div>
        </xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <xsl:template match="getters" mode="summary">
    <!-- =========== GETTER SUMMARY =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="getter.summary">
          <!--   -->
        </a>
        <h3>Getter Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Getter Summary table, listing getters, and an explanation">
          <caption><span>Getters</span><span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span></caption>
          <tr>
            <th class="colFirst" scope="col">Modifier and Type</th>
            <th class="colLast" scope="col">Getter and Description</th>
          </tr>
          <xsl:apply-templates select="property" mode="summary"/>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="getters/property" mode="summary">
    <xsl:element name="tr">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:text>rowColor</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>altColor</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td class="colFirst">
        <code><xsl:value-of select="@scope"/><xsl:text> </xsl:text><xsl:apply-templates select="type"/></code>
      </td>
      <td class="colLast">
        <code>
          <span class="memberNameLink">
            <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#g{name}"><xsl:value-of select="name"/></a>
          </span>
        </code>
        <xsl:if test="description/summary">
          <div class="block"><xsl:value-of select="description/summary"/></div>
        </xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <xsl:template match="setters" mode="summary">
    <!-- =========== SETTER SUMMARY =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="setter.summary">
          <!--   -->
        </a>
        <h3>Setter Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Setter Summary table, listing setters, and an explanation">
          <caption><span>Setters</span><span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span></caption>
          <tr>
            <th class="colFirst" scope="col">Modifier and Type</th>
            <th class="colLast" scope="col">Setter and Description</th>
          </tr>
          <xsl:apply-templates select="property" mode="summary"/>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="setters/property" mode="summary">
    <xsl:element name="tr">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:text>rowColor</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>altColor</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td class="colFirst">
        <code><xsl:value-of select="@scope"/><xsl:text> </xsl:text><xsl:apply-templates select="type"/></code>
      </td>
      <td class="colLast">
        <code>
          <span class="memberNameLink">
            <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#s{name}"><xsl:value-of select="name"/></a>
          </span>
        </code>
        <xsl:if test="description/summary">
          <div class="block"><xsl:value-of select="description/summary"/></div>
        </xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <xsl:template match="methods" mode="summary">
    <!-- ========== METHOD SUMMARY =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="method.summary">
          <!--   -->
        </a>
        <h3>Method Summary</h3>
        <table class="memberSummary" border="0" cellpadding="3" cellspacing="0" summary="Method Summary table, listing methods, and an explanation">
          <caption>
            <span id="t0" class="activeTableTab">
              <span>All Methods</span>
              <span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span>
            </span>
            <span id="t1" class="tableTab">
              <span><a href="javascript:show(1);">Concrete Methods</a></span>
              <span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span>
            </span>
            <span id="t2" class="tableTab">
              <span><a href="javascript:show(2);">Abstract Methods</a></span>
              <span class="tabEnd"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></span>
            </span>
          </caption>
          <tr>
            <th class="colFirst" scope="col">Modifiers and Type</th>
            <th class="colLast" scope="col">Method and Description</th>
          </tr>
          <xsl:apply-templates select="method" mode="summary"/>
        </table>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="method" mode="summary">
    <xsl:element name="tr">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('i', position() - 1)"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:text>rowColor</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>altColor</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <td class="colFirst">
        <code>
          <xsl:value-of select="@scope"/>
          <xsl:if test="boolean(@abstract)">
            <xsl:text> abstract</xsl:text>
          </xsl:if>
          <xsl:if test="type">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="type"/>
          </xsl:if>
        </code>
      </td>
      <td class="colLast">
        <code>
          <span class="memberNameLink">
            <a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#m{name}">
              <xsl:value-of select="name"/>
            </a>
          </span>
          <xsl:text>(</xsl:text>
          <xsl:apply-templates select="arguments/argument"/>
          <xsl:text>)</xsl:text>
        </code>
        <xsl:if test="description/summary">
          <div class="block"><xsl:value-of select="description/summary"/></div>
        </xsl:if>
      </td>
    </xsl:element>
  </xsl:template>

  <xsl:template match="method" mode="tabs">
    <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>"i</xsl:text>
    <xsl:value-of select="position() - 1"/>
    <xsl:text>":</xsl:text>
    <xsl:choose>
      <xsl:when test="/class/@type = 'interface' or boolean(@abstract)">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="constructor" mode="detail">
    <!-- ========= CONSTRUCTOR DETAIL ======== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="constructor.detail">
          <!--   -->
        </a>
        <h3>Constructor Detail</h3>
        <a name="rDetail">
          <!--   -->
        </a>
        <ul class="blockListLast">
          <li class="blockList">
            <h4><xsl:value-of select="name"/></h4>
            <pre><xsl:value-of disable-output-escaping="yes" select="concat(@scope, '&amp;nbsp;', name, '(')"/><xsl:apply-templates select="arguments/argument">
              <xsl:with-param name="indent">
                <xsl:call-template name="dup">
                  <xsl:with-param name="input" select="' '"/>
                  <xsl:with-param name="count" select="string-length(@scope) + string-length(name) + 2"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="sep" select="concat(',', $n)"/>
            </xsl:apply-templates><xsl:text>)</xsl:text></pre>
            <xsl:apply-templates select="description"/>
          </li>
        </ul>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="constants" mode="detail">
    <!-- ============ CONSTANT DETAIL =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="constant.detail">
          <!--   -->
        </a>
        <h3>Constant Detail</h3>
        <xsl:apply-templates select="constant" mode="detail"/>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="constant" mode="detail">
    <a name="c{substring(name, 2)}">
      <!--   -->
    </a>
    <xsl:element name="ul">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>blockListLast</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>blockList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <li class="blockList">
        <h4><xsl:value-of select="name"/></h4>
        <pre>Constant <xsl:value-of select="name"/> = <xsl:value-of select="value"/></pre>
        <xsl:apply-templates select="description"/>
      </li>
    </xsl:element>
  </xsl:template>

  <xsl:template match="properties" mode="detail">
    <!-- ============ PROPERTY DETAIL =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="property.detail">
          <!--   -->
        </a>
        <h3>Property Detail</h3>
        <xsl:apply-templates select="property" mode="detail"/>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="properties/property" mode="detail">
    <xsl:element name="a">
      <xsl:attribute name="name">
        <xsl:choose>
          <xsl:when test="@scope = 'private'">
            <xsl:value-of select="concat('i', substring(name, 2))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('p', name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!--   -->
    </xsl:element>
    <xsl:element name="ul">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>blockListLast</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>blockList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <li class="blockList">
        <h4><xsl:value-of select="name"/></h4>
        <pre><xsl:value-of select="concat(@scope, ' ')"/><xsl:apply-templates select="type"/><xsl:value-of select="concat(' ', name)"/><xsl:choose>
            <xsl:when test="boolean(@readonly)">
              <xsl:text> readonly</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="boolean(@get)">
                <xsl:text> </xsl:text><a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#g{name}">get</a>
              </xsl:if>
              <xsl:if test="boolean(@set)">
                <xsl:text> </xsl:text><a href="{$apiPath}{translate(/class/package, ':', '/')}/{/class/name}.html#s{name}">set</a>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose></pre>
        <xsl:apply-templates select="description"/>
      </li>
    </xsl:element>
  </xsl:template>

  <xsl:template match="getters" mode="detail">
    <!-- ============ GETTER DETAIL =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="getter.detail">
          <!--   -->
        </a>
        <h3>Getter Detail</h3>
        <xsl:apply-templates select="property" mode="detail"/>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="getters/property" mode="detail">
    <a name="g{name}">
      <!--   -->
    </a>
    <xsl:element name="ul">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>blockListLast</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>blockList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <li class="blockList">
        <h4><xsl:value-of select="name"/></h4>
        <pre><xsl:value-of select="concat(@scope, ' ')"/><xsl:apply-templates select="type"/><xsl:value-of select="concat(' ', name)"/></pre>
        <xsl:apply-templates select="description"/>
      </li>
    </xsl:element>
  </xsl:template>

  <xsl:template match="setters" mode="detail">
    <!-- ============ SETTER DETAIL =========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="setter.detail">
          <!--   -->
        </a>
        <h3>Setter Detail</h3>
        <xsl:apply-templates select="property" mode="detail"/>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="setters/property" mode="detail">
    <a name="s{name}">
      <!--   -->
    </a>
    <xsl:element name="ul">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>blockListLast</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>blockList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <li class="blockList">
        <h4><xsl:value-of select="name"/></h4>
        <pre><xsl:value-of select="concat(@scope, ' ')"/><xsl:apply-templates select="type"/><xsl:value-of select="concat(' ', name)"/></pre>
        <xsl:apply-templates select="description"/>
      </li>
    </xsl:element>
  </xsl:template>

  <xsl:template match="methods" mode="detail">
    <!-- ============ METHOD DETAIL ========== -->
    <ul class="blockList">
      <li class="blockList">
        <a name="method.detail">
          <!--   -->
        </a>
        <h3>Method Detail</h3>
        <xsl:apply-templates select="method" mode="detail"/>
      </li>
    </ul>
  </xsl:template>

  <xsl:template match="method" mode="detail">
    <a name="m{name}">
      <!--   -->
    </a>
    <xsl:element name="ul">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>blockListLast</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>blockList</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <li class="blockList">
        <h4><xsl:value-of select="name"/></h4>
        <pre><xsl:value-of select="@scope"/><xsl:if test="boolean(@abstract)">
            <xsl:text disable-output-escaping="yes">&amp;nbsp;abstract</xsl:text>
          </xsl:if><xsl:value-of disable-output-escaping="yes" select="concat('&amp;nbsp;', name, '(')"/><xsl:apply-templates select="arguments/argument"><xsl:with-param name="indent">
            <xsl:call-template name="dup">
              <xsl:with-param name="input" select="' '"/>
              <xsl:with-param name="count">
                <xsl:choose>
                  <xsl:when test="boolean(@abstract)">
                    <xsl:value-of select="string-length(@scope) + string-length(name) + 11"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="string-length(@scope) + string-length(name) + 2"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="sep" select="concat(',', $n)"/>
        </xsl:apply-templates><xsl:text>)</xsl:text><xsl:if test="type">
          <xsl:text> Returns </xsl:text><xsl:apply-templates select="type"/>
        </xsl:if></pre>
        <xsl:apply-templates select="description"/>
      </li>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/class/description | /class/constructor/description | /class/constants/constant/description | /class/properties/property/description | /class/getters/property/description | /class/setters/property/description | /class/methods/method/description">
    <xsl:if test="summary">
      <div class="block">
        <xsl:apply-templates select="full/paragraph"/>
      </div>
    </xsl:if>
    <xsl:if test="version or authors or params or exceptions or return">
      <dl>
        <xsl:if test="version">
          <dt><span class="simpleTagLabel">Version:</span></dt>
          <dd><xsl:value-of select="version"/></dd>
        </xsl:if>
        <xsl:if test="authors">
          <dt><span class="seeLabel">Authors:</span></dt>
          <dd>
            <xsl:for-each select="authors/author">
              <xsl:if test="position() &gt; 1">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="."/>
            </xsl:for-each>
          </dd>
        </xsl:if>
        <xsl:if test="params">
          <dt><span class="paramLabel">Parameters:</span></dt>
          <xsl:for-each select="params/param">
            <dd><xsl:value-of select="."/></dd>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="exceptions">
          <dt><span class="throwsLabel">Throws:</span></dt>
          <xsl:for-each select="exceptions/exception">
            <dd><xsl:value-of select="."/></dd>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="return">
          <dt><span class="returnLabel">Returns:</span></dt>
          <dd><xsl:value-of select="return"/></dd>
        </xsl:if>
      </dl>
    </xsl:if>
  </xsl:template>

  <xsl:template match="argument">
    <xsl:param name="indent" select="''"/>
    <xsl:param name="sep" select="', '"/>

    <xsl:if test="position() &gt; 1"><xsl:value-of select="concat($sep, $indent)"/></xsl:if>
    <xsl:value-of select="name"/>
    <xsl:text disable-output-escaping="yes">&amp;nbsp;as&amp;nbsp;</xsl:text>
    <xsl:apply-templates select="type"/>
    <xsl:if test="boolean(@out)"><xsl:text disable-output-escaping="yes">&amp;nbsp;out</xsl:text></xsl:if>
  </xsl:template>
  
  <xsl:template match="type">
    <xsl:call-template name="dup">
      <xsl:with-param name="input" select="'array of '"/>
      <xsl:with-param name="count" select="number(@array_dimension)"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="package">
        <a href="{$apiPath}{translate(package, ':', '/')}/{name}.html" title="class in {package}"><xsl:value-of select="name"/></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
