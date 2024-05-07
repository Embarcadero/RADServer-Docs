//---------------------------------------------------------------------------
#pragma hdrstop

//#include "APIDocCppAttributesUnit.h"
#include "MyDM.h"
#include <memory>
#include "APIDocSpecs.cpp"
#include "Common.cpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TTestResource1::TTestResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

static void Register()
{
	std::auto_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "test";
	//YAML definitions
	attributes->YAMLDefinitions["test"] = APISpecs::initYamlDefinitions();
	//JSON definitions
	attributes->JSONDefinitions["test"] = APISpecs::initJSONDefinitions();

	//Customer endpoint
	std::unique_ptr<EndPointRequestSummaryAttribute> RequestSummary(new EndPointRequestSummaryAttribute(
																		"Customers", // Tags
																		"Customers", // Summary
																		"Description of the Customers endpoint", // Description
																		"application/json", // Produces
																		"")); // Consumes
	attributes->RequestSummary["dsrCUSTOMER"] = RequestSummary.get();

	//Add Parameters
	std::unique_ptr<EndPointRequestParameterAttribute> ResponseParameter(new EndPointRequestParameterAttribute(
																			 TSpecs::ParamIn::Path,
																			 "CUST_NO", // Param name
																			 "Customer number", // desc
																			 true, // required
																			 TSpecs::Types::spInteger,
																			 TSpecs::Formats::Int64,
																			 TSpecs::Types::spInteger,
																			 "", // Schema
																			 "")); // Reference
	attributes->AddRequestParameter(generateMethod("dsrCUSTOMER", TMethods::Get), ResponseParameter.get());
	ResponseParameter.reset(new EndPointRequestParameterAttribute(
								TSpecs::ParamIn::Body,
								"Name", // Param name
								"Description", // desc
								true, // required
								TSpecs::Types::spObject,
								TSpecs::Formats::None,
								TSpecs::Types::spObject,
								"#/definitions/customer", // Schema
								"#/definitions/customer")); // Reference
	attributes->AddRequestParameter("dsrCUSTOMER.Post", ResponseParameter.get());
	ResponseParameter.reset(new EndPointRequestParameterAttribute(
								TSpecs::ParamIn::Path,
								"CUST_NO", // Param name
								"Customer number", // desc
								true, // required
								TSpecs::Types::spInteger,
								TSpecs::Formats::Int64,
								TSpecs::Types::spInteger,
								"", // Schema
								"")); // Reference
	attributes->AddRequestParameter(generateMethod("dsrCUSTOMER", TMethods::Delete), ResponseParameter.get());

	//Add Responses
	std::unique_ptr<EndPointResponseDetailsAttribute> ResponseDetail(new EndPointResponseDetailsAttribute(TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spArray, TSpecs::Formats::None, "", "#/definitions/customer"));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::List), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/customer"));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::Get), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TStatus::Created::Code, TStatus::Created::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/customer"));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::Post), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/customer"));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::Put), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TStatus::BadRequest::Code, TStatus::BadRequest::Reason, TSpecs::Types::spNull, TSpecs::Formats::None, "", ""));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::Post), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TStatus::NotFound::Code, TStatus::NotFound::Reason, TSpecs::Types::spNull, TSpecs::Formats::None, "", ""));
	attributes->AddResponseDetail(generateMethod("dsrCUSTOMER", TMethods::Post), ResponseDetail.get());

	attributes->ResourceSuffix["dsrCUSTOMER"] = "customers";
	attributes->ResourceSuffix["dsrCUSTOMER.List"] = "./";
	attributes->ResourceSuffix["dsrCUSTOMER.Get"] = "./{CUST_NO}";
	attributes->ResourceSuffix["dsrCUSTOMER.Post"] = "./";
	attributes->ResourceSuffix["dsrCUSTOMER.Put"] = "./{CUST_NO}";
	attributes->ResourceSuffix["dsrCUSTOMER.Delete"] = "./{CUST_NO}";

	// Sales endpoint
	RequestSummary.reset(new EndPointRequestSummaryAttribute("Sales", "Sales", "Description of the Sales endpoint", "application/json", ""));
	attributes->RequestSummary["dsrSALES"] = RequestSummary.get();

	// Add Parameters
	ResponseParameter.reset(new EndPointRequestParameterAttribute(TSpecs::ParamIn::Path, "PO_NUMBER", "Sale number", true, TSpecs::Types::spString, TSpecs::Formats::None, TSpecs::Types::spString,"", ""));
	attributes->AddRequestParameter(generateMethod("dsrSALES", TMethods::Get), ResponseParameter.get());
	ResponseParameter.reset(new EndPointRequestParameterAttribute(TMethods::Post, TSpecs::ParamIn::Body, "Name", "Description", true, TSpecs::Types::spObject, TSpecs::Formats::None, TSpecs::Types::spObject, "#/definitions/sale", "#/definitions/sale"));
	attributes->AddRequestParameter(generateMethod("dsrSALES", TMethods::Post), ResponseParameter.get());
	ResponseParameter.reset(new EndPointRequestParameterAttribute(TMethods::Delete, TSpecs::ParamIn::Path, "PO_NUMBER", "Sale number", true, TSpecs::Types::spString, TSpecs::Formats::None, TSpecs::Types::spString, "", ""));
	attributes->AddRequestParameter(generateMethod("dsrSALES", TMethods::Delete), ResponseParameter.get());

	// Add Response Details
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::List, TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spArray, TSpecs::Formats::None, "", "#/definitions/sale"));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::List), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::Get, TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/sale"));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::Get), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::Post, TStatus::Created::Code, TStatus::Created::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/sale"));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::Post), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::Put, TStatus::Ok::Code, TStatus::Ok::Reason, TSpecs::Types::spObject, TSpecs::Formats::None, "", "#/definitions/sale"));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::Put), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::Post, TStatus::BadRequest::Code, TStatus::BadRequest::Reason, TSpecs::Types::spNull, TSpecs::Formats::None, "", ""));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::Post), ResponseDetail.get());
	ResponseDetail.reset(new EndPointResponseDetailsAttribute(TMethods::Get, TStatus::NotFound::Code, TStatus::NotFound::Reason, TSpecs::Types::spNull, TSpecs::Formats::None, "", ""));
	attributes->AddResponseDetail(generateMethod("dsrSALES", TMethods::Get), ResponseDetail.get());

	attributes->ResourceSuffix["dsrSALES"] = "sales";
	attributes->ResourceSuffix["dsrSALES.List"] = "./";
	attributes->ResourceSuffix["dsrSALES.Get"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.Post"] = "./";
	attributes->ResourceSuffix["dsrSALES.Put"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.Delete"] = "./{PO_NUMBER}";

	RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32
