// EMS Resource Modules
//---------------------------------------------------------------------------

#ifndef ResourceDemoH
#define ResourceDemoH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <EMS.Services.hpp>
#include <EMS.ResourceAPI.hpp>
#include <EMS.ResourceTypes.hpp>
#include <EMSHosting.Helpers.hpp>
#include "BaseInterceptor.h"
//---------------------------------------------------------------------------
#pragma explicit_rtti methods (public)

class TAdminDemoResource : public TBaseInterceptor
{
protected:
	void DoCustomAuthentication(TEndpointRequest* ARequest, bool& AAuthenticated, System::String& AUserID) override;
	void DoCustomValidation(TEndpointRequest* ARequest, bool& AValid, System::String& AErrorMessage) override;

public:
	__fastcall ~TAdminDemoResource(void) { }

	// Resource endpoints
	void GetStatus(TEndpointContext* AContext, TEndpointRequest* ARequest, TEndpointResponse* AResponse);
};
#endif
