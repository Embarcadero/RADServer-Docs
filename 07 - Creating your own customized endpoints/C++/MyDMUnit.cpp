//---------------------------------------------------------------------------
#pragma hdrstop

#include "MyDMUnit.h"
#include <memory>
#include "Data.DBJson.hpp"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TTestResource1::TTestResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

void TTestResource1::GetCustomersDetails(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	qryCUSTOMER->Open();
	qryCUSTOMER->First();
	qrySALES->Open();

	TStringList* lFields = ExcludeMasterFieldFromFields(qrySALES);

	// this array will store all the objects returned from the ConverToMasterDetail loop
	TJSONArray* lJSONArray = new TJSONArray;
	try {
		while (!qryCUSTOMER->Eof) {
			lJSONArray->Add(SerializeMasterDetail(qryCUSTOMER, qrySALES, "SALES", lFields));
			qryCUSTOMER->Next();
		}

		AResponse->Body->SetValue(lJSONArray, true);
	} __finally {
		lFields->Free();
		qrySALES->Close();
		qryCUSTOMER->Close();
	}
}

void TTestResource1::GetCustomerDetails(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	int lCustomerNo = ARequest->Params->Values["CUST_NO"].ToInt();
    // We use a parameter instead of concatenating the CustomerNo to avoid SQL injection
	qryCUSTOMER->MacroByName("MacroWhere")->AsRaw = "WHERE CUST_NO = :CUST_NO";
	qryCUSTOMER->ParamByName("CUST_NO")->AsInteger = lCustomerNo;
	qryCUSTOMER->Open();
	try {
		if (qryCUSTOMER->RecordCount == 0) {
			AResponse->RaiseNotFound("Not found", "Customer ID not found");
		}
		qrySALES->ParamByName("CUST_NO")->AsInteger = lCustomerNo;
		qrySALES->Open();

		TStringList* lFields = ExcludeMasterFieldFromFields(qrySALES);
		try {
			AResponse->Body->SetValue(
				SerializeMasterDetail(qryCUSTOMER, qrySALES, "SALES", lFields),
				true
			);
		} __finally {
			lFields->Free();
		}
	} __finally {
		qryCUSTOMER->Close();
		qryCUSTOMER->MacroByName("MacroWhere")->Clear();
    }
}

void TTestResource1::PostCustomEndPoint(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject *lJSON;
	System::UnicodeString lName;
	if (!ARequest->Body->TryGetObject(lJSON) && lJSON->TryGetValue("name", lName)) {
		AResponse->RaiseBadRequest("Bad Request", "Missing Data");
	}
	int lID = ARequest->Params->Values["ID"].ToInt();
	// Add your extra business logic
	lName = "The name is " & lName;
	AResponse->Body->JSONWriter->WriteStartObject();
	AResponse->Body->JSONWriter->WritePropertyName("id");
	AResponse->Body->JSONWriter->WriteValue(lID);
	AResponse->Body->JSONWriter->WritePropertyName("name");
	AResponse->Body->JSONWriter->WriteValue(lName);
	AResponse->Body->JSONWriter->WriteEndObject();
}

// given 2 queries with a master/detail relationship, returns 1 JSON object with a nested array with the detail query
TJSONObject* TTestResource1::SerializeMasterDetail(TFDQuery* AMasterDataset, TFDQuery* ADetailDataset, System::UnicodeString APropertyName, TStringList* AFields)
{
	TDataSetToJSONBridge *lBridge = new TDataSetToJSONBridge;
	try {
		// takes the current record of the master query and converts it to a JSON object
		lBridge->Dataset = AMasterDataset;
		lBridge->IncludeNulls = True;
		// specifies that the we only require to process the current record
		lBridge->Area = TJSONDataSetArea::Current;
		TJSONObject* lJSONObject = new TJSONObject;
		// adds the master record as an object in the JSON result
		lJSONObject = (TJSONObject*) lBridge->Produce();

		// in case we passed a list of fields we want to export we assign them to the bridge, otherwise the default behaviour is exporting all fields in the query
		if (AFields != NULL) {
			lBridge->FieldNames->Assign(AFields);
		}
        // the same bridge is being reused, but now the detail dataset is being assigned
		lBridge->Dataset = ADetailDataset;
        // in this case all the records from the query will be processed
		lBridge->Area = TJSONDataSetArea::All;
		TJSONArray* lJSONArray = new TJSONArray;
		// stores the detail array in a temp array to add it afterwards in the main object
		lJSONArray = (TJSONArray*) lBridge->Produce();
		// the array is being added to the main object as an array with the propertyname passed in the argument
		lJSONObject->AddPair(APropertyName, lJSONArray);
		return lJSONObject;
	} __finally {
		lBridge->Free();
	}
}

// if a query has a masterfield assigned, it retuns a stringlist with all the fields but that masterfield
TStringList* TTestResource1::ExcludeMasterFieldFromFields(TFDQuery* ADataset)
{
	System::UnicodeString lMasterField = ADataset->MasterFields;
	TStringList* fields = new TStringList;
	fields->Assign(ADataset->FieldList);
	int i = fields->IndexOf(lMasterField);
	if (i > -1) {
		fields->Delete(i);
	}
	return fields;
}


static void Register()
{
	std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "test";
	attributes->ResourceSuffix["dsrCUSTOMER"] = "customers";
	attributes->ResourceSuffix["dsrSALES"] = "customers/{CUST_NO}/sales";
	attributes->ResourceSuffix["dsrSALES.List"] = "./";
	attributes->ResourceSuffix["dsrSALES.Get"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.Post"] = "./";
	attributes->ResourceSuffix["dsrSALES.Put"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["dsrSALES.Delete"] = "./{PO_NUMBER}";
	attributes->ResourceSuffix["GetCustomersDetails"] = "./customers-details/";
	attributes->ResourceSuffix["GetCustomerDetails"] = "./customers-details/{CUST_NO}";
	attributes->ResourceSuffix["PostCustomEndPoint"] = "./custom/{ID}";

	RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32

