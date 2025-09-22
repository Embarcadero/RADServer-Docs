//---------------------------------------------------------------------------
#pragma hdrstop

#include "ResourceSimpleDemo.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

void TDemoResource::DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage)
{
	// Call parent validation first
	TBaseInterceptor::DoCustomValidation(ARequest, AValid, AErrorMessage);

	if (!AValid) {
		return;
	}

	// Add simple custom validation for POST requests
	if (ARequest->Method == TEndpointRequest::TMethod::Post) {
		try {
			TJSONValue* BodyValue = nullptr;
			TJSONObject* RequestBody = nullptr;
			if (!ARequest->Body->TryGetValue(BodyValue) || (RequestBody = dynamic_cast<TJSONObject*>(BodyValue)) == nullptr) {
				AValid = false;
				AErrorMessage = "Request body is required for POST requests";
				return;
			}

			// Simple validation - require a "message" field
			TJSONPair* MessagePair = RequestBody->Get("message");
			if (MessagePair == nullptr || MessagePair->JsonValue == nullptr || MessagePair->JsonValue->ToString() == "") {
				AValid = false;
				AErrorMessage = "Message field is required";
				return;
			}
		}
		catch (Exception& E) {
			AValid = false;
			AErrorMessage = "Invalid JSON format: " + E.Message;
		}
	}
}

void TDemoResource::DoCustomLogging(TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	// Add custom logging for successful requests
	TLogHelpers::LogMessage(Format("[DEMO] Simple demo request completed by user: %s", ARRAYOFCONST((CurrentUserID))));

	// Call parent logging
	TBaseInterceptor::DoCustomLogging(ARequest, AResponse);
}

void TDemoResource::DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID)
{
    TBaseInterceptor::DoCustomAuthentication(ARequest, AAuthenticated, AUserID);
}

void TDemoResource::GetHello(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject* ResponseObj = new TJSONObject();
	ResponseObj->AddPair("message", "Hello from simple demo!");
	ResponseObj->AddPair("user", CurrentUserID);
	ResponseObj->AddPair("timestamp", DateTimeToStr(Now()));

	AResponse->StatusCode = 200; // OK
	// Set response with proper ownership management to prevent RAD Server conflicts
	AResponse->Body->SetValue(ResponseObj, false);
}

void TDemoResource::PostEcho(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject* ResponseObj = new TJSONObject();
	TJSONValue* BodyValue = nullptr;
	TJSONObject* RequestBody = nullptr;
	if (!ARequest->Body->TryGetValue(BodyValue) || (RequestBody = dynamic_cast<TJSONObject*>(BodyValue)) == nullptr) {
		RequestBody = new TJSONObject();
	}

	System::String ReqMessage = "";
	
	// Check if the "message" property exists before accessing it
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

	ResponseObj->AddPair("echo", ReqMessage);
	ResponseObj->AddPair("user", CurrentUserID);
	ResponseObj->AddPair("timestamp", DateTimeToStr(Now()));

	AResponse->StatusCode = 201; // Created
	// Set response with proper ownership management to prevent RAD Server conflicts
	AResponse->Body->SetValue(ResponseObj, false);
}

static void Register()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "demo";
	attributes->ResourceSuffix["GetHello"] = "hello";
	attributes->ResourceSuffix["PostEcho"] = "echo";
	RegisterResource(__typeinfo(TDemoResource), attributes.release());
}

#pragma startup Register 64
