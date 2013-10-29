<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
  
  <xsl:template match="node() | @*">
    <xsl:if test="count(ancestor-or-self::ds:Signature 
      | /root/ds:Signature/ds:SignedInfo/ds:Reference/ds:Transforms
      /ds:Transform/ancestor::ds:Signature[1]) 
      > count(ancestor-or-self::ds:Signature)">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
