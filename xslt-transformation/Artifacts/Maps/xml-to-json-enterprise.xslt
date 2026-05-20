<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">
  
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="/">
    {
    "batchId": "<xsl:value-of select="/orders/@batchId"/>",
    "processedAt": "<xsl:value-of select="current-dateTime()"/>",
    "totalOrders": <xsl:value-of select="count(/orders/order)"/>,
    
    "orders": [
    <xsl:for-each select="/orders/order">
      
      <!-- XSLT 3.0 fix: use for expression to multiply per line -->
      <xsl:variable name="orderTotal" as="xs:double"
        select="sum(for $line in lines/line
            return xs:double($line/qty) * xs:double($line/price))"/>
      
      {
      "orderId": "<xsl:value-of select="orderId"/>",
      "customerId": "<xsl:value-of select="customerId"/>",
      "orderDate": "<xsl:value-of select="
        concat(
          substring(orderDate,1,4), '-',
          substring(orderDate,5,2), '-',
          substring(orderDate,7,2))"/>",
      "status": "<xsl:value-of select="status"/>",
      "highValueOrder": <xsl:choose>
        <xsl:when test="$orderTotal > 1000">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>,
      "orderTotal": <xsl:value-of select="format-number($orderTotal,'0.00')"/>,
      
      "lines": [
      <xsl:for-each select="lines/line">
        <xsl:variable name="lineTotal" as="xs:double"
          select="xs:double(qty) * xs:double(price)"/>
        {
        "lineId": "<xsl:value-of select="lineId"/>",
        "productId": "<xsl:value-of select="productId"/>",
        "description": "<xsl:value-of select="description"/>",
        "category": "<xsl:value-of select="category"/>",
        "qty": <xsl:value-of select="xs:double(qty)"/>,
        "price": <xsl:value-of select="format-number(xs:double(price),'0.00')"/>,
        "lineTotal": <xsl:value-of select="format-number($lineTotal,'0.00')"/>,
        "uom": "<xsl:choose>
          <xsl:when test="xs:double(qty) > 100">BULK</xsl:when>
          <xsl:when test="xs:double(qty) > 10">BOX</xsl:when>
          <xsl:otherwise>UNIT</xsl:otherwise>
        </xsl:choose>"
        }<xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
      }<xsl:if test="position() != last()">,</xsl:if>
      
    </xsl:for-each>
    ],
    
    "summary": {
    "grandTotal": <xsl:value-of select="
      format-number(
        sum(for $line in /orders/order/lines/line
          return xs:double($line/qty) * xs:double($line/price)),
        '0.00')"/>,
    "totalLines": <xsl:value-of select="count(/orders/order/lines/line)"/>,
    "status": "processed"
    }
    }
  </xsl:template>
  
</xsl:stylesheet>