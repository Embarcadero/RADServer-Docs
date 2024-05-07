## Chapter 12 - Documenting and testing your endpoints using OpenAPI

This sample is an EMS package that contains a new resource with API documentation that can be accessed via HTTP. It displays the server responses in YAML and JSON formats.This sample uses an EMS package to extend the EMS Server to connect to Interbase (employee.gdb) using FireDAC components.

### Notes about this sample

To simply the process of reusing HTTP status codes, Specs etc the unit _Common_ was created. In this unit you can find multiple classes and records to reference these instead of raw strings or long pre-defined values from EMS.ResourceTypes. This is not mandatory and these can be still referenced normally directly in the attributes but readability, simplicity and avoid human mistakes, it's recommended to abstract the raw values. 

Keep in mind that this sample only shows some of the standard OpenAPI specifications and it's not fully documented. Follow the standards from OpenAPI to define the most standardized spec possible. 

The generated YAML and JSON specs can be access through the endpoints:

* `http://localhost:8080/api/apidoc.yaml`
* `http://localhost:8080/api/apidoc.json`

## See Also 

* [Custom API Documentation](http://docwiki.embarcadero.com/RADStudio/en/Custom_API_Documentation)





