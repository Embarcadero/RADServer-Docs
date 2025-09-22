//---------------------------------------------------------------------------
#pragma hdrstop

#include "ResourceAdminDemo.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)

// TAdminDemoResource implementation
void TAdminDemoResource::DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID)
{
	// Call parent authentication first
	TBaseInterceptor::DoCustomAuthentication(ARequest, AAuthenticated, AUserID);

	if (!AAuthenticated) {
		return;
	}

	// Add admin-specific authentication
	System::String Token = ExtractAuthToken(ARequest);
	if (Token.Pos("admin") == 0) {
		AAuthenticated = false;
		AUserID = "";
		TLogHelpers::LogMessage("[ADMIN] Access denied - admin token required");
	}
	else {
		TLogHelpers::LogMessage("[ADMIN] Admin access granted");
	}
}

void TAdminDemoResource::DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage)
{
	// Call parent validation
	TBaseInterceptor::DoCustomValidation(ARequest, AValid, AErrorMessage);

	if (!AValid) {
		return;
	}

	// Add admin-specific validation if needed
	TLogHelpers::LogMessage("[ADMIN] Admin validation passed");
}

void TAdminDemoResource::GetStatus(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	TJSONObject* ResponseObj = new TJSONObject();
	ResponseObj->AddPair("status", "Admin access confirmed");
	ResponseObj->AddPair("user", CurrentUserID);
	ResponseObj->AddPair("server_time", DateTimeToStr(Now()));
	ResponseObj->AddPair("version", "1.0.0");

	// Set response with proper ownership management to prevent RAD Server conflicts
	AResponse->Body->SetValue(ResponseObj, false);
}

static void RegisterAdminDemo()
{
    std::unique_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
	attributes->ResourceName = "admin";
	attributes->ResourceSuffix["GetStatus"] = "./status";
    RegisterResource(__typeinfo(TAdminDemoResource), attributes.release());
}

#pragma startup RegisterAdminDemo 64
