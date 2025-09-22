//---------------------------------------------------------------------------

#pragma hdrstop

#include "BaseInterceptor.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)

// Helper methods
System::String TBaseInterceptor::GenerateRequestID()
{
	return FormatDateTime("yyyymmdd-hhnnss-", Now()) + IntToStr(Random(9999));
}

System::String TBaseInterceptor::GetHeaderValue(TEndpointRequest* ARequest, const System::String& AHeaderName)
{
	try {
		return ARequest->Headers->GetValue(AHeaderName);
	}
	catch (Exception& E) {
		// Header not found or other error
		return "";
	}
}

System::String TBaseInterceptor::ExtractAuthToken(TEndpointRequest* ARequest)
{
	// Use custom header to avoid conflicts with RAD Server's built-in auth
	System::String AuthHeader = GetHeaderValue(ARequest, "X-Custom-Token");
	if (AuthHeader != "") {
		return AuthHeader;
	}
	else {
		return "";
	}
}

bool TBaseInterceptor::ValidateAuthToken(const System::String& AToken)
{
	// Simple validation - in real app, validate JWT or check database
	return AToken != "";
	// For demo purposes, accept any non-empty token
}

System::String TBaseInterceptor::GetUserIDFromToken(const System::String& AToken)
{
	// Simple extraction - in real app, decode JWT and extract user ID
	if (AToken.Pos("user:") > 0) {
		return AToken.SubString(AToken.Pos("user:") + 5, AToken.Length());
	}
	else if (AToken.Pos("admin") > 0) {
		return "admin-user";
	}
	else if (AToken != "") {
		return "user-" + AToken.SubString(1, Min(10, AToken.Length())); // Use first 10 chars of token
	}
	else {
		return "anonymous";
	}
}

// Check if metadata should be included based on URL parameter
bool TBaseInterceptor::ShouldIncludeMetadata(TEndpointRequest* ARequest)
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

void TBaseInterceptor::LogRequestStart(TEndpointRequest::TMethod AMethod, const System::String& APath, const System::String& AUserID)
{
	// Convert method enum to string for logging
	System::String MethodStr;
	switch (AMethod) {
		case TEndpointRequest::TMethod::Get: MethodStr = "GET"; break;
		case TEndpointRequest::TMethod::Put: MethodStr = "PUT"; break;
		case TEndpointRequest::TMethod::Post: MethodStr = "POST"; break;
		case TEndpointRequest::TMethod::Head: MethodStr = "HEAD"; break;
		case TEndpointRequest::TMethod::Delete: MethodStr = "DELETE"; break;
		case TEndpointRequest::TMethod::Patch: MethodStr = "PATCH"; break;
		case TEndpointRequest::TMethod::Other: MethodStr = "OTHER"; break;
		default: MethodStr = "UNKNOWN"; break;
	}
	
	TLogHelpers::LogMessage(Format("[%s] %s %s - User: %s - Started",
		ARRAYOFCONST((FRequestID, MethodStr, APath, AUserID))));
}

void TBaseInterceptor::LogRequestComplete(int AStatusCode, int ADuration)
{
	TLogHelpers::LogMessage(Format("[%s] Completed in %dms with status %d",
		ARRAYOFCONST((FRequestID, ADuration, AStatusCode))));
}

// IEMSResourceInterceptor implementation
void __fastcall TBaseInterceptor::BeforeRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse, bool& AHandled)
{

	// Initialize request tracking
	FRequestID = GenerateRequestID();
	FStartTime = Now();

	// Authentication
	System::String Token = ExtractAuthToken(ARequest);
	bool IsAuthenticated;
	System::String UserID;
	DoCustomAuthentication(ARequest, IsAuthenticated, UserID);

	if (!IsAuthenticated) {
		TJSONObject* ErrorResponse = new TJSONObject();
		if (Token == "") {
			ErrorResponse->AddPair("error", "Authentication required");
			ErrorResponse->AddPair("message", "Missing X-Custom-Token header");
		}
		else {
			ErrorResponse->AddPair("error", "Authentication failed");
			ErrorResponse->AddPair("message", "Invalid custom token");
		}

		AResponse->StatusCode = 401;
		AResponse->Body->SetValue(ErrorResponse, true);
		AHandled = true;
		return;
	}

	FCurrentUserID = UserID;

	// Custom validation
	bool IsValid;
	System::String ErrorMessage;
	IsValid = true;
	DoCustomValidation(ARequest, IsValid, ErrorMessage);
	if (!IsValid) {
		TJSONObject* ErrorResponse = new TJSONObject();
		ErrorResponse->AddPair("error", "Validation failed");
		ErrorResponse->AddPair("message", ErrorMessage);

		AResponse->StatusCode = 400;
		AResponse->Body->SetValue(ErrorResponse, true);
		AHandled = true;
		return;
	}

	// Log request start - use ARequest->MethodString directly
	LogRequestStart(ARequest->Method, ARequest->BasePath, FCurrentUserID);
}

void __fastcall TBaseInterceptor::AfterRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	int Duration = MilliSecondsBetween(Now(), FStartTime);

	// Check if metadata should be included
	if (!ShouldIncludeMetadata(ARequest)) {
		// Just log completion without metadata
		LogRequestComplete(200, Duration); // Default assumption
		DoCustomLogging(ARequest, AResponse);
		return;
	}

	// Add metadata to response
	try {
		// Create new response structure
		TJSONObject* ResponseObj = new TJSONObject();

		// Get the original response data directly from AResponse.Body
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
		MetaObj->AddPair("user_id", FCurrentUserID);
		MetaObj->AddPair("method", ARequest->MethodString);
		MetaObj->AddPair("path", ARequest->BasePath);

		ResponseObj->AddPair("meta", MetaObj);

		// Set the new response body - maintain ownership to prevent RAD Server conflicts
		AResponse->Body->SetValue(ResponseObj, false);
	}
	catch (Exception& E) {
		// If something goes wrong, just log it but don't break the response
		TLogHelpers::LogMessage(Format("[%s] Error adding metadata: %s", ARRAYOFCONST((FRequestID, E.Message))));
	}

	// Log request completion
	LogRequestComplete(200, Duration); // Default assumption

	// Allow descendants to add custom logging
	DoCustomLogging(ARequest, AResponse);
}

// Default implementations - descendants can override these
void TBaseInterceptor::DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID)
{
	System::String Token = ExtractAuthToken(ARequest);
	AAuthenticated = ValidateAuthToken(Token);
	if (AAuthenticated) {
		AUserID = GetUserIDFromToken(Token);
	}
	else {
		AUserID = "";
	}
}

void TBaseInterceptor::DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage)
{
	// Default validation - just check content type for POST/PUT
	AValid = true;
	if ((ARequest->Method == TEndpointRequest::TMethod::Post) || (ARequest->Method == TEndpointRequest::TMethod::Put)) {
		System::String ContentType = GetHeaderValue(ARequest, "Content-Type");
		if (ContentType == "") {
			AValid = false;
			AErrorMessage = "Content-Type header is required";
		}
		else if (ContentType != "application/json") {
			AValid = false;
			AErrorMessage = "Content-Type must be application/json";
		}
	}
}

void TBaseInterceptor::DoCustomLogging(TEndpointRequest* ARequest, TEndpointResponse* AResponse)
{
	// Default implementation does nothing - descendants can override
}
