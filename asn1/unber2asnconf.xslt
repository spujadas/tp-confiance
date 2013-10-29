<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="UTF-8" indent="no"/>

  <xsl:param name="prefix"/>

  <!-- Top-level template: creates the initial "asn1 = …" line, and
    then processes the C element if it exists -->
  <xsl:template match="/">
    <xsl:text>asn1 = </xsl:text>
    <xsl:apply-templates select="." mode="field_value"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:if test="C">
        <xsl:text>&#x0a;</xsl:text>
        <xsl:apply-templates select="C" mode="section"/>
    </xsl:if>
  </xsl:template>

  <!-- 
    Templates for ASN.1 primitives
    ==============================
  -->
  
  <!-- Renders "field_name = field_value" from a P node. -->
  <xsl:template match="P">
    <xsl:apply-templates select="." mode="field_name"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="." mode="field_value"/>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <!-- Generates a field name from a P node, using @T to determine
    the type of field and @O to give it a unique number.
    If the global $prefix parameter is defined, then it is prepended
    with an '_' to the field name. -->
  <xsl:template match="P" mode="field_name">
    <xsl:if test="$prefix">
      <xsl:value-of select="$prefix"/>
      <xsl:text>_</xsl:text>
    </xsl:if>
  
    <xsl:choose>
      <!-- INTEGER -->
      <xsl:when test="@T='[UNIVERSAL 2]'">
        <xsl:text>int</xsl:text>
      </xsl:when>

      <!-- ENUMERATED -->
      <xsl:when test="@T='[UNIVERSAL 10]'">
        <xsl:text>enum</xsl:text>
      </xsl:when>

      <!-- OBJECT IDENTIFIER -->
      <xsl:when test="@T='[UNIVERSAL 6]'">
        <xsl:text>oid</xsl:text>
      </xsl:when>

      <!-- NULL -->
      <xsl:when test="@T='[UNIVERSAL 5]'">
        <xsl:text>null</xsl:text>
      </xsl:when>

      <!-- BIT STRING -->
      <xsl:when test="@T='[UNIVERSAL 3]'">
        <xsl:text>bitstring</xsl:text>
      </xsl:when>
      
      <!-- OCTET STRING -->
      <xsl:when test="@T='[UNIVERSAL 4]'">
        <xsl:text>octstring</xsl:text>
      </xsl:when>
      
      <!-- PRINTABLE STRING -->
      <xsl:when test="@T='[UNIVERSAL 19]'">
        <xsl:text>printablestring</xsl:text>
      </xsl:when>
      
      <!-- UTF8 STRING -->
      <xsl:when test="@T='[UNIVERSAL 12]'">
        <xsl:text>utf8string</xsl:text>
      </xsl:when>

      <!-- UTCTIME -->
      <xsl:when test="@T='[UNIVERSAL 23]'">
        <xsl:text>utctime</xsl:text>
      </xsl:when>

      <!-- GENERALIZEDTIME -->
      <xsl:when test="@T='[UNIVERSAL 24]'">
        <xsl:text>gentime</xsl:text>
      </xsl:when>

      <!-- BOOLEAN -->
      <xsl:when test="@T='[UNIVERSAL 1]'">
        <xsl:text>bool</xsl:text>
      </xsl:when>

      <!-- IMPLICIT -->
      <xsl:when test
        ="string(number(substring-before(substring-after(@T, '['),']'))) != 'NaN'">
        <xsl:text>implicit</xsl:text>
      </xsl:when>
    
      <xsl:otherwise>
        <xsl:text>unknown</xsl:text>
      </xsl:otherwise>

    </xsl:choose>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="@O"/>
  </xsl:template>

  <!-- Generates a field value from a P node, using @T to determine
    the type of field. -->
  <xsl:template match="P" mode="field_value">
    <xsl:choose>
      <!-- INTEGER and ENUMERATED-->
      <xsl:when test="@T='[UNIVERSAL 2]' or @T='[UNIVERSAL 10]'">
        <xsl:choose>
          <xsl:when test="@T='[UNIVERSAL 2]'">
            <xsl:text>INTEGER:</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>ENUMERATED:</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="starts-with(., '\x')">
            <!-- if the string begins with "\x" then it is a
              hexstring and needs to be unescaped and prefixed -->
              <xsl:text>0x</xsl:text>
              <xsl:call-template name="xstring_to_hexstring">
                <xsl:with-param name="string" select="."/>
              </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- OBJECT IDENTIFIER -->
      <xsl:when test="@T='[UNIVERSAL 6]'">
        <xsl:text>OID:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>

      <!-- NULL -->
      <xsl:when test="@T='[UNIVERSAL 5]'">
        <xsl:text>NULL</xsl:text>
      </xsl:when>

      <!-- BIT STRING -->
      <xsl:when test="@T='[UNIVERSAL 3]'">
        <!-- Two cases are considered depending on the first byte (unused
          bits) -->
        <xsl:choose>
          <xsl:when test="starts-with(.,'\x00')">
            <!-- 1) the number of unused bits is 0: discard first byte
              and render as hex-string -->
            <xsl:text>FORMAT:HEX,BITSTRING:</xsl:text>
            <xsl:call-template name="fold_long_line">
              <xsl:with-param name="line">
                <xsl:call-template name="xstring_to_hexstring">
                  <xsl:with-param name="string" select="substring-after(.,'\x00')"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- 2) the number of unused bits is not zero: render as
              bitlist -->
            <xsl:text>FORMAT:BITLIST,BITSTRING:</xsl:text>
            <xsl:call-template name="bitstring_to_bitlist">
              <!-- the number of unused bits is in the range 1-7
                (i.e. \x01-\x04), so extract fourth character for
                unused_bits parameter -->
              <xsl:with-param name="unused_bits" select="substring(.,4,1)"/>
              <xsl:with-param name="bits">
                <xsl:call-template name="xstring_to_binary">
                  <!-- convert all but first byte to binary -->
                  <xsl:with-param name="string" select="substring(.,5)"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <!-- OCTET STRING -->
      <xsl:when test="@T='[UNIVERSAL 4]'">
        <xsl:text>FORMAT:HEX,OCTETSTRING:</xsl:text>
        <xsl:call-template name="fold_long_line">
          <xsl:with-param name="line">
            <xsl:call-template name="xstring_to_hexstring">
              <xsl:with-param name="string" select="."/>
			</xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      
      <!-- PRINTABLE STRING -->
      <xsl:when test="@T='[UNIVERSAL 19]'">
        <xsl:text>PRINTABLESTRING:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>
      
      <!-- UTF8 STRING -->
      <xsl:when test="@T='[UNIVERSAL 12]'">
        <xsl:text>FORMAT:UTF8,UTF8String:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>

      <!-- IA5STRING -->
      <xsl:when test="@T='[UNIVERSAL 19]'">
        <xsl:text>IA5STRING:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>
      
      <!-- UTCTIME -->
      <xsl:when test="@T='[UNIVERSAL 23]'">
        <xsl:text>UTCTIME:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>

      <!-- GENERALIZEDTIME -->
      <xsl:when test="@T='[UNIVERSAL 24]'">
        <xsl:text>GENERALIZEDTIME:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>

      <!-- BOOLEAN -->
      <xsl:when test="@T='[UNIVERSAL 1]'">
        <xsl:text>BOOLEAN:</xsl:text>
        <xsl:choose>
          <xsl:when test=". = true">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>false</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <!-- IMPLICIT -->
      <!-- The test below checks whether the string between the
        brackets — which defines the tag type — is a number, by
        checking that it is not NaN (NaN: not a number) -->
      <xsl:when test="string(number(substring-before(substring-after(@T, '['),']'))) != 'NaN'">
        <xsl:text>IMPLICIT:</xsl:text>
        <xsl:value-of select="substring-before(substring-after(@T, '['),']')"/>
        <!-- IMPLICT-ly tagged types may be rendered by unber as
          entities only or as a hybrid (ASCII+entities) string -->
          
        <!-- get number of \x-prefixed hex values -->
        <xsl:variable name="number_of_hexvalues">
		  <xsl:call-template name="count_hexvalues">
		    <xsl:with-param name="string" select="."/>
		  </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <!-- if the string only contains hexvalues then render it
            as an OCTET STRING -->
          <xsl:when test="$number_of_hexvalues * 4 = string-length(.)">
            <xsl:text>,FORMAT:HEX,OCTETSTRING:</xsl:text>
            <xsl:call-template name="fold_long_line">
              <xsl:with-param name="line">
                <xsl:call-template name="xstring_to_hexstring">
                  <xsl:with-param name="string" select="."/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>            
          </xsl:when>
          
          <xsl:otherwise>
            <!-- otherwise render it as a UTF8STRING, leaving the
              hex values escaped -->
            <xsl:text>,FORMAT:UTF8,UTF8String:</xsl:text>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- unber always renders IMPLICIT-ly tagged primitive types as
          hexadecimal strings, so an OCTET STRING type is used -->
      </xsl:when>

      <!-- Fallback: if this happens then this XSLT document needs to
        be extended to cover the unexpected case -->
      <xsl:otherwise>
        <xsl:value-of select="@T"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>  
  
  <!-- 
    Templates for ASN.1 constructed types
    =====================================
  -->
  
  <!-- Generates a section, corresponding to e.g. a SEQUENCE or a
    SET -->
  <xsl:template match="C" mode="section">
    <!-- section name -->
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="." mode="field_name"/>
    <xsl:text>]</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    
    <!-- section contents -->
    <xsl:apply-templates select="C|P"/>
    <xsl:text>&#x0a;</xsl:text>
    
    <!-- recurse to create the sections required by the fields in
      the current section -->
    <xsl:for-each select="C">
      <xsl:apply-templates select="." mode="section"/>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Renders "field_name = field_value" from a C node. -->
  <xsl:template match="C">
    <xsl:apply-templates select="." mode="field_name"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="." mode="field_value"/>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
    <!-- Generates a field value from a C node, using @T to determine
    the type of field. -->
  <xsl:template match="C" mode="field_value">
    <xsl:choose>
      <!-- SEQUENCE -->
      <xsl:when test="@T='[UNIVERSAL 16]'">
        <xsl:text>SEQUENCE:</xsl:text>
        <xsl:apply-templates select="." mode="field_name"/>
      </xsl:when>

      <!-- SET -->
      <xsl:when test="@T='[UNIVERSAL 17]'">
        <xsl:text>SET:</xsl:text>
        <xsl:apply-templates select="." mode="field_name"/>
      </xsl:when>
      
      <!-- [CONTEXT n] EXPLICIT/IMPLICIT -->
      <!-- The test below checks whether the string between the
        brackets — which defines the tag type — is a number, by
        checking that it is not NaN (NaN: not a number) -->
      <xsl:when 
         test="not (number(substring-before(substring-after(@T, '['),']')) = NaN)">
        
        <!-- Explicitly and implicitly tagged types are both decoded
          as [n] by unber.
          Noting that [n] IMPLICIT SEQUENCE … is equivalent (after 
          encoding) to [n] EXPLICIT …, choosing either representation
          is a matter of convenience.
          Two cases are handled here:
          1) There is only one node under the current node: in that
             case, the [n] EXPLICIT … syntax is assumed. -->
        <xsl:choose>
          <xsl:when test="count(C|P) = 1">
            <xsl:text>EXPLICIT:</xsl:text>
            <xsl:value-of select="substring-after(substring-before(@T,']'),'[')"/>
            <xsl:text>,</xsl:text>
            <xsl:apply-templates select="C|P" mode="field_value"/>
          </xsl:when>
        
        <!--
          2) There are several nodes under the current node: in that
             case, the [n] IMPLICIT SEQUENCE … syntax is used. -->
          <xsl:otherwise>
            <xsl:text>IMPLICIT:</xsl:text>
            <xsl:value-of select="substring-after(substring-before(@T,']'),'[')"/>
            <xsl:text>,SEQUENCE:</xsl:text>
            <xsl:apply-templates select="." mode="field_name"/>          
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Fallback: if this happens then this XSLT document needs to
        be extended to cover the unexpected case -->
      <xsl:otherwise>
        <xsl:value-of select="@T"/>
        <xsl:text>:</xsl:text>
        <xsl:apply-templates select="." mode="field_name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
    <!-- Generates a field name from a C node, using @T to determine
    the type of field and @O to give it a unique number.
    If the global $prefix parameter is defined, then it is prepended
    with an '_' to the field name. -->
  <xsl:template match="C" mode="field_name">
    <xsl:if test="$prefix">
      <xsl:value-of select="$prefix"/>
      <xsl:text>_</xsl:text>
    </xsl:if>

    <xsl:choose>
      <!-- SEQUENCE -->
      <xsl:when test="@T='[UNIVERSAL 16]'">
        <xsl:text>seq_</xsl:text>
      </xsl:when>

      <!-- SET -->
      <xsl:when test="@T='[UNIVERSAL 17]'">
        <xsl:text>set_</xsl:text>
      </xsl:when>

      <!-- [CONTEXT n] EXPLICIT/IMPLICIT -->
      <xsl:otherwise>
        <xsl:text>context_</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:value-of select="@O"/>
  </xsl:template>

  <!-- 
    Auxiliary templates
    ===================
  -->
    
  <!-- folds a long line (in parameter $line) into '\'-appended 
    64-character lines -->
  <xsl:template name="fold_long_line">
    <xsl:param name="line"/>
    <xsl:text>\&#x0a;</xsl:text>
    <xsl:choose>
      <xsl:when test="string-length($line) &lt; 65">
        <xsl:value-of select="$line"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring($line, 1, 64)"/>
        <xsl:call-template name="fold_long_line">
          <xsl:with-param name="line" select="substring($line, 65)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- removes the '\x' from a string (in parameter $string) -->
  <xsl:template name="xstring_to_hexstring">
    <xsl:param name="string"/>
    <xsl:call-template name="search_and_replace">
		<xsl:with-param name="replace" select="'\x'"/>
		<xsl:with-param name="in" select="$string"/>
		<xsl:with-param name="with"/>
    </xsl:call-template>
  </xsl:template>

  <!-- converts a bitstring, specified by a number of unused bits
    (in $unused_bits) and the string itself ($bits) to a BITLIST
    e.g. $unused_bits=6, $bits=11000000 => 0,1 -->
  <xsl:template name="bitstring_to_bitlist">
    <xsl:param name="unused_bits"/>
    <xsl:param name="bits"/>
    <xsl:call-template name="indices_of_set_bits_in_bitstring">
	  <xsl:with-param name="offset" select="0"/>
	  <xsl:with-param name="string" select="substring($bits,1,string-length($bits)-$unused_bits)"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- returns the comma-separated indices of set bits (i.e. 1's) in
    a bitstring in parameter $string, adding offset $offset
    (e.g.: 1010 would return 0,2 if $offset == 0 and 1,3 if
    $offset == 1)-->
  <xsl:template name="indices_of_set_bits_in_bitstring">
    <xsl:param name="offset"/>
    <xsl:param name="string"/>
    <xsl:if test="contains($string, '1')">
      <xsl:variable name="set_bit_position" select="string-length(substring-before($string, '1')) + $offset"/>
      <xsl:variable name="bitstring_after_set_bit" select="substring-after($string, '1')"/>
      <xsl:value-of select="$set_bit_position"/>
      <xsl:if test="contains($bitstring_after_set_bit, '1')">
        <xsl:text>,</xsl:text>
        <xsl:call-template name="indices_of_set_bits_in_bitstring">
          <xsl:with-param name="offset" select="$set_bit_position + 1"/>
          <xsl:with-param name="string" select="$bitstring_after_set_bit"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- converts a \x-prefixed string (in parameter $string) to a binary
    string -->
  <xsl:template name="xstring_to_binary">
    <xsl:param name="string"/>
    <xsl:call-template name="hexstring_to_binary">
      <xsl:with-param name="string">
        <xsl:call-template name="xstring_to_hexstring">
          <xsl:with-param name="string" select="$string"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- converts a hexstring (in parameter $string) to a binary string -->
  <xsl:template name="hexstring_to_binary">
    <xsl:param name="string"/>
    <xsl:if test="string-length($string) != 0">
      <xsl:call-template name="hexdigit_to_binary">
		<xsl:with-param name="digit" select="substring($string,1,1)"/>
      </xsl:call-template>
      <xsl:call-template name="hexstring_to_binary">
        <xsl:with-param name="string" select="substring($string,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>  
  
  <!-- converts a hexadecimal digit ([0-9a-f]) in parameter $digit
    to its binary representation -->
  <xsl:template name="hexdigit_to_binary">
    <xsl:param name="digit"/>
    <xsl:choose>
      <xsl:when test="$digit = '0'">0000</xsl:when>
      <xsl:when test="$digit = '1'">0001</xsl:when>
      <xsl:when test="$digit = '2'">0010</xsl:when>
      <xsl:when test="$digit = '3'">0011</xsl:when>
      <xsl:when test="$digit = '4'">0100</xsl:when>
      <xsl:when test="$digit = '5'">0101</xsl:when>
      <xsl:when test="$digit = '6'">0110</xsl:when>
      <xsl:when test="$digit = '7'">0111</xsl:when>
      <xsl:when test="$digit = '8'">1000</xsl:when>
      <xsl:when test="$digit = '9'">1001</xsl:when>
      <xsl:when test="$digit = 'a' or $digit = 'A'">1010</xsl:when>
      <xsl:when test="$digit = 'b' or $digit = 'B'">1011</xsl:when>
      <xsl:when test="$digit = 'c' or $digit = 'C'">1100</xsl:when>
      <xsl:when test="$digit = 'd' or $digit = 'D'">1101</xsl:when>
      <xsl:when test="$digit = 'e' or $digit = 'E'">1110</xsl:when>
      <xsl:when test="$digit = 'f' or $digit = 'F'">1111</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- global search and replace function, which replaces the content
    of $replace in $in with $with -->
  <xsl:template name="search_and_replace">
    <xsl:param name="replace"/>
    <xsl:param name="in"/>
    <xsl:param name="with"/>

    <xsl:choose>
      <xsl:when test="contains($in, $replace)">
        <xsl:value-of select="substring-before($in, $replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="search_and_replace">
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="in" select="substring-after($in, $replace)"/>
          <xsl:with-param name="with" select="$with" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- count number of \x's in a string ($string), thus counting
    hexvalues -->
  <xsl:template name="count_hexvalues">
    <xsl:param name="string"/>
    <xsl:choose>
      <xsl:when test="contains($string, '\x')">
        <xsl:variable name="count_hexvalues_after_prefix">
		  <xsl:call-template name="count_hexvalues">
		    <xsl:with-param name="string" select="substring-after($string, '\x')"/>
		  </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="1+$count_hexvalues_after_prefix"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
