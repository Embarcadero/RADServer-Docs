//---------------------------------------------------------------------------

#ifndef BaseInterceptorH
#define BaseInterceptorH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.JSON.hpp>
#include <System.DateUtils.hpp>
#include <System.TypInfo.hpp>
#include <System.Math.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <EMSHosting.Helpers.hpp>
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)
// Simple base interceptor for RAD Server - demonstrates extending a base class
class TBaseInterceptor : public TInterfacedPersistent, public IEMSResourceInterceptor
{
INTFOBJECT_IMPL_IUNKNOWN(TInterfacedPersistent)
private:
	System::String FRequestID;
	TDateTime FStartTime;

protected:
	System::String FCurrentUserID;
	// FResponseStatusCode field removed - no longer needed

	// Helper methods
	System::String GenerateRequestID();
	System::String ExtractAuthToken(TEndpointRequest* ARequest);
	bool ValidateAuthToken(const System::String& AToken);
	System::String GetUserIDFromToken(const System::String& AToken);
	System::String GetHeaderValue(TEndpointRequest* ARequest, const System::String& AHeaderName);
	bool ShouldIncludeMetadata(TEndpointRequest* ARequest);
	void LogRequestStart(TEndpointRequest::TMethod AMethod, const System::String& APath, const System::String& AUserID);
	void LogRequestComplete(int AStatusCode, int ADuration);

	// Virtual methods that can be overridden by descendants
	virtual void DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage);
	virtual void DoCustomLogging(TEndpointRequest* ARequest, TEndpointResponse* AResponse);
	virtual void DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID);

public:
	__fastcall ~TBaseInterceptor(void) { }

	// Access properties for descendant classes
	__property System::String CurrentUserID = {read = FCurrentUserID};

	// IEMSResourceInterceptor implementation
	void __fastcall BeforeRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse, bool& AHandled);
	void __fastcall AfterRequest(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
//---------------------------------------------------------------------------
#endif
