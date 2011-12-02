<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="1.0">
  <xsl:output method="text" indent="no" encoding="utf-8"/>
  <xsl:template match="/">
    <xsl:for-each select="//table[@id = 'viewTestTable']">
      <xsl:for-each select="tr">
        <xsl:for-each select="td">
          <xsl:text>||</xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
        <xsl:text>||
</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
