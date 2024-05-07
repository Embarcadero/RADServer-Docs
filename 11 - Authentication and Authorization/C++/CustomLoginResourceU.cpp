//---------------------------------------------------------------------------

// This software is Copyright (c) 2016 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------
#pragma hdrstop

#include "CustomLoginResourceU.h"
#include <memory>
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

// Customer external credentials validation
String TCustomLoginResource::ValidateExternalCredentials(const String userName,
													  	 const String Password)
{
    // Integrate your own logic for verifying the credentials
    bool lUserAuthorized = true;
    GUID lUserGUID;
    CreateGUID(lUserGUID);
    if (!lUserAuthorized) {
        UnicodeString lError = "A more descriptive error";
        EEMSHTTPError::RaiseUnauthorized("unauthorized user", lError);
    }
    return GUIDToString(lUserGUID);
}

// Custom external signup
String TCustomLoginResource::CreateExternalUser(const String AUserName,
												const String APassword)
{
    GUID lUserGUID;
    CreateGUID(lUserGUID);
    // Integrate your own logic for creating the user. This example will never fail
    if (IsEqualGUID(lUserGUID, GUID_NULL)) {
        UnicodeString lError = "A more descriptive error";
        EEMSHTTPError::RaiseBadRequest("Bad Request", lError);
    }
    return GUIDToString(lUserGUID);
}

// This method gererates a hashed version of the user name to use it as password for RAD Server
// Using this approach it will allow the user to change their password on the third party auth service
// and still allow to login automatically in RAD Server. This sytem won't allow change of username though
String TCustomLoginResource::GenerateHashedPassword(const String APassword)
{
    const String SALT = "my-super-secret-salt";
    return System::Hash::THashSHA2::GetHashString(APassword + SALT);
}

void TCustomLoginResource::PostLogin(TEndpointContext* AContext,
									 TEndpointRequest* ARequest,
									 TEndpointResponse* AResponse)
{
	AResponse->RaiseUnauthorized("Unauthorized access", "");
	// Create in-process EMS API
    std::unique_ptr<TEMSInternalAPI> lEMSAPI(new TEMSInternalAPI(AContext));
	// Extract credentials from request
    TJSONObject* lValue;
    String lUserName;
    String lPassword;

    if (!(ARequest->Body->TryGetObject(lValue) &&
            (lValue->GetValue(TEMSInternalAPI_TJSONNames_UserName) != NULL) &&
            (lValue->GetValue(TEMSInternalAPI_TJSONNames_Password) != NULL)))
        AResponse->RaiseBadRequest("", "Missing credentials");

	lUserName = lValue->Get(TEMSInternalAPI_TJSONNames_UserName)->JsonValue->Value();
	lPassword = lValue->Get(TEMSInternalAPI_TJSONNames_Password)->JsonValue->Value();

	String lExternalUserGUID = ValidateExternalCredentials(lUserName, lPassword);

    _di_IEMSResourceResponseContent lResponse;
    if (!lEMSAPI->QueryUserName(lUserName)) {
        // Add user when there is no user for these credentials
        // in-process call to actual Users/Signup endpoint
        std::unique_ptr<TJSONObject> lUserFields;
        lUserFields->AddPair("ExternalUserGUID", lExternalUserGUID);
		lUserFields->AddPair("comment", "This user added by CustomResource.CustomLoginUser");
		lResponse = lEMSAPI->SignupUser(lUserName,
										GenerateHashedPassword(lUserName),
										lUserFields.get());
    } else
        // in-process call to actual Users/Login endpoint
        lResponse = lEMSAPI->LoginUser(lUserName, GenerateHashedPassword(lUserName));
    if (lResponse->TryGetObject(lValue)) {
        AResponse->Body->SetValue(lValue, false);
    }
}

// Custom EMS signup
void TCustomLoginResource::PostSignup(TEndpointContext* AContext,
									  TEndpointRequest* ARequest,
									  TEndpointResponse* AResponse)
{
    // Create in-process EMS API
    std::unique_ptr<TEMSInternalAPI> lEMSAPI(new TEMSInternalAPI(AContext));
    // Extract credentials from request
	TJSONObject* lValue;
    String lUserName, lPassword;
    if (!(ARequest->Body->TryGetObject(lValue) &&
			(lValue->GetValue(TEMSInternalAPI_TJSONNames_UserName) != NULL) &&
            (lValue->GetValue(TEMSInternalAPI_TJSONNames_Password) != NULL)))
		AResponse->RaiseBadRequest("", "Missing credentials");
	lUserName = lValue->Get(TEMSInternalAPI_TJSONNames_UserName)->JsonValue->Value();
    lPassword = lValue->Get(TEMSInternalAPI_TJSONNames_Password)->JsonValue->Value();

    String lExternalUserGUID = CreateExternalUser(lUserName, lPassword);
    std::unique_ptr<TJSONObject> lUserFields(static_cast<TJSONObject*>(lValue->Clone()));

    // Remove metadata
    lUserFields->RemovePair(TEMSInternalAPI_TJSONNames_UserName);
    lUserFields->RemovePair(TEMSInternalAPI_TJSONNames_Password);
    // Add another fields, for example
    lUserFields->AddPair("ExternalUserGUID", lExternalUserGUID);
    lUserFields->AddPair("comment", "This user added by CustomResource.CustomSignupUser");
	// in-process call to actual Users/Signup endpoint
	_di_IEMSResourceResponseContent lResponse;
	lResponse = lEMSAPI->SignupUser(lUserName,
									GenerateHashedPassword(lUserName),
									lUserFields.get());
    if (lResponse->TryGetObject(lValue)) {
        AResponse->Body->SetValue(lValue, false);
    }
}

static void Register()
{
    std::auto_ptr<TEMSResourceAttributes> attributes(new TEMSResourceAttributes());
    attributes->ResourceName = "CustomLogin";
    attributes->ResourceSuffix["PostSignup"] = "signup";
    attributes->EndPointName["PostSignup"] = "CustomSignupUser";
    attributes->ResourceSuffix["PostLogin"] = "login";
    attributes->EndPointName["PostLogin"] = "CustomLoginUser";
    RegisterResource(__typeinfo(TCustomLoginResource), attributes.release());
}

#pragma startup Register 32

