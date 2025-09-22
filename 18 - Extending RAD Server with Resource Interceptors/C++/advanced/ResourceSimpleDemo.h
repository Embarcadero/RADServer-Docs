// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef ResourceSimpleDemoH
#define ResourceSimpleDemoH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <System.DateUtils.hpp>
#include <EMSHosting.Helpers.hpp>
#include <System.JSON.hpp>
#include "BaseInterceptor.h"
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)

class TDemoResource : public TBaseInterceptor
{
protected:
	void DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage) override;
	void DoCustomLogging(TEndpointRequest* ARequest, TEndpointResponse* AResponse) override;
	void DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID) override;

public:
	__fastcall ~TDemoResource(void) { }
	void GetHello(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
    void PostEcho(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
