# CDI-to-GeoNetwork
XSL Transformation of a XML CDI (Common Data Index) file to be imported in GeoNetwork 


________________________________ PURPOSE AND USAGE ________________________________________

This XSLT is a proof of concept for the transformation of the Common Data Index (CDI) XML metadata file to a new one focused on the improved visualization through the GeoNetwork 3.0.4.0 catalogue.

Common Data Index (CDI) are the usual means for reporting on datasets obtained at sea. Usually, this kind of metadata are built using MIKADO software under the requirements of SeaDataNet (http://www.seadatanet.org/). Although the original metadata are great to distribute through the SeaDataNet portal, is not adequate at all to be incorporated into the GeoNetwork catalogue.

Usability is under the scope of this XSLT.

As such, this XSLT must be considered as unstable, and can be updated any time based on the revisions to the ISO19115/ISO19139/SeaDataNet specifications and to the particular requirements of the Instituto Español de Oceanografía.

________________________ MAIN TRANSFORMATION DONE BY THIS XSL ___________________________________________

Modify language to be complaint with ISO/TS 19139 based on code alpha-3 of ISO 639-2.
Convert SDN content to character string.
Remove gmd:metadataExtensionInfo (to avoid errors in ISO validation rules).
Convert sdn:SDN_DataIdentification to gmd:MD_DataIdentification.
Make status = completed.
Insert gmd:spatialRepresentationType element if not already present.
Detect the code of the instrument and add a graphic overview (picture of the isntrument). Pictures have been prevously stored in the GeoNetwork server.
Add links to CSR and CDI inventories with a brief explanation in both English and Spanish.
We assume that all CSR are "series" and all CDI are "dataset". By so doing, we can modify the GeoNetwork GUI to differenciate both kind of resources at the home page. This will facilitate browsing CSR by the end-user.
Make more descriptive the title and alternate title.
INSPIRE title and data are wrong in some CDI files.
Arrange geographic extension.


Authors: Instituto Español de Oceanografía - Pablo Otero pablo.otero@md.ieo.es
