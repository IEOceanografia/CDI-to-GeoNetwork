<?xml version="1.0" encoding="UTF-8"?>

<!--

  Copyright 2016 Instituto Español de Oceanografía
  Licensed under GNU GPLv3
  You may not use this work except in compliance with the License.
  You may obtain a copy of the License at:
  http://www.gnu.org/licenses/gpl-3.0.txt
  
  Authors:      Instituto Español de Oceanografía
                Pablo Otero <pablo.otero@md.ieo.es>

-->

<!--

  PURPOSE AND USAGE

  This XSLT is a proof of concept for the transformation of the 
  Common Data Index (CDI) XML metadata file to a new one focused on
  the improved visualization through the GeoNetwork 3.0.4.0 catalogue.
  
  Common Data Index (CDI) are the usual means for reporting on datasets 
  obtained at sea. Usually, this kind of metadata are built 
  using MIKADO software under the requirements of SeaDataNet. Although the 
  original metadata are great to distribute through the SeaDataNet portal, 
  is not adequate at all to be incorporated into the GeoNetwork catalogue.
  
  Usability is under the scope of this XSLT.

  As such, this XSLT must be considered as unstable, and can be updated any
  time based on the revisions to the ISO19115/ISO19139/SeaDataNet specifications 
  and to the particular requirements of the Instituto Español de Oceanografía.

-->
				
<xsl:stylesheet
    xmlns:gmd    = "http://www.isotc211.org/2005/gmd"    
    xmlns:gmi    = "http://www.isotc211.org/2005/gmi"
	xmlns:sdn    = "http://www.seadatanet.org"
	xmlns:srv    = "http://www.isotc211.org/2005/srv"
	xmlns:gco    = "http://www.isotc211.org/2005/gco"
    xmlns:gts    = "http://www.isotc211.org/2005/gts"	
    xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"  
    xmlns:gmx    = "http://www.isotc211.org/2005/gmx"   
    xmlns:xsi    = "http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gml    = "http://www.opengis.net/gml"
	xmlns:geonet = "http://www.fao.org/geonetwork"
    xmlns:xlink  = "http://www.w3.org/1999/xlink"
    xmlns:ns9    = "http://inspire.ec.europa.eu/schemas/geoportal/1.0"
    xmlns:i      = "http://inspire.ec.europa.eu/schemas/common/1.0"
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd"
	version="1.0">

		
		<!--xmlns:schema = "http://schema.org/"-->
		
	<!-- ============================================================================= -->
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	
	<!-- Remove any white-space-only text nodes (empty lines)-->
    <xsl:strip-space elements="*"/>

	<!-- ============================================================================= -->
	

	<!--

	Mapping parameters
	==================

	This section includes mapping parameters by the XSLT processor.

	-->
	
	<xsl:param name="mTitle"><xsl:value-of select="//gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></xsl:param>
	<xsl:param name="mAlternate"><xsl:value-of select="substring(//gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString/text(),1,4)"/></xsl:param>
    <xsl:param name="mCode"><xsl:value-of select="//sdn:SDN_DeviceCategoryCode/@codeListValue"/></xsl:param>
	<xsl:param name="mSurvey"><xsl:value-of select="//gmd:aggregationInfo[1]/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title/gco:CharacterString"/></xsl:param>
 
	<xsl:param name="mWest"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mEast"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mSouth"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mNorth"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/></xsl:param>
	
	<xsl:param name="name_spatialRepresentationInfo">gmd:spatialRepresentationInfo</xsl:param>
    <xsl:param name="value_spatialRepresentationInfo">
		<gmd:MD_VectorSpatialRepresentation>
			  <gmd:geometricObjects>
				<gmd:MD_GeometricObjects>
				  <gmd:geometricObjectType>
					<gmd:MD_GeometricObjectTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_GeometricObjectTypeCode" codeListValue="point" />
				  </gmd:geometricObjectType>
				</gmd:MD_GeometricObjects>
			  </gmd:geometricObjects>
			</gmd:MD_VectorSpatialRepresentation>
	</xsl:param>

	
	<xsl:param name="name_referenceSystemInfo">gmd:referenceSystemInfo</xsl:param>
    <xsl:param name="value_referenceSystemInfo">		
		<gmd:MD_ReferenceSystem>
		  <gmd:referenceSystemIdentifier>
			<gmd:RS_Identifier>
			  <gmd:code>
				<gco:CharacterString>http://www.opengis.net/def/crs/EPSG/0/3041</gco:CharacterString>
			  </gmd:code>
			</gmd:RS_Identifier>
		  </gmd:referenceSystemIdentifier>
		</gmd:MD_ReferenceSystem>
	</xsl:param>
	
	<!-- URI where images of the instruments are located (to add as thumbnail in GeoNetwork) -->
	<!-- 
		This part could be easily adapted by other National Oceanographic Data Center in other country. Just
        create images for other instruments (ideally with size 200x200) and store them in a accesible directory
        of your GeoNetwork server. 
    -->
	<xsl:variable name="CTDuri">http://192.168.72.77:8080/geonetwork/images/instruments/ctd.jpg</xsl:variable>
	<xsl:variable name="BOTTLEuri">http://192.168.72.77:8080/geonetwork/images/instruments/bottle.jpg</xsl:variable>
	<xsl:variable name="CURRENT1uri">http://192.168.72.77:8080/geonetwork/images/instruments/currentmeter1.jpg</xsl:variable>
	<xsl:variable name="CURRENT2uri">http://192.168.72.77:8080/geonetwork/images/instruments/currentmeter2.jpg</xsl:variable>
	
	<!-- Add thumbnail if vessel code is found -->
	<xsl:param name="name_graphicOverview_small">gmd:graphicOverview</xsl:param>
    <xsl:param name="value_graphicOverview_small">	
        <gmd:MD_BrowseGraphic>
          <gmd:fileName>
			<xsl:if test="$mCode = '130'">
			  <gco:CharacterString><xsl:value-of select="$CTDuri"/></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '30'">
			  <gco:CharacterString><xsl:value-of select="$BOTTLEuri"/></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '114'">
			  <gco:CharacterString><xsl:value-of select="$CURRENT1uri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '115'">
			  <gco:CharacterString><xsl:value-of select="$CURRENT2uri"/></gco:CharacterString>
            </xsl:if>  			
          </gmd:fileName>
          <gmd:fileDescription>
            <gco:CharacterString>thumbnail</gco:CharacterString>
          </gmd:fileDescription>
          <gmd:fileType>
            <gco:CharacterString>jpg</gco:CharacterString>
          </gmd:fileType>
        </gmd:MD_BrowseGraphic>
	</xsl:param>

		
	<!--

	Apply templates
	===============

	-->
	
	<!--Modify language to be complaint with ISO/TS 19139 based on code alpha-3 of ISO 639-2-->
	<xsl:template match="//gmd:language">
		<gmd:language>
			<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="eng">eng</gmd:LanguageCode>
		</gmd:language>
	</xsl:template>
	
    <!-- Convert SDN content to character string -->
    <xsl:template
        match="sdn:SDN_EDMOCode|sdn:SDN_CountryCode|sdn:SDN_PortCode|sdn:SDN_CRSCode|
        sdn:SDN_PlatformCode|sdn:SDN_PlatformCategoryCode|sdn:SDN_EDMERPCode|
        sdn:SDN_WaterBodyCode|sdn:SDN_MarsdenCode|sdn:SDN_ParameterDiscoveryCode|
        sdn:SDN_DeviceCategoryCode|sdn:SDN_DataCategoryCode|sdn:SDN_HierarchyLevelNameCode|
        sdn:SDN_FormatNameCode|sdn:SDN_CSRCode|sdn:SDN_EDMEDCode">
        <gco:CharacterString>
            <xsl:value-of select="text()"/>
        </gco:CharacterString>
    </xsl:template>

    <!-- Remove gmd:metadataExtensionInfo (to avoid errors in ISO validation rules ) -->
	<xsl:template match="gmd:metadataExtensionInfo"/>
	
    <!-- Convert to data identification and add gmd:spatialRepresentationType-->
    <xsl:template match="sdn:SDN_DataIdentification">
        <gmd:MD_DataIdentification>
		
            <xsl:apply-templates select="gmd:citation"/>
			<xsl:apply-templates select="gmd:abstract"/>
			
			<!-- Make status = completed -->
			<xsl:if test="not(//gmd:status)">
				<gmd:status>
					<gmd:MD_ProgressCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ProgressCode" codeListValue="completed" />
				</gmd:status>
			</xsl:if>
			
			<xsl:apply-templates select="gmd:pointOfContact"/>
			
			<xsl:apply-templates select="gmd:resourceMaintenance"/>
			
			<!-- Insert picture -->
			<xsl:if test="($mCode = '130')">
				<xsl:element name="{$name_graphicOverview_small}"><xsl:copy-of select="$value_graphicOverview_small" /></xsl:element>
			</xsl:if>
			
			<xsl:if test="gmd:graphicOverview">
				<xsl:apply-templates select="gmd:graphicOverview"/>
			</xsl:if>
									
			<xsl:for-each select="gmd:descriptiveKeywords">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			
			<xsl:for-each select="gmd:resourceConstraints">
				<xsl:apply-templates select="."/>
			</xsl:for-each>

			<xsl:for-each select="gmd:aggregationInfo">
				<xsl:apply-templates select="."/>
			</xsl:for-each>				
												
			<!-- Insert gmd:spatialRepresentationType element if not already present -->
			<xsl:if test="not(//gmd:spatialRepresentationType)">
				<gmd:spatialRepresentationType>
					<gmd:MD_SpatialRepresentationTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode"
                                                  codeListValue="vector"/>
				</gmd:spatialRepresentationType>
			</xsl:if>
						
			<xsl:apply-templates select="gmd:language"/>
			<xsl:apply-templates select="gmd:characterSet"/>
			<xsl:apply-templates select="gmd:topicCategory"/>
			<xsl:apply-templates select="gmd:extent"/>
			
					
        </gmd:MD_DataIdentification>
    </xsl:template>

	
    <!-- 
         We assume that all CSR are "series" and all CDI are "dataset". By so doing, we can modify the GeoNetwork GUI to differenciate 
         both kind of resources at the home page. This will facilitate browsing CSR and CDI by the end-user. 
	-->	
	<xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode">
        <gmd:MD_ScopeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#MD_ScopeCode" codeListValue="dataset" codeSpace="ISOTC211/19115">Datos/Data</gmd:MD_ScopeCode>
        <xsl:apply-templates select="*"/>   
    </xsl:template>
	
	<xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode">
		<gmd:MD_ScopeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#MD_ScopeCode" codeListValue="dataset" codeSpace="ISOTC211/19115">Datos/Data</gmd:MD_ScopeCode>
		<xsl:apply-templates select="*"/>   
    </xsl:template>
	
	
    <!-- Make more descriptive the title by adding at the beginning the words "Datos/Data: "-->	
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:title">
        <gmd:title>
			<xsl:if test="$mCode = '130'">
			  <gco:CharacterString>CTD: <xsl:copy-of select="$mTitle" /></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '30'">
			  <gco:CharacterString>Muestras agua/Sampling water: <xsl:copy-of select="$mTitle" /></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '114'">
			  <gco:CharacterString>Corrientes/Currents: <xsl:copy-of select="$mTitle" /></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '115'">
			  <gco:CharacterString>Corrientes/Currents: <xsl:copy-of select="$mTitle" /></gco:CharacterString>
            </xsl:if>  			
        </gmd:title>		
    </xsl:template>
	
	<!-- Make more descriptive the alternate title -->
    <xsl:param name="mAltTitle">
      <xsl:value-of select="//gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString"/>
    </xsl:param>	
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
        <gmd:alternateTitle>
            <gco:CharacterString>IEO ref.: <xsl:copy-of select="$mAltTitle" /></gco:CharacterString>
        </gmd:alternateTitle>	        
    </xsl:template>
	
	<!-- INSPIRE title and data are wrong in some CSR files. -->
	<xsl:template match="//gmd:specification/gmd:CI_Citation/gmd:date"/>
	<xsl:template match="//gmd:specification/gmd:CI_Citation/gmd:title">      
	    <gmd:title>
			<gco:CharacterString>Commission Regulation (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services</gco:CharacterString>
	    </gmd:title>
	    <gmd:date>
			<gmd:CI_Date>
				<gmd:date>
					<gco:Date>2010-12-08</gco:Date>
				</gmd:date>
				<gmd:dateType>
					<gmd:CI_DateTypeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#CI_DateTypeCode" codeListValue="publication" codeSpace="ISOTC211/19115">publication</gmd:CI_DateTypeCode>
				</gmd:dateType>
			</gmd:CI_Date>
	    </gmd:date>
	</xsl:template>	
	
	<!-- Modify date to be the end of the cruise. This makes easier to find a cruise inside GeoNetwork -->
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:date">
	    <gmd:date>
            <gmd:CI_Date>
                <gmd:date>
                    <gco:Date><xsl:value-of select="substring(//gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition/text(),1,10)"/></gco:Date>
                </gmd:date>
                <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#CI_DateTypeCode"  codeListValue="creation"  codeSpace="ISOTC211/19115" >creation</gmd:CI_DateTypeCode>
                </gmd:dateType>
            </gmd:CI_Date>
        </gmd:date>
	</xsl:template>
	

	<!-- Arrange geographic extension
	
		 Delete other existent geographic elements, as for example, GML information from the track cruise, 
	     but keep those related to the bounding box. Note that from GeoNetwork 3.0.1 multiple geographic
		 boundary boxes are permitted.
		 
		 Moreover, GeoNetwork (at least v3.0.4) fails in the 
		 spatial extent representation if any of the coordinates is "0". We check and add some decimals 
		 if neccesary. Sometimes, the  spatial representation also fails if is a point. We add and substract 0.0001
		 to create a very small square.
		 -->
	<xsl:template match="//gmd:extent/gmd:EX_Extent">
		<gmd:EX_Extent>
		    <xsl:for-each select="gmd:geographicElement">
			   <xsl:if test="gmd:EX_GeographicBoundingBox">
				<gmd:geographicElement>
					<gmd:EX_GeographicBoundingBox>				
						<gmd:westBoundLongitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal - 0.001"/></gco:Decimal>
							</xsl:if>
						</gmd:westBoundLongitude>
						<gmd:eastBoundLongitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal + 0.001"/></gco:Decimal>
							</xsl:if>
						</gmd:eastBoundLongitude>
						<gmd:southBoundLatitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal - 0.001"/></gco:Decimal>
							</xsl:if>
						</gmd:southBoundLatitude>
						<gmd:northBoundLatitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal + 0.001"/></gco:Decimal>
							</xsl:if>
						</gmd:northBoundLatitude>
					</gmd:EX_GeographicBoundingBox>
				</gmd:geographicElement>	
               </xsl:if>				
			</xsl:for-each>
			<xsl:apply-templates select="gmd:temporalElement"/>
			<xsl:apply-templates select="gmd:verticalElement"/>
		</gmd:EX_Extent>			
	</xsl:template>
	
	
	<xsl:template match="//gmd:transferOptions">
		<gmd:transferOptions>				
			<!-- Add links to CSR and CDI inventories with a brief explanation in both English and Spanish (keep end-users in mind!) -->
			<gmd:MD_DigitalTransferOptions>
			  <gmd:onLine>
				<gmd:CI_OnlineResource>
				  <gmd:linkage>
					<gmd:URL>http://seadatanet.maris2.nl/v_cdi_v3/search.asp</gmd:URL>
				  </gmd:linkage>
				  <gmd:protocol>
					<gco:CharacterString>WWW:LINK-1.0-http--related</gco:CharacterString>
				  </gmd:protocol>
				  <gmd:name>
					<gco:CharacterString>Solicita los datos a través del portal de SeaDataNet. Introduce "<xsl:value-of select="$mTitle"/>" en el cajetín de búsqueda. | &#xD;&#xA; 
										 Request data through the SeaDataNet portal. Insert "<xsl:value-of select="$mTitle"/>" in the free search box.</gco:CharacterString>
				  </gmd:name>
				  <gmd:description>
					<gco:CharacterString>SeaDataNet - CDI inventory</gco:CharacterString>
				  </gmd:description>
				</gmd:CI_OnlineResource>
			  </gmd:onLine>
			  <gmd:onLine>
				<gmd:CI_OnlineResource>
				  <gmd:linkage>
					<gmd:URL>http://seadata.bsh.de/csr/retrieve/sdn2_index.html</gmd:URL>
				  </gmd:linkage>
				  <gmd:protocol>
					<gco:CharacterString>WWW:LINK-1.0-http--related</gco:CharacterString>
				  </gmd:protocol>
				  <gmd:name>
					<gco:CharacterString>Base de datos internacional con información de más de 53.000 campañas desde 1873 hasta la actualidad. Utiliza la plabra clave "<xsl:value-of select="$mSurvey"/>" para buscar más información de la presente campaña. | &#xD;&#xA; 
										 International database with information of more than 53.000 surveys from 1873 till today. Search the current cruise summary report by using the tag <xsl:value-of select="$mSurvey"/>.</gco:CharacterString>
				  </gmd:name>
				  <gmd:description>
					<gco:CharacterString>SeaDataNet - CRS inventory</gco:CharacterString>
				  </gmd:description>
				</gmd:CI_OnlineResource>
			  </gmd:onLine>
			</gmd:MD_DigitalTransferOptions>
		</gmd:transferOptions>
	</xsl:template>
			
	<!-- Apply templates (master) -->	
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>			
        </xsl:copy>		
    </xsl:template>
	
	<!-- replace xsi:schemaLocation attribute -->
    <xsl:template match="@xsi:schemaLocation">
		<xsl:attribute name="xsi:schemaLocation">http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd</xsl:attribute>
    </xsl:template>
	
</xsl:stylesheet>