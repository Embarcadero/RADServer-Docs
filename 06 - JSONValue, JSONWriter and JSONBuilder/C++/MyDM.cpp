//---------------------------------------------------------------------------
#pragma hdrstop

#include "MyDM.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TTestResource1::TTestResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

void TTestResource1::GetJSON(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
  // create some JSON objects
  TJSONObject* JSONRed = new TJSONObject();
  JSONRed->AddPair("color", "red");
  JSONRed->AddPair("hex", "#ff0000");
  JSONRed->AddPair("default", True);
  JSONRed->AddPair("customId", new TJSONNull());
  TJSONObject* JSONBlue = new TJSONObject();
  JSONBlue->AddPair("color", "blue");
  JSONBlue->AddPair("hex", "#0000ff");
  JSONBlue->AddPair("default", False);
  JSONBlue->AddPair("customId", 653992);
  // create an array and assign the previous objects to it
  TJSONArray* JSONArray = new TJSONArray();
  JSONArray->Add(JSONRed);
  JSONArray->Add(JSONBlue);
  // create an extra object that will contain the array of colors
  TJSONObject* JSONObject = new TJSONObject();
  JSONObject->AddPair("colors", JSONArray);
  AResponse->Body->SetValue(JSONObject, True);
}

void TTestResource1::GetJSONWriter(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
  // to avoid typing AResponse.Body.JSONWriter on every line we store it in a variable
  TJsonWriter* Writer = AResponse->Body->JSONWriter;
  // start the JSON object
  Writer->WriteStartObject();
  Writer->WritePropertyName("colors");
  // start the JSON Array
  Writer->WriteStartArray();
  Writer->WriteStartObject();
  Writer->WritePropertyName("name");
  Writer->WriteValue("red");
  // add WritePropertyName and WriteValue statements as often as needed
  Writer->WritePropertyName("hex");
  Writer->WriteValue("#ff0000");
  Writer->WritePropertyName("default");
  Writer->WriteValue(False);
  Writer->WritePropertyName("customId");
  Writer->WriteNull();
  Writer->WriteEndObject();
  // write as many additional JSON objects as you need
  Writer->WriteStartObject();
  Writer->WritePropertyName("name");
  Writer->WriteValue("blue");
  Writer->WritePropertyName("hex");
  Writer->WriteValue("#0000ff");
  Writer->WritePropertyName("default");
  Writer->WriteValue(True);
  Writer->WritePropertyName("customId");
  Writer->WriteValue(653992);
  // end the JSON object
  Writer->WriteEndObject();
  // end the JSON array
  Writer->WriteEndArray();
  Writer->WriteEndObject();
}

void TTestResource1::GetJSONBuilder(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
  TJsonWriter* Writer = AResponse->Body->JSONWriter;
  // link the JSONWriter from the response to the builder
  TJSONObjectBuilder* Builder = new TJSONObjectBuilder(Writer);
  try {
  Builder
	->BeginObject()
	  ->BeginArray("colors")
		->BeginObject()
		  ->Add("name", "red")
		  ->Add("hex", "#ff0000")
		  ->Add("default", False)
		  ->AddNull("customId")
		->EndObject()
		->BeginObject()
		  ->Add("name", "blue")
		  ->Add("hex", "#0000ff")
		  ->Add("default", True)
		  ->Add("customId", 653992)
		->EndObject()
	  ->EndArray()
	->EndObject();
  } __finally {
	delete Builder;
  }
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "Test";
	attributes->ResourceSuffix["GetJSON"] = "JSON";
	attributes->ResourceSuffix["GetJSONWriter"] = "JSONWriter";
	attributes->ResourceSuffix["GetJSONBuilder"] = "JSONBuilder";
    RegisterResource(__typeinfo(TTestResource1), attributes.release());
}

#pragma startup Register 32
