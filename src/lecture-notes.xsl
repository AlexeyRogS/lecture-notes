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
            <xsl:when test="local-name()='equation'">
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

    <!-- Strip label category prefix from hrefs -->
    <!-- (prefix for equations and subsections in IDs is stripped above, prefix for chapters and sections is stripped from filenames by perl script after building) -->
    <!-- Overrides template in LaTeXML-inline-xhtml.xsl -->
    <xsl:template match="ltx:ref">
        <xsl:param name="context"/>
        <xsl:choose>
            <xsl:when test="contains(@href,'eq:') or contains(@href,'chap_') or contains(@href,'sec_') or contains(@href,'subsec:')">
                <xsl:element name="a" namespace="{$html_ns}">
                    <xsl:variable name="innercontext" select="'inline'"/>
                    <!-- this is the edited part -->
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="contains(@href,'eq:')"><xsl:value-of select="f:url(concat(substring-before(@href,'eq:'),@idref))"/></xsl:when>
                            <xsl:when test="contains(@href,'chap_') and contains(@href,'sec_')"><xsl:value-of select="f:url(concat(substring-before(@href,'chap_'),substring-before(substring-after(@href,'chap_'),'sec_'),substring-after(@href,'sec_')))"/></xsl:when>
                            <xsl:when test="contains(@href,'chap_')"><xsl:value-of select="f:url(concat(substring-before(@href,'chap_'),substring-after(@href,'chap_')))"/></xsl:when>
                            <xsl:when test="contains(@href,'sec_')"><xsl:value-of select="f:url(concat(substring-before(@href,'sec_'),substring-after(@href,'sec_')))"/></xsl:when>
                            <xsl:when test="contains(@href,'subsec:')"><xsl:value-of select="f:url(concat('#',substring-after(@href,'subsec:')))"/></xsl:when>
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

    <!-- The following templates all override templates in LaTeXML-webpage-xhtml.xsl -->

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

</xsl:stylesheet>