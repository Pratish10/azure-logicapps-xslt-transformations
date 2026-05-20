<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="/">
    <deliveryNote>
      
      <referenceId>
        <xsl:value-of select="/purchaseOrder/orderId"/>
      </referenceId>
      
      <deliverTo>
        <xsl:value-of select="/purchaseOrder/customer"/>
      </deliverTo>
      
      <lines>
        <xsl:for-each select="/purchaseOrder/items/item">
          <deliveryLine>
            <sku><xsl:value-of select="itemId"/></sku>
            <quantity><xsl:value-of select="qty"/></quantity>
            <unitPrice><xsl:value-of select="price"/></unitPrice>
            <lineTotal>
              <xsl:value-of select="qty * price"/>
            </lineTotal>
          </deliveryLine>
        </xsl:for-each>
      </lines>
      
      <!-- call named template to compute grand total -->
      <grandTotal>
        <xsl:call-template name="sumTotal">
          <xsl:with-param name="items" select="/purchaseOrder/items/item"/>
          <xsl:with-param name="total" select="0"/>
        </xsl:call-template>
      </grandTotal>
      
    </deliveryNote>
  </xsl:template>
  
  <!-- named template: recursively accumulates qty*price -->
  <xsl:template name="sumTotal">
    <xsl:param name="items"/>
    <xsl:param name="total"/>
    <xsl:choose>
      <xsl:when test="$items">
        <xsl:call-template name="sumTotal">
          <xsl:with-param name="items" select="$items[position() > 1]"/>
          <xsl:with-param name="total"
            select="$total + ($items[1]/qty * $items[1]/price)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$total"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>