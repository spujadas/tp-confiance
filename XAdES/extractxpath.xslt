<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
  xmlns:xades="http://uri.etsi.org/01903/v1.3.2#"
  xmlns:xadesv141="http://uri.etsi.org/01903/v1.4.1#"
  xmlns:dyn="http://exslt.org/dynamic"
  extension-element-prefixes="dyn">
  
  <xsl:output indent="no" omit-xml-declaration="yes"/>

  <xsl:param name="xpath"/>

  <xsl:template match="/">
    <xsl:call-template name="extractXPath"/>
  </xsl:template>
  
  <xsl:template name="extractXPath">
    <xsl:copy-of select="dyn:evaluate($xpath)"/>
  </xsl:template>
</xsl:stylesheet>
