SELECT 
    entities_people.name, 
    source_documents.source_document_name
FROM
    entities_people
LEFT OUTER JOIN people_x_sourcedocuments
    ON people_x_sourcedocuments.id_entities_person = entities_people.id_entities_person
LEFT OUTER JOIN source_documents
    ON source_documents.id_source_document = people_x_sourcedocuments.id_source_document
ORDER BY 
    entities_people.name;
    
    
SELECT 
    entities_locations.name, 
    source_documents.source_document_name
FROM
    entities_locations
LEFT OUTER JOIN locations_x_sourcedocuments
    ON locations_x_sourcedocuments.id_entities_location = entities_locations.id_entities_location
LEFT OUTER JOIN source_documents
    ON source_documents.id_source_document = locations_x_sourcedocuments.id_source_document
ORDER BY 
    entities_locations.name;
    

SELECT 
    entities_organizations.name, 
    source_documents.source_document_name
FROM
    entities_organizations
LEFT OUTER JOIN organizations_x_sourcedocuments
    ON organizations_x_sourcedocuments.id_entities_organization = entities_organizations.id_entities_organization
LEFT OUTER JOIN source_documents
    ON source_documents.id_source_document = organizations_x_sourcedocuments.id_source_document
ORDER BY 
    entities_organizations.name;