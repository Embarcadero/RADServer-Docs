//---------------------------------------------------------------------------
#pragma hdrstop

#include "ResourceDemo.h"
#include <memory>
#include <System.DateUtils.hpp>
#include <System.JSON.hpp>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma classgroup "System.Classes.TPersistent"
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
__fastcall TDemoResource1::TDemoResource1(TComponent* Owner)
	: TDataModule(Owner)
{
}

__fastcall TDemoResource1::~TDemoResource1()
{
}

// Helper method
System::String TDemoResource1::GenerateRequestID()
{
	return FormatDateTime("yyyymmdd-hhnnss-", Now()) + IntToStr(Random(9999));
}

// Check if metadata should be included based on URL parameter
bool TDemoResource1::ShouldIncludeMetadata(TEndpointRequest* ARequest)
{
	try {
		System::String MetadataParam = ARequest->Params->Values["metadata"];
		if (MetadataParam == "false" || MetadataParam == "0" || MetadataParam == "no") {
			return false;
		}
		// Default to true for any other value or if parameter is missing
		return true;
	}
	catch (Exception& E) {
		// If there's any error reading the parameter, default to including metadata
		return true;
	}
}

// Interceptor method
void __fastcall TDemoResource1::BeforeRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse, bool& AHandled)
{
	// Initialize request tracking
	FRequestID = GenerateRequestID();
	FStartTime = Now();

	// Log request start
	TLogHelpers::LogMessage(Format("[%s] %s - Started", ARRAYOFCONST((FRequestID, ARequest->BasePath))));

	// Simple validation for POST requests
	if (ARequest->Method == TEndpointRequest::TMethod::Post) {
		try {
			// Check if request has a body
			if (ARequest->Body->GetString() == "") {
				AResponse->RaiseError(400, "Request body is required for POST requests", "");
				AHandled = true;
				return;
			}
		}
		catch (Exception& E) {
			AResponse->RaiseError(400, "Invalid request format", "");
			AHandled = true;
			return;
		}
	}
}

// Interceptor method
void __fastcall TDemoResource1::AfterRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	int Duration = MilliSecondsBetween(Now(), FStartTime);

	// Log request completion
	TLogHelpers::LogMessage(Format("[%s] Completed in %dms", ARRAYOFCONST((FRequestID, Duration))));

	// Check if metadata should be included
	if (!ShouldIncludeMetadata(ARequest)) {
		return; // Skip metadata addition
	}

	// Add metadata to response
	try {
		TJSONObject* ResponseObj = new TJSONObject();

		// Get the original response data
		TJSONValue* ResponseValue = nullptr;
		if (AResponse->Body->TryGetValue(ResponseValue)) {
			ResponseObj->AddPair("data", ResponseValue);
		}
		else {
			ResponseObj->AddPair("data", new TJSONNull());
		}

		// Add metadata
		TJSONObject* MetaObj = new TJSONObject();
		MetaObj->AddPair("request_id", FRequestID);
		MetaObj->AddPair("timestamp", DateTimeToStr(Now()));
		MetaObj->AddPair("duration_ms", new TJSONNumber(Duration));

		ResponseObj->AddPair("meta", MetaObj);
		AResponse->Body->SetValue(ResponseObj, true);
	}
	catch (Exception& E) {
		TLogHelpers::LogMessage(Format("[%s] Error adding metadata: %s", ARRAYOFCONST((FRequestID, E.Message))));
	}
}

// Resource endpoints
void TDemoResource1::GetHello(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject* ResponseObj = new TJSONObject();
	ResponseObj->AddPair("message", "Hello from demo interceptor!");
	AResponse->Body->SetValue(ResponseObj, true);
}

void TDemoResource1::PostEcho(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject* ResponseObj = new TJSONObject();
	TJSONValue* BodyValue = nullptr;
	System::String ReqMessage = "";
	if (ARequest->Body->TryGetValue(BodyValue)) {
		TJSONObject* RequestBody = dynamic_cast<TJSONObject*>(BodyValue);
		if (RequestBody != nullptr) {
			TJSONPair* MessagePair = RequestBody->Get("message");
			if (MessagePair != nullptr && MessagePair->JsonValue != nullptr) {
				TJSONString* JsonStr = dynamic_cast<TJSONString*>(MessagePair->JsonValue);
				if (JsonStr != nullptr) {
					ReqMessage = JsonStr->Value();
				}
				else {
					ReqMessage = MessagePair->JsonValue->ToString();
				}
			}
		}
	}

	ResponseObj->AddPair("echo", ReqMessage);

	AResponse->StatusCode = 201; // Created
	AResponse->Body->SetValue(ResponseObj, true);
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "demo";
	attributes->ResourceSuffix["GetHello"] = "./hello";
    attributes->ResourceSuffix["PostEcho"] = "./echo";
    RegisterResource(__typeinfo(TDemoResource1), attributes.release());
}

#pragma startup Register 64
