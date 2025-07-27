<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    version     = "1.0"
    xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
    xmlns:ltx   = "http://dlmf.nist.gov/LaTeXML"
    xmlns:f     = "http://dlmf.nist.gov/LaTeXML/functions"
    extension-element-prefixes="f"
    exclude-result-prefixes = "ltx f">

    <!-- Fallback to defaults -->
    <xsl:import href="urn:x-LaTeXML:XSLT:LaTeXML-html5.xsl"/>

    <!-- Custom transformations here -->

    <!-- Leave all IDs unchanged from the XML except equations, where we take the equation number instead of its label as the ID -->
    <!-- Overrides template in LaTeXML-common-xhtml.xsl -->
    <xsl:template name="add_id">
        <xsl:choose>
            <xsl:when test="local-name()='equation' or local-name()='theorem'">
                <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
            </xsl:when>
            <xsl:when test="local-name()='subsection'">
                <xsl:attribute name="id"><xsl:value-of select="substring-after(@fragid,'subsec:')"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="@fragid">
                    <xsl:attribute name="id"><xsl:value-of select="@fragid"/></xsl:attribute>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove colour styling from all elements -->
    <!-- Overrides template in LaTeXML-common-xhtml.xsl -->
    <!-- TODO: this will probably be removed at some point to bring back colours -->
    <xsl:template match="*" mode="base-styling">
        <xsl:if test="@fontsize">
            <xsl:value-of select="concat('font-size:',@fontsize,';')"/>
        </xsl:if>
        <xsl:if test="@width"  ><xsl:value-of select="concat('width:',@width,';')"/></xsl:if>
        <xsl:if test="@height" >
            <xsl:choose>
                <xsl:when test="@depth">
                    <xsl:value-of select="concat('height:',f:adddim(@height,@depth),';')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('height:',@height,';')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@depth">
            <xsl:value-of select="concat('vertical-align:',f:negate(@depth),';')"/>
        </xsl:if>
        <xsl:if test="@xoffset">
            <xsl:value-of select="concat('position:relative; left:',@xoffset,';')"/>
        </xsl:if>
        <xsl:if test="@yoffset">
            <xsl:value-of select="concat('position:relative; bottom:',@yoffset,';')"/>
        </xsl:if>
        <!-- <xsl:if test="@color"><xsl:value-of select="concat('color:',@color,';')"/></xsl:if> -->
        <xsl:if test="@backgroundcolor">
            <xsl:value-of select="concat('background-color:',@backgroundcolor,';')"/>
        </xsl:if>
        <xsl:if test="@opacity"><xsl:value-of select="concat('opacity:',@opacity,';')"/></xsl:if>
        <xsl:if test="@framecolor">
            <xsl:value-of select="'border-color: '"/>
            <xsl:value-of select="@framecolor"/>
            <xsl:value-of select="';'"/>
        </xsl:if>
        <xsl:if test="@cssstyle"><xsl:value-of select="concat(@cssstyle,';')"/></xsl:if>
    </xsl:template>

    <!-- Strip label category prefix from hrefs -->
    <!-- (prefix for equations, theorems, and subsections in IDs is stripped above, prefix for chapters and sections is stripped from filenames by perl script after building) -->
    <!-- Overrides template in LaTeXML-inline-xhtml.xsl -->
    <xsl:template match="ltx:ref">
        <xsl:param name="context"/>
        <xsl:choose>
            <xsl:when test="contains(@href,'eq:') or contains(@href,'chap_') or contains(@href,'sec_') or contains(@href,'subsec:') or contains(@href,'thm:') or contains(@href,'ex:') or contains(@href,'def:')">
                <xsl:element name="a" namespace="{$html_ns}">
                    <xsl:variable name="innercontext" select="'inline'"/>
                    <!-- this is the edited part -->
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="contains(@href,'eq:')"><xsl:value-of select="f:url(f:subst(f:subst(concat(substring-before(@href,'eq:'),@idref),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'thm:')"><xsl:value-of select="f:url(f:subst(f:subst(concat(substring-before(@href,'thm:'),@idref),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'ex:')"><xsl:value-of select="f:url(f:subst(f:subst(concat(substring-before(@href,'ex:'),@idref),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'def:')"><xsl:value-of select="f:url(f:subst(f:subst(concat(substring-before(@href,'def:'),@idref),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'subsec:') and contains(@href,'sec:')"><xsl:value-of select="f:url(f:subst(f:subst(concat(substring-before(@href,'sec:'),substring-after(@href,'subsec:')),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'subsec:')"><xsl:value-of select="f:url(f:subst(f:subst(f:subst(@href,'subsec:',''),'chap_',''),'sec_',''))"/></xsl:when>
                            <xsl:when test="contains(@href,'chap_') or contains(@href,'sec_')"><xsl:value-of select="f:url(f:subst(f:subst(@href,'chap_',''),'sec_',''))"/></xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="@title"/></xsl:attribute>
                    <xsl:call-template name="add_id"/>
                    <xsl:call-template name="add_attributes"/>
                    <xsl:apply-templates select="." mode="begin">
                        <xsl:with-param name="context" select="$innercontext"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates>
                        <xsl:with-param name="context" select="$innercontext"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="." mode="end">
                        <xsl:with-param name="context" select="$innercontext"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-imports/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Add a wrapper to all equation <table>s to stop them expanding when they are too wide -->
    <!-- Overrides templates in LaTeXML-block-xhtml.xsl -->
    <xsl:template match="ltx:equationgroup">
        <xsl:param name="context"/>
        <xsl:element name="{f:blockelement($context,'div')}" namespace="{$html_ns}">
            <xsl:attribute name="class">ltx_equation_wrapper</xsl:attribute>
            <xsl:apply-imports/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ltx:equation">
        <xsl:param name="context"/>
        <xsl:element name="{f:blockelement($context,'div')}" namespace="{$html_ns}">
            <xsl:attribute name="class">ltx_equation_wrapper</xsl:attribute>
            <xsl:apply-imports/>
        </xsl:element>
    </xsl:template>

    <!-- Remove authors -->
    <!-- Overrides template in LaTeXML-structure-xhtml.xsl -->
    <xsl:template name="authors"/>

    <!-- The following templates all override templates in LaTeXML-webpage-xhtml.xsl -->

    <!-- Add CSS and JavaScript files to head (they will be located in the same virtual location for all files on the server) -->
    <xsl:template match="/" mode="head-resources">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="link" namespace="{$html_ns}">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="href">styles/main.css</xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
        </xsl:element>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="link" namespace="{$html_ns}">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="href">styles/lecture-notes.css</xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
        </xsl:element>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="script" namespace="{$html_ns}">
            <xsl:attribute name="defer">defer</xsl:attribute>
            <xsl:attribute name="src">scripts/lecture-notes.js</xsl:attribute>
        </xsl:element>
        <xsl:apply-imports/>
    </xsl:template>

    <!-- Strip label category prefix from <link>s in <head> -->
    <xsl:template match="ltx:navigation/ltx:ref[@rel] | ltx:navigation/ltx:ref[@rev]" mode="inhead">
        <xsl:choose>
            <xsl:when test="contains(@href, 'chap_') or contains(@href, 'sec_')">
                <xsl:text>&#x0A;</xsl:text>
                <xsl:element name="link" namespace="{$html_ns}">
                    <xsl:choose>
                        <xsl:when test="@rel">
                            <xsl:attribute name="rel"><xsl:value-of select="@rel"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rev"><xsl:value-of select="@rev"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="contains(@href,'chap_')"><xsl:value-of select="f:url(concat(substring-before(@href,'chap_'),substring-after(@href,'chap_')))"/></xsl:when>
                            <xsl:when test="contains(@href,'sec_')"><xsl:value-of select="f:url(concat(substring-before(@href,'sec_'),substring-after(@href,'sec_')))"/></xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="normalize-space(f:if(@fulltitle,@fulltitle, @title))"/></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-imports/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Remove <header> navigation for now, will put something here at some point -->
    <xsl:template match="/" mode="header-navigation">
    </xsl:template>

    <!-- Changed navigation elements that appear in the footer -->
    <xsl:template match="/" mode="footer-navigation">
        <xsl:if test="//ltx:navigation/ltx:ref">
            <xsl:text>&#x0A;</xsl:text>
            <xsl:element name="div" namespace="{$html_ns}">
                <xsl:attribute name="class">ltx_align_center</xsl:attribute>
                <xsl:apply-templates select="//ltx:navigation/ltx:ref[@rel='prev']"/>
                <xsl:apply-templates select="//ltx:navigation/ltx:ref[@rel='next']"/>
                <xsl:text>&#x0A;</xsl:text>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Remove title from TOCs -->
    <xsl:template match="ltx:TOC">
        <xsl:param name="context"/>
        <xsl:if test="ltx:toclist/descendant::ltx:tocentry">
            <xsl:text>&#x0A;</xsl:text>
            <xsl:element name="{f:if($USE_HTML5,'nav','div')}" namespace="{$html_ns}">
                <xsl:call-template name="add_attributes">
                    <xsl:with-param name="extra_classes" select="f:class-pref('ltx_toc_',@lists)"/>
                </xsl:call-template>
                <xsl:apply-templates>
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Remove subsections from TOC -->
    <xsl:template match="ltx:tocentry">
        <xsl:if test="contains(@class,'ltx_tocentry_chapter') or contains(@class,'ltx_tocentry_section') or contains(../@class,'ltx_toclist_chapter')">
            <xsl:apply-imports/>
        </xsl:if>
    </xsl:template>

    <!-- Add header to navbar -->
    <xsl:template match="/" mode="navbar">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="{f:if($USE_HTML5,'nav','div')}" namespace="{$html_ns}">
            <xsl:attribute name="class">ltx_page_navbar</xsl:attribute>
            <xsl:apply-templates select="//ltx:navigation/ltx:ref[@rel='start']"/>
            <xsl:element name="h2" namespace="{$html_ns}">
                <xsl:element name="a" namespace="{$html_ns}"><xsl:attribute name="href">https://lachlan.dk/lecture-notes/</xsl:attribute>Lecture Notes</xsl:element>
            </xsl:element>
            <xsl:element name="h3" namespace="{$html_ns}">by <xsl:element name="a" namespace="{$html_ns}"><xsl:attribute name="class">external-link</xsl:attribute><xsl:attribute name="href">https://lachlan.dk</xsl:attribute>Lachlan Dufort-Kennett</xsl:element></xsl:element>
            <xsl:apply-templates select="//ltx:navigation/ltx:TOC"/>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:element>
    </xsl:template>

    <!-- Add an "in this page" navbar for each section in addition to the navbar for the whole document -->
    <!-- Lists subsections, theorems, definitions, examples -->
    <xsl:template match="/" mode="body">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="body" namespace="{$html_ns}">
            <xsl:element name="div" namespace="{$html_ns}">
                <xsl:attribute name="id">body-wrapper</xsl:attribute>
                <xsl:apply-templates select="." mode="body-begin"/>
                <xsl:apply-templates select="." mode="navbar"/>
                <xsl:apply-templates select="." mode="body-main-wrapper"/>
                <xsl:apply-templates select="." mode="body-end"/>
            </xsl:element>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:element>
    </xsl:template>

    <!-- Wrap the body-main (contains main content) with the in-page navbar for layout purposes -->
    <xsl:template match="/" mode="body-main-wrapper">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="main" namespace="{$html_ns}">
            <xsl:apply-templates select="." mode="body-main"/>
            <xsl:apply-templates select="." mode="in-page-navbar"/>
        </xsl:element>
    </xsl:template>

    <!-- Create the <nav> element -->
    <!-- These templates are mostly copied from the navbar in LaTeXML-webpage-xhtml.xsl -->
    <xsl:template match="/" mode="in-page-navbar">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="nav" namespace="{$html_ns}">
            <xsl:attribute name="class">ltx_in_page_navbar</xsl:attribute>
            <xsl:apply-templates select="//ltx:navigation/ltx:TOC" mode="in-page-navbar"/>
            <xsl:text>&#x0A;</xsl:text>
            <xsl:element name="footer" namespace="{$html_ns}">Website designed by me. Copyright <xsl:text disable-output-escaping="yes">&amp;copy;</xsl:text> <xsl:element name="span" namespace="{$html_ns}"><xsl:attribute name="id">copyright-date</xsl:attribute></xsl:element> Lachlan Dufort-Kennett</xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Create TOC if section contains subsections or theorem environments -->
    <xsl:template match="ltx:TOC" mode="in-page-navbar">
        <xsl:param name="context"/>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:if test="//ltx:subsection|//ltx:theorem">
            <xsl:element name="span" namespace="{$html_ns}">
                <xsl:attribute name="class">ltx_text ltx_ref_title</xsl:attribute>
                <xsl:element name="h2" namespace="{$html_ns}">On this page</xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:element name="nav" namespace="{$html_ns}">
            <xsl:call-template name='add_attributes'>
                <xsl:with-param name="extra_classes" select="f:class-pref('ltx_toc_',@lists)"/>
            </xsl:call-template>
            <xsl:apply-templates mode="in-page-navbar">
                <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <!-- Create an <ol> and apply templates to descendants which are subsections -->
    <xsl:template match="ltx:toclist" mode="in-page-navbar">
        <xsl:param name="context"/>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:element name="ol" namespace="{$html_ns}">
            <xsl:call-template name="add_id"/>
            <xsl:call-template name="add_attributes"/>
            <!-- create <li>s for theorem environments that are not part of a subsection -->
            <xsl:if test="//ltx:section/ltx:theorem">
                <xsl:element name="ol" namespace="{$html_ns}">
                    <xsl:attribute name="class">ltx_toclist ltx_toclist_section</xsl:attribute>
                    <xsl:for-each select="//ltx:section/ltx:theorem">
                        <xsl:call-template name="theorem-nav-element">
                            <xsl:with-param name="title" select="./ltx:tocentry[contains(@class,'ltx_ref_self')]/ltx:ref/@title"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            <!-- create <li>s for subsections -->
            <xsl:apply-templates select="./descendant::ltx:tocentry[contains(@class, 'ltx_tocentry_subsection')]" mode="in-page-navbar">
                <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:element>
    </xsl:template>

    <!-- Create the <li> for the subsection, then create a sublist for any theorem environments inside it -->
    <xsl:template match="ltx:tocentry" mode="in-page-navbar">
        <xsl:param name="context"/>
            <xsl:text>&#x0A;</xsl:text>
            <xsl:element name="li" namespace="{$html_ns}">
                <xsl:call-template name="add_id"/>
                <xsl:call-template name="add_attributes"/>
                <xsl:apply-templates>
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:element>
            <!-- check for children that are theorems and create <li>s for them -->
            <xsl:variable name="subsection-id" select="substring-after(./ltx:ref/@href,'#')"/>
            <xsl:if test="//ltx:subsection[@fragid=$subsection-id]/ltx:theorem">
                <xsl:element name="ol" namespace="{$html_ns}">
                    <xsl:attribute name="class">ltx_toclist ltx_toclist_subsection</xsl:attribute>
                    <xsl:for-each select="//ltx:subsection[@fragid=$subsection-id]/ltx:theorem">
                        <xsl:call-template name="theorem-nav-element">
                            <xsl:with-param name="title" select="./ltx:ref/@title"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
    </xsl:template>

    <!-- Generate an <li> for a theorem environment -->
    <xsl:template name="theorem-nav-element">
        <xsl:param name="title"/>
        <xsl:element name="li" namespace="{$html_ns}">
            <xsl:attribute name="class">ltx_tocentry ltx_tocentry_subsubsection</xsl:attribute>
            <xsl:element name="a" namespace="{$html_ns}">
                <xsl:attribute name="class">ltx_ref</xsl:attribute>
                <xsl:attribute name="href"><xsl:value-of select="concat('#',@xml:id)"/></xsl:attribute>
                <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
                <xsl:element name="span" namespace="{$html_ns}">
                    <xsl:attribute name="class">ltx_text ltx_ref_title</xsl:attribute>
                    <xsl:value-of select="./ltx:tags/ltx:tag[@role='typerefnum']"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>