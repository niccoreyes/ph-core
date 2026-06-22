Profile: PHCoreCapabilityStatement
Parent: CapabilityStatement
Id: ph-core-capability-statement
Title: "PH Core CapabilityStatement"
Description: "CapabilityStatement for the PH Core Implementation Guide. Defines the conformance requirements for FHIR servers implementing the minimum set of Philippine Realm resource constraints. Includes supported resource types with PH Core profiles, RESTful interactions, search parameters, and security expectations. Validated during the June 2026 Aklan Connectathon."

* status 1..1
* status = #draft
* kind 1..1
* kind = #requirements
* fhirVersion = #4.0.1
* format 1..*

* rest 1..*
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.rules = #open
* rest contains server 1..1
* rest[server].mode = #server (exactly)
* rest[server].security 1..1
* rest[server].security insert ObligationRequired
* rest[server].interaction 1..*
* rest[server].resource 1..*
* rest[server].resource.profile 1..1
* rest[server].resource.interaction 1..*

Invariant: ph-core-cs-1
Description: "Server rest entry must declare transaction interaction"
Severity: #error
Expression: "rest.all(mode = 'server' implies interaction.where(code = 'transaction').exists())"
