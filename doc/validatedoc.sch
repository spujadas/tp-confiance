<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <ns uri="http://www.w3.org/1999/xhtml" prefix="h"/>

  <xsl:key name="a_name" match="h:a[@name]" use="@name"/>
  <xsl:key name="header_id" match="h:h1|h:h2|h:h3" use="@id"/>
  
  <pattern name="Check that all headers have an id">
    <rule context="h:h1 | h:h2 | h:h3">
     <assert test="@id">id element is missing for header entitled '<value-of select="."/>'</assert>
    </rule>
  </pattern>
  <pattern name="Check all references for valid attributes">
	<rule context="h:a[@href and @class]">
      <assert test="starts-with(@href, '#')">internally-classed anchor (with class <value-of select="@class"/>) points to external reference <value-of select="@href"/></assert>
      <assert test="@class='chapter' or @class='page' or @class='section' or @class='appendix' or @class='appendix_section'">wrong class ('<value-of select="@class"/>') for internal reference to id/name <value-of select="@href"/></assert>
	</rule>
    <rule context="h:a[@href and not(@class)]">
      <assert test="starts-with(@href, '#')">missing class for internal reference to id/name <value-of select="@href"/></assert>
    </rule>
    <rule context="h:a">
      <assert test="@href or @name">incomplete anchor tag (missing href or name attribute)</assert>
    </rule>
  </pattern>
  <pattern name="Check all internal references for consistency">
    <rule context="h:a[@href and @class]">
      <assert test="key('a_name', substring(@href, 2)) or key('header_id', substring(@href, 2))">internal reference to <value-of select="@href"/> does not point to an existing id/name</assert>
    </rule>
  </pattern>
</schema>