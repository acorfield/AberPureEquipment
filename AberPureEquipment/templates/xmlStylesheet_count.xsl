<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:equipment-base_uk="http://atira.dk/schemas/pure4/wsdl/base_uk/equipment/stable"
	xmlns:core="http://atira.dk/schemas/pure4/model/core/stable"
	exclude-result-prefixes="xsi equipment-base_uk core">

	<xsl:strip-space elements="*"/>
	<xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>
	
	<xsl:template match="/equipment-base_uk:GetEquipmentsResponse">
		<xsl:value-of select="normalize-space(core:count)"/>
	</xsl:template>
</xsl:stylesheet>