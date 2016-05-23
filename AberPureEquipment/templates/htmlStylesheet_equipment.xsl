<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"	
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"	
	xmlns:equipment-base_uk="http://atira.dk/schemas/pure4/wsdl/base_uk/equipment/stable"
	xmlns:core="http://atira.dk/schemas/pure4/model/core/stable"
	xmlns:equipment-template="http://atira.dk/schemas/pure4/model/template/abstractequipment/stable"
	xmlns:person-template="http://atira.dk/schemas/pure4/model/template/abstractperson/stable"
	xmlns:organisation-template="http://atira.dk/schemas/pure4/model/template/abstractorganisation/stable"
	xmlns:extensions-core="http://atira.dk/schemas/pure4/model/core/extensions/stable"
	xmlns:externalorganisation-template="http://atira.dk/schemas/pure4/model/template/externalorganisation/stable"
	xmlns:extensions-base_uk="http://atira.dk/schemas/pure4/model/base_uk/extensions/stable"
	xmlns:stab="http://atira.dk/schemas/pure4/model/base_uk/equipment/stable"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsi equipment-base_uk core equipment-template person-template organisation-template extensions-core externalorganisation-template extensions-base_uk stab xs">

	<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:param name="defaultLocale">en_GB</xsl:param>
	<xsl:param name="locale"><xsl:value-of select="$defaultLocale"/></xsl:param>
	<xsl:param name="id"/>
	<xsl:param name="date"/>
	<xsl:param name="key"/>
	<xsl:param name="tempFilesUri"/>
	<xsl:variable name="pound">&#xA3;</xsl:variable>
		
	<!-- <xsl:variable name="nodes" select="collection('/Users/awc/Desktop?select=equipments.xml')"/> -->
	<xsl:variable name="nodes" select="collection($tempFilesUri)"/>
	<xsl:template match="/">	

	<html>
	    <head>
	      <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
	      	<style>
				body {
					font: arial, sans-serif;
	    			background-color: #FFFFFF;
				}
				
				.pure_item {
	    			background-color: #FAFAFA;
	    			border: 1px solid #DDDDDD;
	    			padding:4px;
	    			margin: 4px;
				}

				.pure_title {
	    			font-style: bold;
				}
				
				.group {
	    			background-color: #EFEFFF;
	    			border: 1px solid #DEDEEE;
	    			padding:4px;
				}

				.pure_label{
					margin-right: 4px;
	    			color: #444444;
	    			font-style: italic;
				}
				span {
					margin-right: 4px;
				}
			</style>
	    </head>
	    <body>
    
		<xsl:comment>count:<xsl:value-of select="$nodes[1]/equipment-base_uk:GetEquipmentsResponse/core:count"/></xsl:comment>	
 		<xsl:comment>id:<xsl:value-of select="$id"/></xsl:comment>	
		<xsl:comment>key:<xsl:value-of select="$key"/></xsl:comment>	
		<xsl:comment>locale:<xsl:value-of select="$locale"/></xsl:comment>	
		<xsl:comment>date:<xsl:value-of select="$date"/></xsl:comment>	
		<div>
			<xsl:for-each-group select="$nodes/equipment-base_uk:GetEquipmentsResponse/core:result/core:content" group-by="equipment-template:owner ">
				<xsl:sort select="current-grouping-key()" data-type="text" order="ascending"/>
				
				<h4><xsl:apply-templates select="equipment-template:owner/organisation-template:name/core:localizedString"/></h4>			
				<xsl:for-each select="current-group()">
					
		 			<!-- TODO Fix this? --> 	
					<xsl:if test="stab:availableForLoan = true() and (stab:decommissionDate/@xsi:nil='true' or (not(stab:decommissionDate/@xsi:nil='true') and xs:date(stab:decommissionDate) gt current-date()))">

						<div class="pure_item">

							<div class="group">
								<div><xsl:apply-templates select="equipment-template:title/core:localizedString"/></div>
								<div><xsl:apply-templates select="equipment-template:description/core:localizedString"/></div>
							</div>
														
							<div>
								<xsl:if test="stab:manufacturer/externalorganisation-template:name">
									<span class="pure_label">Manufacturer</span> <span><xsl:value-of select="stab:manufacturer/externalorganisation-template:name"/></span>
								</xsl:if>
								<xsl:if test="not(stab:decommissionDate/@xsi:nil='true')">
									<span class="pure_label">Decommission date</span> <span><xsl:value-of select="format-date(stab:decommissionDate,'[D01]-[M01]-[Y0001]')"/></span>
								</xsl:if>
								<!-- 					
								<xsl:if test="stab:value">
									<span class="pure_label">Value</span> <span><xsl:value-of select="$pound"/><xsl:value-of select="stab:value"/></span>
								</xsl:if>
								-->
							</div>
							
							<div>
								<span class="pure_label">Department</span><xsl:apply-templates select="equipment-template:owner/organisation-template:name/core:localizedString"/>
							</div>
																							
							<xsl:if test="equipment-template:responsiblePerson">
								<div>
									<span class="pure_label">Staff contact</span> <xsl:apply-templates select="equipment-template:responsiblePerson"/>
								</div>
								<div>
									<xsl:if test="not(stab:phone/@xsi:nil='true')">
										<span class="pure_label">phone</span> <span><xsl:value-of select="stab:phone"/></span>
									</xsl:if>
									<xsl:if test="not(stab:fax/@xsi:nil='true')">
										<span class="pure_label">fax</span> <span><xsl:value-of select="stab:fax"/></span>
									</xsl:if>
									<xsl:if test="not(stab:email/@xsi:nil='true')">
										<span class="pure_label">email</span> <span><xsl:apply-templates select="stab:email"/></span>
									</xsl:if>
									<xsl:if test="stab:website/text()">
										<span class="pure_label">web</span> <span><xsl:apply-templates select="stab:website"/></span>
									</xsl:if>
								</div>
							</xsl:if>
	
							<div>
								<span class="pure_label">Equipment Location</span><span><xsl:apply-templates select="stab:location"/></span>
							</div>																							
						</div>
					</xsl:if>
				</xsl:for-each>				
			</xsl:for-each-group>
		</div>
		
		</body>
	</html>
	</xsl:template>

 	<xsl:template match="equipment-template:responsiblePerson">
 		<span><xsl:value-of select="person-template:name/core:firstName"/></span>
 		<span><xsl:value-of select="person-template:name/core:lastName"/></span>
 		<span class="pure_label">email</span><span><xsl:apply-templates select="person-template:organisationAssociations/person-template:organisationAssociation[1]/person-template:email"/></span>
	</xsl:template>

 	<xsl:template match="person-template:email">
		<xsl:element name="a">
			<xsl:attribute name="href">																			
				<xsl:value-of select="concat('mailto:', text())"/>									 	 
			</xsl:attribute>
				<xsl:value-of select="text()"/>									 	 
		</xsl:element> 	
 	</xsl:template>

 	<xsl:template match="stab:email">
		<xsl:element name="a">
			<xsl:attribute name="href">																			
				<xsl:value-of select="concat('mailto:', text())"/>									 	 
			</xsl:attribute>
				<xsl:value-of select="text()"/>									 	 
		</xsl:element> 	
 	</xsl:template>
 	
 	<xsl:template match="stab:location">
	 	<xsl:if test="extensions-base_uk:address1">
	 		<span><xsl:value-of select="extensions-base_uk:address1"/>,</span>
	 	</xsl:if>
	 	<xsl:if test="extensions-base_uk:address2">
	 		<span><xsl:value-of select="extensions-base_uk:address2"/>,</span>
	 	</xsl:if>
	 	<xsl:if test="extensions-base_uk:address3">
	 		<span><xsl:value-of select="extensions-base_uk:address3"/>,</span>		
	 	</xsl:if>
	 	<xsl:if test="extensions-base_uk:address4">
	 		<span><xsl:value-of select="extensions-base_uk:address4"/>,</span>		
	 	</xsl:if>
	 	<xsl:if test="extensions-base_uk:address5">
	 		<span><xsl:value-of select="extensions-base_uk:address5"/>,</span>		
	 	</xsl:if>
	 	<xsl:if test="extensions-base_uk:address1">
	 		<span><xsl:value-of select="extensions-base_uk:postalCode"/>,</span>
	 	</xsl:if>
		<xsl:apply-templates select="extensions-base_uk:country/core:term/core:localizedString"/>
	</xsl:template>
		
	<xsl:template match="stab:website">
		<xsl:variable name="url" select="core:localizedString"/>
			<xsl:element name="a">
				<xsl:attribute name="href">											
					<xsl:choose>
						<xsl:when test="not(starts-with($url, 'http://') or starts-with($url, 'https://'))">				
							<xsl:value-of select="concat('http://', $url)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$url"/>
						</xsl:otherwise>
					</xsl:choose>									 	 
				</xsl:attribute>
				<xsl:attribute name="target">
					<xsl:text>_blank</xsl:text>
				</xsl:attribute>
	 			<xsl:value-of select="$url"/>
			</xsl:element>
	</xsl:template>

 	<xsl:template match="core:localizedString">
		<xsl:choose>
			<!-- awc Select if a child element of parent node has matching locale attribute -->
			<xsl:when test="../*[@locale=$locale]">
				<xsl:value-of select="self::*[@locale=$locale]" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- awc Otherwise select if a child element of parent node has matching defaultLocale attribute -->
					<xsl:when test="../*[@locale=$defaultLocale]">
						<xsl:value-of select="self::*[@locale=$defaultLocale]" disable-output-escaping="yes"/>
					</xsl:when>
					<!-- awc Otherwise just select element -->
					<xsl:otherwise>
						<xsl:value-of select="." disable-output-escaping="yes"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>