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
	xmlns:oo="http://purl.org/openorg/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"
	xmlns:gr="http://purl.org/goodrelations/v1#"
	xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	exclude-result-prefixes="xsi equipment-base_uk core equipment-template person-template organisation-template extensions-core externalorganisation-template extensions-base_uk">

	<!-- parameters passed to xslt processor via java application -->
	<xsl:param name="defaultLocale">en_GB</xsl:param>
	<xsl:param name="locale"><xsl:value-of select="$defaultLocale"/></xsl:param>
	<xsl:param name="id"/>
	<xsl:param name="date"/>
	<xsl:param name="key"/>
	<xsl:param name="tempFilesUri"/>
	<!-- declare variables -->
	<xsl:variable name="equipmenTypeFacility">/dk/atira/pure/equipment/equipmenttypes/equipment/facility</xsl:variable>
	<xsl:variable name="equipmenTypeEquipment">/dk/atira/pure/equipment/equipmenttypes/equipment/equipment</xsl:variable>
	
	<xsl:strip-space elements="*"/>
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!--
		tempFilesUri parameter passed to xslt processor via java application
		e.g. select all xml files in path '/Users/awc/Desktop/xmlfiles?select=*.xml'
		N.B. this requires xslt 2.0 processor see http://saxon.sourceforge.net/
	-->
	<xsl:variable name="nodes" select="collection($tempFilesUri)"/>
	<!-- single static file used for testing -->
	<!-- <xsl:variable name="nodes" select="collection('/Users/awc/Desktop?select=equipments.xml')"/> -->

	<xsl:template match="/">	

		<rdf:RDF>
	 		<xsl:for-each select="$nodes/equipment-base_uk:GetEquipmentsResponse/core:result/core:content">
	 			<!-- TODO Fix this? -->
	 				
				<xsl:if test="stab:availableForLoan = true() and (stab:decommissionDate/@xsi:nil='true' or (not(stab:decommissionDate/@xsi:nil='true') and xs:date(stab:decommissionDate) gt current-date()))">
				
					<xsl:variable name="equipmentType"><xsl:value-of select="substring-before(core:portalUrl,'.html')"/></xsl:variable>
					
					<xsl:choose>
						<xsl:when test="equipment-template:typeClassification/core:uri = $equipmenTypeFacility">
							<xsl:call-template name="facility">
								<xsl:with-param name="equipmentType"><xsl:value-of select="$equipmentType"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="equipment">
								<xsl:with-param name="equipmentType"><xsl:value-of select="$equipmentType"/></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
				
			<xsl:for-each-group select="$nodes/equipment-base_uk:GetEquipmentsResponse/core:result/core:content" group-by="equipment-template:responsiblePerson">
				<xsl:call-template name="contact" />
			</xsl:for-each-group>							
		</rdf:RDF>
	</xsl:template>

	<xsl:template name="facility">
		<xsl:param name="equipmentType" />
 		
 		<oo:Facility>
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="$equipmentType"/>
			</xsl:attribute>
			<xsl:call-template name="titleDescription" />
			<xsl:call-template name="responsiblePerson" />
			<xsl:call-template name="ownerLocation" />
		</oo:Facility>
	</xsl:template>
	
 	<xsl:template name="equipment">
		<xsl:param name="equipmentType" />
 	
		<oo:Equipment>
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="$equipmentType"/>
			</xsl:attribute>
			<xsl:call-template name="titleDescription" />
			<xsl:call-template name="responsiblePerson" />
			<xsl:call-template name="ownerLocation" />
			<xsl:call-template name="model">
				<xsl:with-param name="equipmentType"><xsl:value-of select="$equipmentType"/></xsl:with-param>
			</xsl:call-template>							
		</oo:Equipment>

		<xsl:call-template name="manufacturer">
			<xsl:with-param name="equipmentType"><xsl:value-of select="$equipmentType"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
 
  	<xsl:template name="model">
		<xsl:param name="equipmentType" />

		<xsl:if test="not(stab:manufacturer/@xsi:nil=true())">	
			<gr:hasMakeAndModel>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="concat($equipmentType, '#model')"/>
				</xsl:attribute>
			</gr:hasMakeAndModel>	
		</xsl:if>  	
  	</xsl:template>

  	<xsl:template name="manufacturer">
		<xsl:param name="equipmentType" />

		<xsl:if test="not(stab:manufacturer/@xsi:nil=true())">	
	 		<gr:ProductOrServiceModel>
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="concat($equipmentType, '#model')"/>
				</xsl:attribute>
				<gr:hasManufacturer>
					<xsl:attribute name="rdf:resource">
	 					<xsl:value-of select="concat($equipmentType, '#manufacturer')"/>
					</xsl:attribute>
				</gr:hasManufacturer>								
			</gr:ProductOrServiceModel>			
			<gr:BusinessEntity>
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="concat($equipmentType, '#manufacturer')"/>
				</xsl:attribute>
					<rdfs:label><xsl:value-of select="stab:manufacturer/externalorganisation-template:name"/></rdfs:label>
			</gr:BusinessEntity>
		</xsl:if>	
  	</xsl:template>

 	<xsl:template name="titleDescription">
		<rdfs:label><xsl:apply-templates select="equipment-template:title/core:localizedString"/></rdfs:label>
		
		<xsl:if test="equipment-template:description/*">
			<dcterms:description rdf:datatype="xtypes:Fragment-PlainText">
				<xsl:apply-templates select="equipment-template:description/core:localizedString"/>
			</dcterms:description>
		</xsl:if>
 	</xsl:template>

 	<xsl:template name="ownerLocation">
		<xsl:variable name="ownerUri"><xsl:value-of select="substring-before(equipment-template:owner/core:portalUrl, '.html')"/></xsl:variable>
		<oo:formalOrganization>
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="$ownerUri"/>
			</xsl:attribute>								
		</oo:formalOrganization>
								
		<vcard:adr>
			<rdf:Description>
				<xsl:attribute name="rdf:about">
					<xsl:value-of select="concat($ownerUri, '#address')"/>
				</xsl:attribute>
				<xsl:apply-templates select="stab:location" />
			</rdf:Description>
		</vcard:adr>
 	</xsl:template>

	<xsl:template name="contact">
		<rdf:Description>
			<xsl:attribute name="rdf:about">
				<xsl:value-of select="substring-before(equipment-template:responsiblePerson/core:portalUrl, '.html')"/>
			</xsl:attribute>								
			<foaf:name><xsl:apply-templates select="equipment-template:responsiblePerson"/></foaf:name>								
			<foaf:phone>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="concat('tel:', stab:phone)"/>
				</xsl:attribute>
			</foaf:phone>								
			<foaf:mbox>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="concat('mailto:', stab:email)"/>
				</xsl:attribute>
			</foaf:mbox>																							
			<foaf:homepage>
				<xsl:attribute name="rdf:resource">
					<xsl:choose>
						<xsl:when test="starts-with(stab:website/core:localizedString, 'http')">
							<xsl:value-of select="stab:website/core:localizedString"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('http://', stab:website/core:localizedString)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</foaf:homepage>
		</rdf:Description>
	</xsl:template>
 	
 	<xsl:template name="responsiblePerson">
	 	<xsl:if test="equipment-template:responsiblePerson">
			<oo:contact>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="substring-before(equipment-template:responsiblePerson/core:portalUrl, '.html')"/>
				</xsl:attribute>							
			</oo:contact>
		</xsl:if>
 	</xsl:template>

 	<xsl:template match="stab:location">
		<rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Address" />
		<vcard:extended-address><xsl:value-of select="extensions-base_uk:address1"/></vcard:extended-address>
		<vcard:street-address><xsl:value-of select="extensions-base_uk:address2"/>
			<xsl:if test="extensions-base_uk:address3">
				<xsl:text>, </xsl:text><xsl:value-of select="extensions-base_uk:address3"/>
			</xsl:if>
		</vcard:street-address>
		<vcard:locality><xsl:value-of select="extensions-base_uk:address4"/></vcard:locality>
		<vcard:region><xsl:value-of select="extensions-base_uk:address5"/></vcard:region>
		<vcard:postal-code><xsl:value-of select="extensions-base_uk:postalCode"/></vcard:postal-code>
		<vcard:country-name><xsl:apply-templates select="extensions-base_uk:country/core:term/core:localizedString"/></vcard:country-name>
	</xsl:template>

  	<xsl:template match="equipment-template:responsiblePerson">
 		<xsl:value-of select="person-template:name/core:firstName"/><xsl:text> </xsl:text>
 		<xsl:value-of select="person-template:name/core:lastName"/>
	</xsl:template>	
	
 	<xsl:template match="core:localizedString">
		<xsl:choose>
			<!-- awc Select if a child element of parent node has matching locale attribute -->
			<xsl:when test="../*[@locale=$locale]">
				<xsl:value-of select="self::*[@locale=$locale]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- awc Otherwise select if a child element of parent node has matching defaultLocale attribute -->
					<xsl:when test="../*[@locale=$defaultLocale]">
						<xsl:value-of select="self::*[@locale=$defaultLocale]"/>
					</xsl:when>
					<!-- awc Otherwise just select element -->
					<xsl:otherwise>
						<xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>