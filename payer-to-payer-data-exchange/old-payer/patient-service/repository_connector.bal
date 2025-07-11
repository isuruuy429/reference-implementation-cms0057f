import ballerina/http;
import ballerinax/health.clients.fhir;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.uscore501;

isolated uscore501:USCorePatientProfile[] patients = [];
isolated int createOperationNextId = 102;

public isolated function create(json payload) returns r4:FHIRError|uscore501:USCorePatientProfile {
    uscore501:USCorePatientProfile|error patient = parser:parse(payload, uscore501:USCorePatientProfile).ensureType();

    if patient is error {
        return r4:createFHIRError(patient.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            patient.id = (++createOperationNextId).toBalString();
        }

        lock {
            patients.push(patient.clone());
        }

        return patient;
    }
}

public isolated function getById(string id) returns r4:FHIRError|uscore501:USCorePatientProfile {
    lock {
        foreach var item in patients {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a Patient resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function search(string 'resource, map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        // if searchParameters.keys().count() == 0 {
        //     lock {
        //         r4:BundleEntry[] bundleEntries = [];
        //         foreach var item in patients {
        //             r4:BundleEntry bundleEntry = {
        //                 'resource: item
        //             };
        //             bundleEntries.push(bundleEntry);
        //         }
        //         r4:Bundle BundleClone = bundle.clone();
        //         BundleClone.entry = bundleEntries;
        //         return BundleClone.clone();
        //     }
        // }

        foreach var 'key in searchParameters.keys() {
            match 'key {
                "given" => {
                    uscore501:USCorePatientProfile byGivenName = {identifier: [], gender: "unknown", name: []};
                    lock {
                        foreach uscore501:USCorePatientProfile item in patients {
                            string givenNameParam = searchParameters.get('key)[0];
                            uscore501:USCorePatientProfileName[] names = item.name;

                            if names.length() == 0 {
                                //no matches
                                return r4:createFHIRError(string `No matching Patients: ${'key}:, ${'givenNameParam}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
                            }

                            // Taking the first element since this is a refernce impl
                            string[] givenNames = <string[]>names[0].given;
                            if givenNames[0] == givenNameParam {
                                byGivenName = item.clone();

                            }
                        }
                    }
                    bundle.entry = [
                        {
                            'resource: byGivenName
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

    return bundle;
}

public isolated function update(json payload) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);

}

public isolated function patchResource(string 'resource, string id, json payload) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
}

public isolated function delete(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse {
    return r4:createFHIRError("Not implemented", r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);

}

function init() returns error? {
    lock {
        map<json> patientJson = {
            "given1": {
                "resourceType": "Patient",
                "id": "101",
                "meta": {
                    "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]
                },
                "identifier": [
                    {
                        "system": "http://hospital.org/patients",
                        "value": "12345"
                    }
                ],
                "name": [
                    {
                        "use": "official",
                        "family": "Smith",
                        "given": ["John"]
                    }
                ],
                "gender": "male",
                "birthDate": "1979-04-15",
                "address": [
                    {
                        "line": ["123 Main St"],
                        "city": "Anytown",
                        "state": "CA",
                        "postalCode": "90210",
                        "country": "US"
                    }
                ],
                "telecom": [
                    {
                        "system": "phone",
                        "value": "+1 555-555-5555",
                        "use": "mobile"
                    },
                    {
                        "system": "email",
                        "value": "john@example.com"
                    }
                ]
            },
            "given2": {
                "resourceType": "Patient",
                "id": "101",
                "meta": {
                    "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]
                },
                "identifier": [
                    {
                        "system": "http://hospital.org/patients",
                        "value": "12345"
                    }
                ],
                "name": [
                    {
                        "use": "official",
                        "family": "Smith",
                        "given": ["John"]
                    }
                ],
                "gender": "male",
                "birthDate": "1979-04-15",
                "address": [
                    {
                        "line": ["123 Main St"],
                        "city": "Anytown",
                        "state": "CA",
                        "postalCode": "90210",
                        "country": "US"
                    }
                ],
                "telecom": [
                    {
                        "system": "phone",
                        "value": "+1 555-555-5555",
                        "use": "mobile"
                    },
                    {
                        "system": "email",
                        "value": "john@example.com"
                    }
                ]
            },
            "given3": {
                "resourceType": "Patient",
                "id": "588675dc-e80e-4528-a78f-af10f9755f23",
                "meta": {
                    "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]
                },
                "identifier": [
                    {
                        "system": "http://hospital.org/patients",
                        "value": "12345"
                    }
                ],
                "name": [
                    {
                        "use": "official",
                        "family": "Smith",
                        "given": ["John"]
                    }
                ],
                "gender": "male",
                "birthDate": "1979-04-15",
                "address": [
                    {
                        "line": ["123 Main St"],
                        "city": "Anytown",
                        "state": "CA",
                        "postalCode": "90210",
                        "country": "US"
                    }
                ],
                "telecom": [
                    {
                        "system": "phone",
                        "value": "+1 555-555-5555",
                        "use": "mobile"
                    },
                    {
                        "system": "email",
                        "value": "john@example.com"
                    }
                ]
            }
        };
        foreach string given in patientJson.keys() {
            uscore501:USCorePatientProfile patient = check parser:parse(patientJson[given], uscore501:USCorePatientProfile).ensureType();
            patients.push(patient);

        }
    }

}
