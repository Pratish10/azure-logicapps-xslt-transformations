<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:j="http://www.w3.org/2005/xpath-functions"
                xmlns:out="http://enterprise.output/orders"
                xmlns:dm="http://azure.workflow.datamapper" 
                xmlns:ef="http://azure.workflow.datamapper.extensions"
                exclude-result-prefixes="xs j ef">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:function name="ef:safe-number" as="xs:double">
    <xsl:param name="v" as="item()?"/>
    <xsl:sequence select="if (string($v) castable as xs:double)
        then xs:double($v) else 0"/>
  </xsl:function>
  
  <xsl:function name="ef:format-date" as="xs:string">
    <xsl:param name="raw" as="xs:string"/>
    <xsl:sequence select="if (matches($raw, '^\d{8}$'))
        then concat(substring($raw,1,4),'-',
          substring($raw,5,2),'-',
          substring($raw,7,2))
      else $raw"/>
  </xsl:function>
  
  <xsl:template match="/">
    
    <xsl:variable name="parsed" select="json-to-xml(/)"/>
    <xsl:variable name="root" select="$parsed/j:map"/>
    <xsl:variable name="orders"
      select="$root/j:array[@key='orders']/j:map"/>
    
    <out:orderBatch
      batchId="{$root/j:string[@key='batchId']}"
      generatedAt="{current-dateTime()}"
      totalOrders="{count($orders)}">
      
      <xsl:apply-templates select="$orders" mode="header">
        <xsl:with-param name="batchId" tunnel="yes"
          select="$root/j:string[@key='batchId']"/>
      </xsl:apply-templates>
      
      <xsl:apply-templates select="$root" mode="summary"/>
      
    </out:orderBatch>
  </xsl:template>
  
  <xsl:template match="j:map" mode="header">
    <xsl:param name="batchId" tunnel="yes"/>
    
    <xsl:variable name="order" select="."/>
    <xsl:variable name="orderId"
      select="$order/j:string[@key='orderId']"/>
    
    <out:order
      id="{$orderId}"
      batchRef="{$batchId}">
      
      <out:header>
        <out:orderId><xsl:value-of select="$orderId"/></out:orderId>
        <out:customerId>
          <xsl:value-of select="$order/j:string[@key='customerId']"/>
        </out:customerId>
        <out:orderDate>
          <xsl:value-of select="ef:format-date(
              string($order/j:string[@key='orderDate']))"/>
        </out:orderDate>
        <out:currency>
          <xsl:value-of select="
            if (string($order/j:string[@key='currency']) != '')
              then $order/j:string[@key='currency']
            else 'EUR'"/>
        </out:currency>
        <out:priority>
          <xsl:choose>
            <xsl:when test="$order/j:boolean[@key='urgent'] = 'true'">HIGH</xsl:when>
            <xsl:when test="ef:safe-number($order/j:number[@key='total']) > 50000">HIGH</xsl:when>
            <xsl:when test="ef:safe-number($order/j:number[@key='total']) > 10000">MEDIUM</xsl:when>
            <xsl:otherwise>NORMAL</xsl:otherwise>
          </xsl:choose>
        </out:priority>
      </out:header>
      
      <xsl:apply-templates
        select="$order/j:array[@key='lines']/j:map"
        mode="lines">
        <xsl:with-param name="orderId" tunnel="yes" select="$orderId"/>
      </xsl:apply-templates>
      
      <out:totals>
        <out:lineCount>
          <xsl:value-of select="count($order/j:array[@key='lines']/j:map)"/>
        </out:lineCount>
        <out:orderTotal>
          <xsl:value-of select="format-number(
              sum($order/j:array[@key='lines']/j:map/
                (ef:safe-number(j:number[@key='qty']) *
                  ef:safe-number(j:number[@key='unitPrice']))),
              '0.00')"/>
        </out:orderTotal>
      </out:totals>
      
      <xsl:apply-templates select="." mode="audit"/>
      
    </out:order>
  </xsl:template>
  
  <xsl:template match="j:map" mode="lines">
    <xsl:param name="orderId" tunnel="yes"/>
    
    <xsl:variable name="qty"
      select="ef:safe-number(j:number[@key='qty'])"/>
    <xsl:variable name="price"
      select="ef:safe-number(j:number[@key='unitPrice'])"/>
    
    <out:line
      seq="{position()}"
      orderRef="{$orderId}">
      <out:productId>
        <xsl:value-of select="j:string[@key='productId']"/>
      </out:productId>
      <out:description>
        <xsl:value-of select="j:string[@key='description']"/>
      </out:description>
      <out:qty><xsl:value-of select="$qty"/></out:qty>
      <out:unitPrice>
        <xsl:value-of select="format-number($price,'0.00')"/>
      </out:unitPrice>
      <out:lineTotal>
        <xsl:value-of select="format-number($qty * $price,'0.00')"/>
      </out:lineTotal>
      <out:warehouse>
        <xsl:choose>
          <xsl:when test="j:string[@key='warehouse'] != ''">
            <xsl:value-of select="j:string[@key='warehouse']"/>
          </xsl:when>
          <xsl:otherwise>DEFAULT</xsl:otherwise>
        </xsl:choose>
      </out:warehouse>
    </out:line>
  </xsl:template>
  
  <xsl:template match="j:map" mode="summary">
    <xsl:variable name="allOrders"
      select="j:array[@key='orders']/j:map"/>
    <out:batchSummary>
      <out:totalOrders>
        <xsl:value-of select="count($allOrders)"/>
      </out:totalOrders>
      <out:totalLines>
        <xsl:value-of select="count(
            $allOrders/j:array[@key='lines']/j:map)"/>
      </out:totalLines>
      <out:grandTotal>
        <xsl:value-of select="format-number(
            sum($allOrders/j:array[@key='lines']/j:map/
              (ef:safe-number(j:number[@key='qty']) *
                ef:safe-number(j:number[@key='unitPrice']))),
            '0.00')"/>
      </out:grandTotal>
      <out:generatedAt>
        <xsl:value-of select="current-dateTime()"/>
      </out:generatedAt>
    </out:batchSummary>
  </xsl:template>
  
  <xsl:template match="j:map" mode="audit">
    <out:audit>
      <out:transformedAt>
        <xsl:value-of select="current-dateTime()"/>
      </out:transformedAt>
      <out:transformVersion>3.0</out:transformVersion>
      <out:sourceFormat>JSON</out:sourceFormat>
      <out:targetFormat>XML</out:targetFormat>
    </out:audit>
  </xsl:template>
  
</xsl:stylesheet>