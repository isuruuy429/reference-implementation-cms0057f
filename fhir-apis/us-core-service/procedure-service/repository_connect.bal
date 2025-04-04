import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.uscore700;

isolated uscore700:USCoreProcedureProfile[] procedures = [];
isolated int createOperationNextId = 12344;

public isolated function create(json payload) returns r4:FHIRError|uscore700:USCoreProcedureProfile {
    uscore700:USCoreProcedureProfile|error procedure = parser:parse(payload, uscore700:USCoreProcedureProfile).ensureType();

    if procedure is error {
        return r4:createFHIRError(procedure.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            createOperationNextId += 1;
            procedure.id = (createOperationNextId).toBalString();
        }

        lock {
            procedures.push(procedure.clone());
        }

        return procedure;
    }
}

public isolated function getById(string id) returns r4:FHIRError|uscore700:USCoreProcedureProfile {
    lock {
        foreach var item in procedures {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a procedure resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function search(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        foreach var 'key in searchParameters.keys() {
            match 'key {
                "_id" => {
                    uscore700:USCoreProcedureProfile byId = check getById(searchParameters.get('key)[0]);
                    bundle.entry = [
                        {
                            'resource: byId
                        }
                    ];
                    return bundle;
                }
                _ => {
                    return r4:createFHIRError(string `Not supported search parameter: ${'key}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
                }
            }
        }
    }

    lock {
        r4:BundleEntry[] bundleEntries = [];
        foreach var item in procedures {
            r4:BundleEntry bundleEntry = {
                'resource: item
            };
            bundleEntries.push(bundleEntry);
        }
        r4:Bundle cloneBundle = bundle.clone();
        cloneBundle.entry = bundleEntries;
        return cloneBundle.clone();
    }
}

function init() returns error? {
    lock {
        json procedureJson = {
            "resourceType": "Procedure",
            "id": "12344",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure|7.0.0"]
            },
            "text": {
                "status": "generated",
                "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Generated Narrative: Procedure</b><a name=\"defib-implant\"> </a><a name=\"hcdefib-implant\"> </a></p><div style=\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\"><p style=\"margin-bottom: 0px\">Resource Procedure &quot;defib-implant&quot; </p><p style=\"margin-bottom: 0px\">Profile: <a href=\"StructureDefinition-us-core-procedure.html\">US Core Procedure Profile (version 7.0.0)</a></p></div><p><b>identifier</b>: <a href=\"http://terminology.hl7.org/5.3.0/NamingSystem-uri.html\" title=\"As defined by RFC 3986 (http://www.ietf.org/rfc/rfc3986.txt)(with many schemes defined in many RFCs). For OIDs and UUIDs, use the URN form (urn:oid:(note: lowercase) and urn:uuid:). See http://www.ietf.org/rfc/rfc3001.txt and http://www.ietf.org/rfc/rfc4122.txt \r\n\r\nThis oid is used as an identifier II.root to indicate the the extension is an absolute URI (technically, an IRI). Typically, this is used for OIDs and GUIDs. Note that when this OID is used with OIDs and GUIDs, the II.extension should start with urn:oid or urn:uuid: \r\n\r\nNote that this OID is created to aid with interconversion between CDA and FHIR - FHIR uses urn:ietf:rfc:3986 as equivalent to this OID. URIs as identifiers appear more commonly in FHIR.\r\n\r\nThis OID may also be used in CD.codeSystem.\">Uniform Resource Identifier (URI)</a>/urn:uuid:b2a737f2-2fdb-49c1-b097-dac173d07aff</p><p><b>status</b>: completed</p><p><b>code</b>: Insertion or replacement of permanent implantable defibrillator system with transvenous lead(s), single or dual chamber <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.3.0/CodeSystem-CPT.html\">Current Procedural Terminology (CPT®)</a>#33249)</span></p><p><b>subject</b>: <a href=\"Patient-example.html\">Patient/example</a> &quot; SHAW&quot;</p><p><b>encounter</b>: <a href=\"Encounter-example-1.html\">Encounter/example-1: Office Visit</a></p><p><b>performed</b>: 2019-03-26 12:55:26-0700 --&gt; 2019-03-26 13:25:26-0700</p><h3>Performers</h3><table class=\"grid\"><tr><td style=\"display: none\">-</td><td><b>Actor</b></td></tr><tr><td style=\"display: none\">*</td><td><a href=\"Practitioner-practitioner-1.html\">Practitioner/practitioner-1</a> &quot; BONE&quot;</td></tr></table><p><b>reasonCode</b>: Ventricular fibrillation <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.3.0/CodeSystem-icd10CM.html\">International Classification of Diseases, 10th Revision, Clinical Modification (ICD-10-CM)</a>#I49.01)</span></p><h3>FocalDevices</h3><table class=\"grid\"><tr><td style=\"display: none\">-</td><td><b>Manipulated</b></td></tr><tr><td style=\"display: none\">*</td><td><a href=\"Device-udi-2.html\">Device/udi-2</a></td></tr></table></div>"
            },
            "identifier": [
                {
                    "system": "urn:ietf:rfc:3986",
                    "value": "urn:uuid:b2a737f2-2fdb-49c1-b097-dac173d07aff"
                }
            ],
            "status": "completed",
            "code": {
                "coding": [
                    {
                        "system": "http://www.ama-assn.org/go/cpt",
                        "code": "33249"
                    }
                ],
                "text": "Insertion or replacement of permanent implantable defibrillator system with transvenous lead(s), single or dual chamber"
            },
            "subject": {
                "reference": "Patient/example"
            },
            "encounter": {
                "reference": "Encounter/example-1",
                "display": "Office Visit"
            },
            "performedPeriod": {
                "start": "2019-03-26T12:55:26-07:00",
                "end": "2019-03-26T13:25:26-07:00"
            },
            "performer": [
                {
                    "actor": {
                        "reference": "Practitioner/practitioner-1"
                    }
                }
            ],
            "reasonCode": [
                {
                    "coding": [
                        {
                            "system": "http://hl7.org/fhir/sid/icd-10-cm",
                            "code": "I49.01",
                            "display": "Ventricular fibrillation"
                        }
                    ],
                    "text": "Ventricular fibrillation"
                }
            ],
            "focalDevice": [
                {
                    "manipulated": {
                        "reference": "Device/udi-2"
                    }
                }
            ]
        };
        uscore700:USCoreProcedureProfile procedure = check parser:parse(procedureJson, uscore700:USCoreProcedureProfile).ensureType();
        procedures.push(procedure.clone());
    }
}
