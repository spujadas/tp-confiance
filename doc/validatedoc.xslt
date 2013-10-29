<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
	<xsl:output method="text" encoding="UTF-8" indent="no"/>
	<xsl:template match="/">
		<xsl:apply-templates select="svrl:schematron-output"/>
	</xsl:template>
	
	<xsl:template match="svrl:schematron-output">
		<xsl:apply-templates select="svrl:failed-assert | svrl:failed-report"/>
	</xsl:template>
	
	<xsl:template match="svrl:failed-assert | svrl:failed-report">
		<xsl:value-of select="svrl:text"/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
