Instance: ExamplePHCoreCapabilityStatement
InstanceOf: PHCoreCapabilityStatement
Usage: #definition
Title: "PH Core Server CapabilityStatement"
Description: "CapabilityStatement for the PH Core Implementation Guide. Defines the conformance requirements for FHIR servers implementing Philippine Realm resource constraints. Validated at the June 2026 Aklan Connectathon using the Juan Dela Cruz ACS scenario (Emergency Department triage and evaluation at Philippine General Hospital)."

* name = "PHCoreServerCapabilityStatement"
* version = "0.2.0"
* status = #draft
* experimental = true
* date = "2026-06-22"
* publisher = "UP Manila National TeleHealth Center"
* description = "CapabilityStatement for the PH Core Implementation Guide. Defines the conformance requirements for FHIR servers implementing the minimum set of Philippine Realm resource constraints. Validated at the June 2026 Aklan Connectathon with the Juan Dela Cruz ACS scenario. Transaction Bundles are supported for atomic submission of clinical packages. Both POST (create) and PUT (update/upsert) patterns are demonstrated in Connectathon-validated examples."
* kind = #requirements
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

// =================================================================================
// REST Server Section
// =================================================================================
* rest[server].mode = #server
* rest[server].documentation = "FHIR RESTful server supporting PH Core profiles and interactions validated at the June 2026 Aklan Connectathon. Supports standard CRUD operations, search, and transaction Bundles for atomic resource submission. Both POST (create-new) and PUT (conditional update/upsert) patterns are supported for each resource type, matching the two Connectathon-validated example Bundles."

// Security
* rest[server].security.service = $restful-security-service#SMART-on-FHIR "SMART-on-FHIR"
* rest[server].security.description = "Implementations SHOULD use SMART on FHIR or equivalent bearer-token authentication. Transport security (TLS) is REQUIRED. See the PH Core IG security guidance for base requirements."

// System-level interactions
* rest[server].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].interaction[=].code = #transaction
* rest[server].interaction[=].documentation = "Transaction Bundle support for atomic submission of clinical packages. The ACS case example uses PUT for idempotent upsert; the general transaction example uses POST for new resource creation."

* rest[server].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].interaction[=].code = #batch

// =================================================================================
// Resource: Patient
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Patient
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-patient"
* rest[server].resource[=].documentation = "Patient demographics with Philippine-specific extensions (nationality, religion, ethnicity, PWD disability, occupation, education). Supports PhilHealth and PhilSys identifiers. Must Support: name (given split into first/middle), birthDate, gender, telecom, address (PSGC hierarchy), identifier."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "identifier"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Patient-identifier"
* rest[server].resource[=].searchParam[=].documentation = "Search by PhilHealth ID or PhilSys ID."
* rest[server].resource[=].searchParam[+].name = "name"
* rest[server].resource[=].searchParam[=].type = #string
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Patient-name"
* rest[server].resource[=].searchParam[+].name = "birthdate"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/individual-birthdate"
* rest[server].resource[=].searchParam[+].name = "gender"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Patient-gender"

// =================================================================================
// Resource: Practitioner
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Practitioner
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-practitioner"
* rest[server].resource[=].documentation = "Practitioner resource for healthcare providers. Includes SOGIE extensions (genderIdentity, individualPronouns, sex). Must Support: name, telecom, address, birthDate, gender, identifier (PRC license)."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "identifier"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Practitioner-identifier"
* rest[server].resource[=].searchParam[=].documentation = "Search by PRC license number."
* rest[server].resource[=].searchParam[+].name = "name"
* rest[server].resource[=].searchParam[=].type = #string
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Practitioner-name"

// =================================================================================
// Resource: Organization
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Organization
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-organization"
* rest[server].resource[=].documentation = "Organization resource for healthcare facilities. Supports NHFR facility code, HCPN network code, PEN, and PAN identifiers. Address constrained to PHCoreAddress with PSGC geographic coding. PartOf for facility hierarchy."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "identifier"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Organization-identifier"
* rest[server].resource[=].searchParam[=].documentation = "Search by NHFR facility code, HCPN code, PEN, or PAN."
* rest[server].resource[=].searchParam[+].name = "name"
* rest[server].resource[=].searchParam[=].type = #string
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Organization-name"

// =================================================================================
// Resource: PractitionerRole
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #PractitionerRole
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-practitionerrole"
* rest[server].resource[=].documentation = "PractitionerRole linking practitioners to facilities and locations. Used in the ACS scenario for ED attending physician role assignment."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "identifier"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/PractitionerRole-identifier"
* rest[server].resource[=].searchParam[+].name = "practitioner"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/PractitionerRole-practitioner"
* rest[server].resource[=].searchParam[+].name = "organization"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/PractitionerRole-organization"

// =================================================================================
// Resource: Location
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Location
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-location"
* rest[server].resource[=].documentation = "Location resource for healthcare service locations and sites within facilities. Address constrained to PHCoreAddress with PSGC geographic hierarchy. Used as reference from Encounter and PractitionerRole."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "name"
* rest[server].resource[=].searchParam[=].type = #string
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Location-name"
* rest[server].resource[=].searchParam[+].name = "organization"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Location-organization"

// =================================================================================
// Resource: RelatedPerson
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #RelatedPerson
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-relatedperson"
* rest[server].resource[=].documentation = "RelatedPerson for patient contacts, next of kin, guardians, and emergency contacts. Supports PhilHealth and PhilSys identifiers with PH Core naming and address constraints."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "patient"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/RelatedPerson-patient"

// =================================================================================
// Resource: Encounter
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Encounter
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-encounter"
* rest[server].resource[=].documentation = "Encounter resource for clinical visits and encounters. class is required and Must Support. Hospitalization details supported. Location references PHCoreLocation. Used in both ACS (ED encounter) and general (ambulatory) scenarios."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Encounter-subject"
* rest[server].resource[=].searchParam[+].name = "date"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Encounter-date"
* rest[server].resource[=].searchParam[+].name = "status"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Encounter-status"
* rest[server].resource[=].searchParam[+].name = "location"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Encounter-location"

// =================================================================================
// Resource: Condition
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Condition
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-condition"
* rest[server].resource[=].documentation = "Condition resource for diagnoses and problems. category, encounter, note, severity, subject, and code are Must Support. Used for encounter diagnosis (ACS) and problem-list (T2DM comorbidity)."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Condition-subject"
* rest[server].resource[=].searchParam[+].name = "encounter"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Condition-encounter"
* rest[server].resource[=].searchParam[+].name = "clinical-status"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Condition-clinical-status"
* rest[server].resource[=].searchParam[+].name = "code"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Condition-code"

// =================================================================================
// Resource: Observation
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].type = #Observation
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-observation"
* rest[server].resource[=].documentation = "Observation resource for clinical measurements, vital signs, and lab results. subject, encounter, performer, basedOn, and partOf constrained to PH Core profiles. Used extensively in the ACS scenario: vital signs (BP, HR, RR, SpO2, temp, pain) and lab results (troponin, glucose, HbA1c, cholesterol, ECG)."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-subject"
* rest[server].resource[=].searchParam[+].name = "encounter"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-encounter"
* rest[server].resource[=].searchParam[+].name = "code"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-code"
* rest[server].resource[=].searchParam[=].documentation = "Search by LOINC code for specific observation types (e.g., 85354-9 for BP, 8480-6 for BP systolic)."
* rest[server].resource[=].searchParam[+].name = "date"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-date"
* rest[server].resource[=].searchParam[+].name = "category"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-category"

// =================================================================================
// Resource: Procedure
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Procedure
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-procedure"
* rest[server].resource[=].documentation = "Procedure resource for clinical procedures and treatments. subject (Patient/Group) and status are Must Support with obligations. encounter is Must Support."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Procedure-subject"
* rest[server].resource[=].searchParam[+].name = "encounter"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Procedure-encounter"
* rest[server].resource[=].searchParam[+].name = "date"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Procedure-date"
* rest[server].resource[=].searchParam[+].name = "code"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Procedure-code"

// =================================================================================
// Resource: Immunization
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Immunization
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-immunization"
* rest[server].resource[=].documentation = "Immunization resource for vaccination records. Includes extensions for BatchNumber and AdministeredProduct. patient, status, lotNumber, and occurrenceDateTime are Must Support with obligations."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "patient"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Immunization-patient"
* rest[server].resource[=].searchParam[+].name = "vaccine-code"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Immunization-vaccine-code"
* rest[server].resource[=].searchParam[+].name = "date"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Immunization-date"

// =================================================================================
// Resource: AllergyIntolerance
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #AllergyIntolerance
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-allergyintolerance"
* rest[server].resource[=].documentation = "AllergyIntolerance resource for patient allergies and adverse reactions. patient is 1..1 Must Support. reaction and onset are Must Support."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "patient"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/AllergyIntolerance-patient"
* rest[server].resource[=].searchParam[+].name = "clinical-status"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/AllergyIntolerance-clinical-status"

// =================================================================================
// Resource: HealthcareService
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #HealthcareService
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-healthcareservice"
* rest[server].resource[=].documentation = "HealthcareService resource for available clinical services. identifier, active, providedBy, location, name, and telecom are Must Support with obligations."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "location"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/HealthcareService-location"
* rest[server].resource[=].searchParam[+].name = "organization"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/HealthcareService-organization"
* rest[server].resource[=].searchParam[+].name = "name"
* rest[server].resource[=].searchParam[=].type = #string
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/HealthcareService-name"

// =================================================================================
// Resource: ServiceRequest
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #ServiceRequest
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-serviceRequest"
* rest[server].resource[=].documentation = "ServiceRequest resource for orders and requests. subject and status are 1..1 Must Support. encounter and requester are Must Support."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/ServiceRequest-subject"
* rest[server].resource[=].searchParam[+].name = "status"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/ServiceRequest-status"

// =================================================================================
// Resource: Provenance
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Provenance
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-provenance"
* rest[server].resource[=].documentation = "Provenance resource for audit trail and data provenance. Agent sliced into ProvenanceAuthor and ProvenanceTransmitter. Agent.who constrained to PH Core profiles. Location references PHCoreLocation."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "target"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Provenance-target"
* rest[server].resource[=].searchParam[+].name = "agent"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Provenance-agent"

// =================================================================================
// Resource: Task
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Task
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-task"
* rest[server].resource[=].documentation = "Task resource for workflow tracking. executionPeriod, for, and note are Must Support. status is 1..1 Must Support. References constrained to PH Core profiles."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "patient"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Task-patient"
* rest[server].resource[=].searchParam[+].name = "status"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Task-status"
* rest[server].resource[=].searchParam[+].name = "owner"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Task-owner"

// =================================================================================
// Resource: Composition
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].type = #Composition
* rest[server].resource[=].profile = "http://hl7.org/fhir/StructureDefinition/Composition"
* rest[server].resource[=].documentation = "Composition resource for clinical documents. Used in the ACS scenario for the ED Physician's Note containing the complete clinical narrative. Currently uses base FHIR profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHOULD
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Composition-subject"
* rest[server].resource[=].searchParam[+].name = "encounter"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Composition-encounter"
* rest[server].resource[=].searchParam[+].name = "date"
* rest[server].resource[=].searchParam[=].type = #date
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Composition-date"
* rest[server].resource[=].searchParam[+].name = "type"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Composition-type"

// =================================================================================
// Experimental: Medication series
// These profiles are marked experimental and MAY be supported.
// =================================================================================

// =================================================================================
// Resource: Medication (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #Medication
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-medication"
* rest[server].resource[=].documentation = "Medication resource for medicinal products. Code bound to DrugsVS (PH FDA drug codes). EXPERIMENTAL profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "code"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Medication-code"

// =================================================================================
// Resource: MedicationRequest (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #MedicationRequest
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-medicationrequest"
* rest[server].resource[=].documentation = "MedicationRequest resource for prescription orders. subject, encounter, medicationReference, requester, and performer constrained to PH Core profiles. DrugsVS binding. EXPERIMENTAL profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationRequest-subject"
* rest[server].resource[=].searchParam[+].name = "encounter"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationRequest-encounter"
* rest[server].resource[=].searchParam[+].name = "medication"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationRequest-medication"

// =================================================================================
// Resource: MedicationStatement (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #MedicationStatement
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-medicationstatement"
* rest[server].resource[=].documentation = "MedicationStatement resource for medication usage records. subject (Patient), context (Encounter), and medicationReference constrained. DrugsVS binding. EXPERIMENTAL profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationStatement-subject"
* rest[server].resource[=].searchParam[+].name = "context"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationStatement-context"

// =================================================================================
// Resource: MedicationDispense (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #MedicationDispense
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-medicationdispense"
* rest[server].resource[=].documentation = "MedicationDispense resource for medication dispense records. subject, context, medicationReference, performer, location, and authorizingPrescription constrained. DrugsVS binding. EXPERIMENTAL profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationDispense-subject"
* rest[server].resource[=].searchParam[+].name = "context"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationDispense-context"

// =================================================================================
// Resource: MedicationAdministration (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #MedicationAdministration
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-medicationadministration"
* rest[server].resource[=].documentation = "MedicationAdministration resource for medication administration records. subject, context, medicationReference, performer, request, and partOf constrained. DrugsVS binding. EXPERIMENTAL profile."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #update
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "subject"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationAdministration-subject"
* rest[server].resource[=].searchParam[+].name = "context"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/MedicationAdministration-context"

// =================================================================================
// Resource: Claim (experimental)
// =================================================================================
* rest[server].resource[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].type = #Claim
* rest[server].resource[=].profile = "https://fhir.doh.gov.ph/phcore/StructureDefinition/ph-core-claim"
* rest[server].resource[=].documentation = "Claim resource for healthcare reimbursement claims. patient, insurer, provider, payee, and careTeam constrained to PH Core profiles."
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #read
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #SHALL
* rest[server].resource[=].interaction[=].code = #search-type
* rest[server].resource[=].interaction[+].extension[$cs-expectation].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* rest[server].resource[=].interaction[=].extension[$cs-expectation].valueCode = #MAY
* rest[server].resource[=].interaction[=].code = #create
* rest[server].resource[=].searchParam[+].name = "_id"
* rest[server].resource[=].searchParam[=].type = #token
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Resource-id"
* rest[server].resource[=].searchParam[+].name = "patient"
* rest[server].resource[=].searchParam[=].type = #reference
* rest[server].resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Claim-patient"
